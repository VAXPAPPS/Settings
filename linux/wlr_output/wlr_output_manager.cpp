#include "wlr_output_manager.h"

#include <cstring>
#include <cstdlib>
#include <cstdio>
#include <algorithm>

// ─────────────────────────────────────────────────────────────────────────────
// Static listener tables
// ─────────────────────────────────────────────────────────────────────────────

const wl_registry_listener WlrOutputManager::registry_listener_ = {
    .global        = WlrOutputManager::onRegistryGlobal,
    .global_remove = WlrOutputManager::onRegistryGlobalRemove,
};

const zwlr_output_manager_v1_listener WlrOutputManager::manager_listener_ = {
    .head     = WlrOutputManager::onManagerHead,
    .done     = WlrOutputManager::onManagerDone,
    .finished = WlrOutputManager::onManagerFinished,
};

// Head listener — covers v1 through v4 events
const zwlr_output_head_v1_listener WlrOutputManager::head_listener_ = {
    .name          = WlrOutputManager::onHeadName,
    .description   = WlrOutputManager::onHeadDescription,
    .physical_size = WlrOutputManager::onHeadPhysicalSize,
    .mode          = WlrOutputManager::onHeadMode,
    .enabled       = WlrOutputManager::onHeadEnabled,
    .current_mode  = WlrOutputManager::onHeadCurrentMode,
    .position      = WlrOutputManager::onHeadPosition,
    .transform     = WlrOutputManager::onHeadTransform,
    .scale         = WlrOutputManager::onHeadScale,
    .finished      = WlrOutputManager::onHeadFinished,
    // v2
    .make          = WlrOutputManager::onHeadMake,
    .model         = WlrOutputManager::onHeadModel,
    .serial_number = WlrOutputManager::onHeadSerialNumber,
    // v4
    .adaptive_sync = WlrOutputManager::onHeadAdaptiveSync,
};

const zwlr_output_mode_v1_listener WlrOutputManager::mode_listener_ = {
    .size      = WlrOutputManager::onModeSize,
    .refresh   = WlrOutputManager::onModeRefresh,
    .preferred = WlrOutputManager::onModePreferred,
    .finished  = WlrOutputManager::onModeFinished,
};

const zwlr_output_configuration_v1_listener WlrOutputManager::config_listener_ = {
    .succeeded = WlrOutputManager::onConfigSucceeded,
    .failed    = WlrOutputManager::onConfigFailed,
    .cancelled = WlrOutputManager::onConfigCancelled,
};

// ─────────────────────────────────────────────────────────────────────────────
// Constructor / Destructor
// ─────────────────────────────────────────────────────────────────────────────

WlrOutputManager::WlrOutputManager() = default;

WlrOutputManager::~WlrOutputManager() {
    disconnect();
}

// ─────────────────────────────────────────────────────────────────────────────
// connect / disconnect / dispatch
// ─────────────────────────────────────────────────────────────────────────────

bool WlrOutputManager::connect() {
    display_ = wl_display_connect(nullptr);
    if (!display_) {
        fprintf(stderr, "[WlrOutputManager] Cannot connect to Wayland display\n");
        return false;
    }

    registry_ = wl_display_get_registry(display_);
    if (!registry_) {
        fprintf(stderr, "[WlrOutputManager] Cannot get Wayland registry\n");
        wl_display_disconnect(display_);
        display_ = nullptr;
        return false;
    }

    wl_registry_add_listener(registry_, &registry_listener_, this);
    // Round-trip to receive all globals
    wl_display_roundtrip(display_);

    if (!manager_) {
        fprintf(stderr, "[WlrOutputManager] zwlr_output_manager_v1 not advertised by compositor\n");
        wl_registry_destroy(registry_);
        registry_ = nullptr;
        wl_display_disconnect(display_);
        display_ = nullptr;
        return false;
    }

    // Second round-trip to receive initial heads/modes/done
    wl_display_roundtrip(display_);

    connected_ = true;
    return true;
}

void WlrOutputManager::disconnect() {
    if (!display_) return;

    {
        std::lock_guard<std::mutex> lock(heads_mutex_);
        for (auto &head : heads_) {
            // Release modes (v3)
            for (auto &mode : head->modes) {
                if (mode->proxy) {
                    if (zwlr_output_mode_v1_get_version(mode->proxy) >= 3)
                        zwlr_output_mode_v1_release(mode->proxy);
                    else
                        zwlr_output_mode_v1_destroy(mode->proxy);
                    mode->proxy = nullptr;
                }
            }
            // Release head (v3)
            if (head->proxy) {
                if (zwlr_output_head_v1_get_version(head->proxy) >= 3)
                    zwlr_output_head_v1_release(head->proxy);
                else
                    zwlr_output_head_v1_destroy(head->proxy);
                head->proxy = nullptr;
            }
        }
        heads_.clear();
    }

    if (manager_) {
        zwlr_output_manager_v1_stop(manager_);
        zwlr_output_manager_v1_destroy(manager_);
        manager_ = nullptr;
    }

    if (registry_) {
        wl_registry_destroy(registry_);
        registry_ = nullptr;
    }

    wl_display_disconnect(display_);
    display_   = nullptr;
    connected_ = false;
}

bool WlrOutputManager::dispatch(int timeout_ms) {
    if (!display_) return false;
    if (wl_display_flush(display_) < 0) return false;
    if (timeout_ms > 0) {
        wl_display_dispatch_pending(display_);
        // Blocking dispatch with timeout via wl_display_dispatch
        return wl_display_dispatch(display_) >= 0;
    }
    return wl_display_dispatch_pending(display_) >= 0;
}

// ─────────────────────────────────────────────────────────────────────────────
// Read API
// ─────────────────────────────────────────────────────────────────────────────

std::vector<WlrHead> WlrOutputManager::getHeads() const {
    std::lock_guard<std::mutex> lock(heads_mutex_);
    std::vector<WlrHead> result;
    for (const auto &h : heads_) {
        if (!h->finished)
            result.push_back(*h);
    }
    return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// Write API — internal helper
// ─────────────────────────────────────────────────────────────────────────────

WlrMode *WlrOutputManager::findMode(WlrHead &head, int32_t w, int32_t h, int32_t r_mhz) {
    // Exact match
    for (auto &m : head.modes) {
        if (m->width == w && m->height == h && m->refresh_mhz == r_mhz)
            return m.get();
    }
    // Closest refresh match for same resolution
    WlrMode *best = nullptr;
    int32_t  best_diff = INT32_MAX;
    for (auto &m : head.modes) {
        if (m->width == w && m->height == h) {
            int32_t diff = abs(m->refresh_mhz - r_mhz);
            if (diff < best_diff) { best_diff = diff; best = m.get(); }
        }
    }
    return best;
}

bool WlrOutputManager::sendConfiguration(const std::vector<HeadConfig> &configs,
                                          bool test_only,
                                          WlrConfigResultCb result_cb,
                                          void *user_data) {
    if (!manager_) return false;

    // Create configuration object
    zwlr_output_configuration_v1 *config =
        zwlr_output_manager_v1_create_configuration(manager_, last_serial_);
    if (!config) return false;

    {
        std::lock_guard<std::mutex> lock(heads_mutex_);

        for (const auto &hc : configs) {
            // Find head by name
            WlrHead *head_ptr = nullptr;
            for (auto &h : heads_) {
                if (h->name == hc.head_name) { head_ptr = h.get(); break; }
            }
            if (!head_ptr || !head_ptr->proxy) {
                zwlr_output_configuration_v1_destroy(config);
                return false;
            }

            if (!hc.enabled) {
                zwlr_output_configuration_v1_disable_head(config, head_ptr->proxy);
            } else {
                // enable_head returns a configuration_head object
                zwlr_output_configuration_head_v1 *cfg_head =
                    zwlr_output_configuration_v1_enable_head(config, head_ptr->proxy);

                if (cfg_head) {
                    // Set mode
                    if (hc.use_custom_mode) {
                        zwlr_output_configuration_head_v1_set_custom_mode(
                            cfg_head,
                            hc.mode_width,
                            hc.mode_height,
                            hc.mode_refresh_mhz);
                    } else {
                        WlrMode *m = findMode(*head_ptr,
                                              hc.mode_width,
                                              hc.mode_height,
                                              hc.mode_refresh_mhz);
                        if (m && m->proxy) {
                            zwlr_output_configuration_head_v1_set_mode(cfg_head, m->proxy);
                        }
                    }

                    // Position
                    zwlr_output_configuration_head_v1_set_position(
                        cfg_head, hc.pos_x, hc.pos_y);

                    // Transform
                    zwlr_output_configuration_head_v1_set_transform(
                        cfg_head, (wl_output_transform)hc.transform);

                    // Scale (wl_fixed)
                    zwlr_output_configuration_head_v1_set_scale(
                        cfg_head, wl_fixed_from_double(hc.scale));

                    // Adaptive sync (v4)
                    if (hc.adaptive_sync >= 0) {
                        uint32_t version = zwlr_output_configuration_head_v1_get_version(cfg_head);
                        if (version >= 4) {
                            zwlr_output_configuration_head_v1_set_adaptive_sync(
                                cfg_head,
                                (uint32_t)hc.adaptive_sync);
                        }
                    }
                }
            }
        }
    }

    // Set up result context
    ConfigContext *ctx = new ConfigContext{result_cb, user_data, config};
    zwlr_output_configuration_v1_add_listener(config, &config_listener_, ctx);

    if (test_only)
        zwlr_output_configuration_v1_test(config);
    else
        zwlr_output_configuration_v1_apply(config);

    wl_display_flush(display_);
    return true;
}

bool WlrOutputManager::applyConfiguration(const std::vector<HeadConfig> &configs,
                                           WlrConfigResultCb result_cb,
                                           void *user_data) {
    return sendConfiguration(configs, false, result_cb, user_data);
}

bool WlrOutputManager::testConfiguration(const std::vector<HeadConfig> &configs,
                                          WlrConfigResultCb result_cb,
                                          void *user_data) {
    return sendConfiguration(configs, true, result_cb, user_data);
}

// ─────────────────────────────────────────────────────────────────────────────
// Registry listeners
// ─────────────────────────────────────────────────────────────────────────────

void WlrOutputManager::onRegistryGlobal(void *data, wl_registry *registry,
                                         uint32_t name, const char *interface,
                                         uint32_t version) {
    WlrOutputManager *self = static_cast<WlrOutputManager *>(data);

    if (strcmp(interface, zwlr_output_manager_v1_interface.name) == 0) {
        // Bind at the highest version we support (4)
        uint32_t bind_version = (version < 4) ? version : 4;
        self->manager_ = static_cast<zwlr_output_manager_v1 *>(
            wl_registry_bind(registry, name,
                             &zwlr_output_manager_v1_interface,
                             bind_version));
        zwlr_output_manager_v1_add_listener(self->manager_,
                                             &manager_listener_, self);
    }
}

void WlrOutputManager::onRegistryGlobalRemove(void *data, wl_registry *,
                                               uint32_t /*name*/) {
    // Nothing to do — manager destruction is handled via finished event
}

// ─────────────────────────────────────────────────────────────────────────────
// Manager listeners
// ─────────────────────────────────────────────────────────────────────────────

void WlrOutputManager::onManagerHead(void *data,
                                      zwlr_output_manager_v1 *,
                                      zwlr_output_head_v1 *head_proxy) {
    WlrOutputManager *self = static_cast<WlrOutputManager *>(data);

    auto head = std::make_shared<WlrHead>();
    head->proxy = head_proxy;

    // Add listener with head as user data
    zwlr_output_head_v1_add_listener(head_proxy, &head_listener_, head.get());

    std::lock_guard<std::mutex> lock(self->heads_mutex_);
    self->heads_.push_back(head);
}

void WlrOutputManager::onManagerDone(void *data,
                                      zwlr_output_manager_v1 *,
                                      uint32_t serial) {
    WlrOutputManager *self = static_cast<WlrOutputManager *>(data);
    self->last_serial_ = serial;

    // Remove finished heads
    {
        std::lock_guard<std::mutex> lock(self->heads_mutex_);
        self->heads_.erase(
            std::remove_if(self->heads_.begin(), self->heads_.end(),
                [](const std::shared_ptr<WlrHead> &h){ return h->finished; }),
            self->heads_.end());
    }

    if (self->heads_changed_cb_)
        self->heads_changed_cb_(self->heads_changed_data_);
}

void WlrOutputManager::onManagerFinished(void *data, zwlr_output_manager_v1 *) {
    WlrOutputManager *self = static_cast<WlrOutputManager *>(data);
    // Compositor is done — mark disconnected
    self->connected_ = false;
    if (self->heads_changed_cb_)
        self->heads_changed_cb_(self->heads_changed_data_);
}

// ─────────────────────────────────────────────────────────────────────────────
// Head listeners — v1
// ─────────────────────────────────────────────────────────────────────────────

void WlrOutputManager::onHeadName(void *data, zwlr_output_head_v1 *, const char *name) {
    static_cast<WlrHead *>(data)->name = name ? name : "";
}

void WlrOutputManager::onHeadDescription(void *data, zwlr_output_head_v1 *, const char *desc) {
    static_cast<WlrHead *>(data)->description = desc ? desc : "";
}

void WlrOutputManager::onHeadPhysicalSize(void *data, zwlr_output_head_v1 *,
                                           int32_t w, int32_t h) {
    WlrHead *head = static_cast<WlrHead *>(data);
    head->physical_width  = w;
    head->physical_height = h;
}

void WlrOutputManager::onHeadMode(void *data, zwlr_output_head_v1 *,
                                   zwlr_output_mode_v1 *mode_proxy) {
    WlrHead *head = static_cast<WlrHead *>(data);

    auto mode = std::make_shared<WlrMode>();
    mode->proxy = mode_proxy;

    zwlr_output_mode_v1_add_listener(mode_proxy, &mode_listener_, mode.get());
    head->modes.push_back(mode);
}

void WlrOutputManager::onHeadEnabled(void *data, zwlr_output_head_v1 *, int32_t enabled) {
    static_cast<WlrHead *>(data)->enabled = (enabled != 0);
}

void WlrOutputManager::onHeadCurrentMode(void *data, zwlr_output_head_v1 *,
                                          zwlr_output_mode_v1 *mode_proxy) {
    WlrHead *head = static_cast<WlrHead *>(data);
    head->current_mode = nullptr;
    for (auto &m : head->modes) {
        if (m->proxy == mode_proxy) {
            head->current_mode = m.get();
            break;
        }
    }
}

void WlrOutputManager::onHeadPosition(void *data, zwlr_output_head_v1 *,
                                       int32_t x, int32_t y) {
    WlrHead *head = static_cast<WlrHead *>(data);
    head->pos_x = x;
    head->pos_y = y;
}

void WlrOutputManager::onHeadTransform(void *data, zwlr_output_head_v1 *,
                                        int32_t transform) {
    static_cast<WlrHead *>(data)->transform = transform;
}

void WlrOutputManager::onHeadScale(void *data, zwlr_output_head_v1 *,
                                    wl_fixed_t scale) {
    static_cast<WlrHead *>(data)->scale = wl_fixed_to_double(scale);
}

void WlrOutputManager::onHeadFinished(void *data, zwlr_output_head_v1 *) {
    static_cast<WlrHead *>(data)->finished = true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Head listeners — v2
// ─────────────────────────────────────────────────────────────────────────────

void WlrOutputManager::onHeadMake(void *data, zwlr_output_head_v1 *, const char *make) {
    static_cast<WlrHead *>(data)->make = make ? make : "";
}

void WlrOutputManager::onHeadModel(void *data, zwlr_output_head_v1 *, const char *model) {
    static_cast<WlrHead *>(data)->model = model ? model : "";
}

void WlrOutputManager::onHeadSerialNumber(void *data, zwlr_output_head_v1 *, const char *serial) {
    static_cast<WlrHead *>(data)->serial_number = serial ? serial : "";
}

// ─────────────────────────────────────────────────────────────────────────────
// Head listeners — v4
// ─────────────────────────────────────────────────────────────────────────────

void WlrOutputManager::onHeadAdaptiveSync(void *data, zwlr_output_head_v1 *, uint32_t state) {
    static_cast<WlrHead *>(data)->adaptive_sync = state;
}

// ─────────────────────────────────────────────────────────────────────────────
// Mode listeners
// ─────────────────────────────────────────────────────────────────────────────

void WlrOutputManager::onModeSize(void *data, zwlr_output_mode_v1 *,
                                   int32_t w, int32_t h) {
    WlrMode *mode = static_cast<WlrMode *>(data);
    mode->width  = w;
    mode->height = h;
}

void WlrOutputManager::onModeRefresh(void *data, zwlr_output_mode_v1 *, int32_t refresh) {
    static_cast<WlrMode *>(data)->refresh_mhz = refresh;
}

void WlrOutputManager::onModePreferred(void *data, zwlr_output_mode_v1 *) {
    static_cast<WlrMode *>(data)->preferred = true;
}

void WlrOutputManager::onModeFinished(void *data, zwlr_output_mode_v1 *mode_proxy) {
    WlrMode *mode = static_cast<WlrMode *>(data);
    mode->finished = true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Configuration listeners
// ─────────────────────────────────────────────────────────────────────────────

void WlrOutputManager::onConfigSucceeded(void *data, zwlr_output_configuration_v1 *config) {
    ConfigContext *ctx = static_cast<ConfigContext *>(data);
    if (ctx->cb) ctx->cb(ctx->user_data, 0);
    zwlr_output_configuration_v1_destroy(config);
    delete ctx;
}

void WlrOutputManager::onConfigFailed(void *data, zwlr_output_configuration_v1 *config) {
    ConfigContext *ctx = static_cast<ConfigContext *>(data);
    if (ctx->cb) ctx->cb(ctx->user_data, 1);
    zwlr_output_configuration_v1_destroy(config);
    delete ctx;
}

void WlrOutputManager::onConfigCancelled(void *data, zwlr_output_configuration_v1 *config) {
    ConfigContext *ctx = static_cast<ConfigContext *>(data);
    if (ctx->cb) ctx->cb(ctx->user_data, 2);
    zwlr_output_configuration_v1_destroy(config);
    delete ctx;
}
