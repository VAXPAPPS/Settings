#pragma once
#ifndef WLR_OUTPUT_MANAGER_H
#define WLR_OUTPUT_MANAGER_H

#include <wayland-client.h>
#include "wlr_output_management.h"

#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <vector>
#include <string>
#include <functional>
#include <memory>
#include <mutex>

// ─────────────────────────────────────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────────────────────────────────────

struct WlrMode {
    zwlr_output_mode_v1 *proxy  = nullptr;
    int32_t              width  = 0;
    int32_t              height = 0;
    int32_t              refresh_mhz = 0;   // millihertz
    bool                 preferred   = false;
    bool                 finished    = false;
};

struct WlrHead {
    zwlr_output_head_v1 *proxy        = nullptr;

    // v1 properties
    std::string          name;
    std::string          description;
    int32_t              physical_width  = 0;   // mm
    int32_t              physical_height = 0;   // mm
    std::vector<std::shared_ptr<WlrMode>> modes;
    bool                 enabled         = false;
    WlrMode             *current_mode    = nullptr;
    int32_t              pos_x           = 0;
    int32_t              pos_y           = 0;
    int32_t              transform       = 0;  // wl_output_transform enum
    double               scale           = 1.0;

    // v2 properties
    std::string          make;
    std::string          model;
    std::string          serial_number;

    // v4 properties
    uint32_t             adaptive_sync = 0;  // zwlr_output_head_v1_adaptive_sync_state

    bool                 finished      = false;
};

// ─────────────────────────────────────────────────────────────────────────────
// Callbacks (called on Wayland event thread)
// ─────────────────────────────────────────────────────────────────────────────

typedef void (*WlrHeadsChangedCb)(void *user_data);
typedef void (*WlrConfigResultCb)(void *user_data, int result);
// result: 0=succeeded, 1=failed, 2=cancelled

// ─────────────────────────────────────────────────────────────────────────────
// Manager
// ─────────────────────────────────────────────────────────────────────────────

class WlrOutputManager {
public:
    WlrOutputManager();
    ~WlrOutputManager();

    // Connect to Wayland and bind wlr_output_manager_v1
    // Returns true on success
    bool connect();

    // Disconnect and free all resources
    void disconnect();

    bool isConnected() const { return connected_; }

    // Dispatch pending events (call repeatedly or from a dedicated thread)
    // Returns false on error
    bool dispatch(int timeout_ms = 0);

    // ── Read API ──────────────────────────────────────────────────────────────

    // Thread-safe snapshot of current heads (deep copy)
    std::vector<WlrHead> getHeads() const;

    uint32_t lastSerial() const { return last_serial_; }

    // ── Write API ─────────────────────────────────────────────────────────────

    struct HeadConfig {
        std::string head_name;
        bool        enabled = true;

        // only when enabled:
        bool        use_custom_mode = false;
        std::string mode_name;      // name = "WxH@mHz" built internally
        int32_t     mode_width  = 0;
        int32_t     mode_height = 0;
        int32_t     mode_refresh_mhz = 0;

        int32_t     pos_x = 0;
        int32_t     pos_y = 0;
        int32_t     transform = 0;
        double      scale = 1.0;
        int32_t     adaptive_sync = -1;  // -1 = don't set
    };

    // Apply configuration atomically
    // result_cb is invoked when compositor responds (succeeded/failed/cancelled)
    bool applyConfiguration(const std::vector<HeadConfig> &configs,
                            WlrConfigResultCb result_cb,
                            void *user_data);

    // Test configuration without applying
    bool testConfiguration(const std::vector<HeadConfig> &configs,
                           WlrConfigResultCb result_cb,
                           void *user_data);

    // ── Callbacks ─────────────────────────────────────────────────────────────

    void setHeadsChangedCallback(WlrHeadsChangedCb cb, void *user_data) {
        heads_changed_cb_   = cb;
        heads_changed_data_ = user_data;
    }

private:
    // ── Wayland objects ───────────────────────────────────────────────────────
    wl_display              *display_  = nullptr;
    wl_registry             *registry_ = nullptr;
    zwlr_output_manager_v1  *manager_  = nullptr;
    bool                     connected_ = false;
    uint32_t                 last_serial_ = 0;

    // ── State ─────────────────────────────────────────────────────────────────
    std::vector<std::shared_ptr<WlrHead>> heads_;
    mutable std::mutex                    heads_mutex_;

    WlrHeadsChangedCb heads_changed_cb_   = nullptr;
    void             *heads_changed_data_ = nullptr;

    // ── Internal helpers ──────────────────────────────────────────────────────
    bool sendConfiguration(const std::vector<HeadConfig> &configs,
                           bool test_only,
                           WlrConfigResultCb result_cb,
                           void *user_data);

    WlrMode *findMode(WlrHead &head, int32_t w, int32_t h, int32_t r_mhz);

    // ── Registry listener ─────────────────────────────────────────────────────
    static void onRegistryGlobal(void *data, wl_registry *registry,
                                 uint32_t name, const char *interface,
                                 uint32_t version);
    static void onRegistryGlobalRemove(void *data, wl_registry *registry,
                                       uint32_t name);

    // ── Manager listeners ─────────────────────────────────────────────────────
    static void onManagerHead(void *data,
                              zwlr_output_manager_v1 *manager,
                              zwlr_output_head_v1 *head);
    static void onManagerDone(void *data,
                              zwlr_output_manager_v1 *manager,
                              uint32_t serial);
    static void onManagerFinished(void *data,
                                  zwlr_output_manager_v1 *manager);

    // ── Head listeners ────────────────────────────────────────────────────────
    static void onHeadName       (void *data, zwlr_output_head_v1 *, const char *name);
    static void onHeadDescription(void *data, zwlr_output_head_v1 *, const char *desc);
    static void onHeadPhysicalSize(void *data, zwlr_output_head_v1 *, int32_t w, int32_t h);
    static void onHeadMode       (void *data, zwlr_output_head_v1 *, zwlr_output_mode_v1 *mode);
    static void onHeadEnabled    (void *data, zwlr_output_head_v1 *, int32_t enabled);
    static void onHeadCurrentMode(void *data, zwlr_output_head_v1 *, zwlr_output_mode_v1 *mode);
    static void onHeadPosition   (void *data, zwlr_output_head_v1 *, int32_t x, int32_t y);
    static void onHeadTransform  (void *data, zwlr_output_head_v1 *, int32_t transform);
    static void onHeadScale      (void *data, zwlr_output_head_v1 *, wl_fixed_t scale);
    static void onHeadFinished   (void *data, zwlr_output_head_v1 *);
    // v2
    static void onHeadMake        (void *data, zwlr_output_head_v1 *, const char *make);
    static void onHeadModel       (void *data, zwlr_output_head_v1 *, const char *model);
    static void onHeadSerialNumber(void *data, zwlr_output_head_v1 *, const char *serial);
    // v4
    static void onHeadAdaptiveSync(void *data, zwlr_output_head_v1 *, uint32_t state);

    // ── Mode listeners ────────────────────────────────────────────────────────
    static void onModeSize     (void *data, zwlr_output_mode_v1 *, int32_t w, int32_t h);
    static void onModeRefresh  (void *data, zwlr_output_mode_v1 *, int32_t refresh);
    static void onModePreferred(void *data, zwlr_output_mode_v1 *);
    static void onModeFinished (void *data, zwlr_output_mode_v1 *);

    // ── Configuration listeners ───────────────────────────────────────────────
    struct ConfigContext {
        WlrConfigResultCb cb;
        void             *user_data;
        zwlr_output_configuration_v1 *config_proxy;
    };

    static void onConfigSucceeded(void *data, zwlr_output_configuration_v1 *);
    static void onConfigFailed   (void *data, zwlr_output_configuration_v1 *);
    static void onConfigCancelled(void *data, zwlr_output_configuration_v1 *);

    static const zwlr_output_manager_v1_listener   manager_listener_;
    static const zwlr_output_head_v1_listener       head_listener_;
    static const zwlr_output_mode_v1_listener       mode_listener_;
    static const zwlr_output_configuration_v1_listener config_listener_;
    static const wl_registry_listener              registry_listener_;
};

#endif // WLR_OUTPUT_MANAGER_H
