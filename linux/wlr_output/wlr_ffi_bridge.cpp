#include "wlr_ffi_bridge.h"
#include "wlr_output_manager.h"

#include <cstdlib>
#include <cstring>
#include <vector>
#include <string>

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

static char *dup_str(const std::string &s) {
    char *buf = static_cast<char *>(malloc(s.size() + 1));
    if (buf) memcpy(buf, s.c_str(), s.size() + 1);
    return buf;
}

// ─────────────────────────────────────────────────────────────────────────────
// Lifecycle
// ─────────────────────────────────────────────────────────────────────────────

WlrManagerHandle wlr_manager_create(void) {
    return static_cast<WlrManagerHandle>(new WlrOutputManager());
}

bool wlr_manager_connect(WlrManagerHandle handle) {
    if (!handle) return false;
    return static_cast<WlrOutputManager *>(handle)->connect();
}

void wlr_manager_disconnect(WlrManagerHandle handle) {
    if (!handle) return;
    static_cast<WlrOutputManager *>(handle)->disconnect();
}

void wlr_manager_destroy(WlrManagerHandle handle) {
    if (!handle) return;
    delete static_cast<WlrOutputManager *>(handle);
}

void wlr_manager_dispatch(WlrManagerHandle handle) {
    if (!handle) return;
    static_cast<WlrOutputManager *>(handle)->dispatch(0);
}

// ─────────────────────────────────────────────────────────────────────────────
// Callbacks
// ─────────────────────────────────────────────────────────────────────────────

void wlr_manager_set_heads_changed_cb(WlrManagerHandle handle,
                                       WlrHeadsChangedFn cb,
                                       void *user_data) {
    if (!handle) return;
    static_cast<WlrOutputManager *>(handle)->setHeadsChangedCallback(cb, user_data);
}

// ─────────────────────────────────────────────────────────────────────────────
// Read — build flat WlrHeadInfo array
// ─────────────────────────────────────────────────────────────────────────────

WlrHeadInfo *wlr_manager_get_heads(WlrManagerHandle handle, int32_t *count_out) {
    if (!handle || !count_out) return nullptr;

    WlrOutputManager *mgr = static_cast<WlrOutputManager *>(handle);
    std::vector<WlrHead> heads = mgr->getHeads();

    *count_out = static_cast<int32_t>(heads.size());
    if (heads.empty()) return nullptr;

    WlrHeadInfo *infos = static_cast<WlrHeadInfo *>(
        calloc(heads.size(), sizeof(WlrHeadInfo)));
    if (!infos) { *count_out = 0; return nullptr; }

    for (size_t i = 0; i < heads.size(); ++i) {
        const WlrHead &h = heads[i];
        WlrHeadInfo   &info = infos[i];

        info.name               = dup_str(h.name);
        info.description        = dup_str(h.description);
        info.physical_width_mm  = h.physical_width;
        info.physical_height_mm = h.physical_height;
        info.enabled            = h.enabled;
        info.pos_x              = h.pos_x;
        info.pos_y              = h.pos_y;
        info.transform          = h.transform;
        info.scale              = h.scale;
        info.make               = dup_str(h.make);
        info.model              = dup_str(h.model);
        info.serial_number      = dup_str(h.serial_number);
        info.adaptive_sync      = h.adaptive_sync;

        // Current mode
        if (h.current_mode) {
            info.current_width       = h.current_mode->width;
            info.current_height      = h.current_mode->height;
            info.current_refresh_mhz = h.current_mode->refresh_mhz;
            info.current_preferred   = h.current_mode->preferred;
        }

        // Modes array (filter out finished modes)
        std::vector<WlrMode *> valid_modes;
        for (const auto &m : h.modes) {
            if (!m->finished) valid_modes.push_back(m.get());
        }

        info.mode_count = static_cast<int32_t>(valid_modes.size());
        if (!valid_modes.empty()) {
            info.modes = static_cast<WlrModeInfo *>(
                calloc(valid_modes.size(), sizeof(WlrModeInfo)));
            if (info.modes) {
                for (size_t j = 0; j < valid_modes.size(); ++j) {
                    info.modes[j].width       = valid_modes[j]->width;
                    info.modes[j].height      = valid_modes[j]->height;
                    info.modes[j].refresh_mhz = valid_modes[j]->refresh_mhz;
                    info.modes[j].preferred   = valid_modes[j]->preferred;
                }
            }
        }
    }

    return infos;
}

void wlr_free_heads(WlrHeadInfo *heads, int32_t count) {
    if (!heads) return;
    for (int32_t i = 0; i < count; ++i) {
        free(heads[i].name);
        free(heads[i].description);
        free(heads[i].make);
        free(heads[i].model);
        free(heads[i].serial_number);
        free(heads[i].modes);
    }
    free(heads);
}

// ─────────────────────────────────────────────────────────────────────────────
// Write
// ─────────────────────────────────────────────────────────────────────────────

static std::vector<WlrOutputManager::HeadConfig> buildConfigs(
    const WlrHeadConfig *configs, int32_t count) {

    std::vector<WlrOutputManager::HeadConfig> result;
    result.reserve(count);
    for (int32_t i = 0; i < count; ++i) {
        WlrOutputManager::HeadConfig hc;
        hc.head_name          = configs[i].head_name ? configs[i].head_name : "";
        hc.enabled            = configs[i].enabled;
        hc.use_custom_mode    = configs[i].use_custom_mode;
        hc.mode_width         = configs[i].mode_width;
        hc.mode_height        = configs[i].mode_height;
        hc.mode_refresh_mhz   = configs[i].mode_refresh_mhz;
        hc.pos_x              = configs[i].pos_x;
        hc.pos_y              = configs[i].pos_y;
        hc.transform          = configs[i].transform;
        hc.scale              = configs[i].scale;
        hc.adaptive_sync      = configs[i].adaptive_sync;
        result.push_back(hc);
    }
    return result;
}

bool wlr_manager_apply_config(WlrManagerHandle   handle,
                               const WlrHeadConfig *configs,
                               int32_t              config_count,
                               WlrConfigResultFn    result_cb,
                               void                *user_data) {
    if (!handle || !configs || config_count <= 0) return false;
    auto hcs = buildConfigs(configs, config_count);
    return static_cast<WlrOutputManager *>(handle)->applyConfiguration(
        hcs,
        reinterpret_cast<WlrConfigResultCb>(result_cb),
        user_data);
}

bool wlr_manager_test_config(WlrManagerHandle   handle,
                              const WlrHeadConfig *configs,
                              int32_t              config_count,
                              WlrConfigResultFn    result_cb,
                              void                *user_data) {
    if (!handle || !configs || config_count <= 0) return false;
    auto hcs = buildConfigs(configs, config_count);
    return static_cast<WlrOutputManager *>(handle)->testConfiguration(
        hcs,
        reinterpret_cast<WlrConfigResultCb>(result_cb),
        user_data);
}

// ─────────────────────────────────────────────────────────────────────────────
// Misc
// ─────────────────────────────────────────────────────────────────────────────

void wlr_free_string(char *str) {
    free(str);
}
