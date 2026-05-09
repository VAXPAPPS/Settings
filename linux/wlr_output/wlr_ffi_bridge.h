#pragma once
#ifndef WLR_FFI_BRIDGE_H
#define WLR_FFI_BRIDGE_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// ─────────────────────────────────────────────────────────────────────────────
// Opaque handle
// ─────────────────────────────────────────────────────────────────────────────

typedef void* WlrManagerHandle;

// ─────────────────────────────────────────────────────────────────────────────
// Flat structs (C-ABI safe, owned strings as char*)
// ─────────────────────────────────────────────────────────────────────────────

// A single mode entry
typedef struct {
    int32_t width;
    int32_t height;
    int32_t refresh_mhz;   // e.g. 60000 = 60 Hz
    bool    preferred;
} WlrModeInfo;

// A single head entry
typedef struct {
    // v1
    char    *name;           // caller must free via wlr_free_string
    char    *description;
    int32_t  physical_width_mm;
    int32_t  physical_height_mm;
    bool     enabled;
    int32_t  pos_x;
    int32_t  pos_y;
    int32_t  transform;     // wl_output_transform value (0=normal,1=90,2=180,3=270,4-7=flipped)
    double   scale;
    // current mode (zeroed if head disabled or no mode)
    int32_t  current_width;
    int32_t  current_height;
    int32_t  current_refresh_mhz;
    bool     current_preferred;
    // modes array
    WlrModeInfo *modes;
    int32_t      mode_count;
    // v2
    char    *make;
    char    *model;
    char    *serial_number;
    // v4
    uint32_t adaptive_sync; // 0=disabled, 1=enabled
} WlrHeadInfo;

// ─────────────────────────────────────────────────────────────────────────────
// Head config (input for apply/test)
// ─────────────────────────────────────────────────────────────────────────────

typedef struct {
    const char *head_name;    // must match WlrHeadInfo.name
    bool        enabled;

    // only when enabled:
    bool        use_custom_mode;
    int32_t     mode_width;
    int32_t     mode_height;
    int32_t     mode_refresh_mhz;

    int32_t     pos_x;
    int32_t     pos_y;
    int32_t     transform;
    double      scale;
    int32_t     adaptive_sync; // -1 = don't set, 0 = disable, 1 = enable
} WlrHeadConfig;

// ─────────────────────────────────────────────────────────────────────────────
// Callback types
// ─────────────────────────────────────────────────────────────────────────────

// Called when any head/mode state changes (after every "done" event)
typedef void (*WlrHeadsChangedFn)(void *user_data);

// Called when apply/test completes:
//   result: 0=succeeded, 1=failed, 2=cancelled
typedef void (*WlrConfigResultFn)(void *user_data, int32_t result);

// ─────────────────────────────────────────────────────────────────────────────
// Lifecycle
// ─────────────────────────────────────────────────────────────────────────────

WlrManagerHandle wlr_manager_create(void);
bool             wlr_manager_connect(WlrManagerHandle handle);
void             wlr_manager_disconnect(WlrManagerHandle handle);
void             wlr_manager_destroy(WlrManagerHandle handle);

// Dispatch pending Wayland events (non-blocking)
void wlr_manager_dispatch(WlrManagerHandle handle);

// ─────────────────────────────────────────────────────────────────────────────
// Callbacks
// ─────────────────────────────────────────────────────────────────────────────

void wlr_manager_set_heads_changed_cb(WlrManagerHandle handle,
                                       WlrHeadsChangedFn cb,
                                       void *user_data);

// ─────────────────────────────────────────────────────────────────────────────
// Read
// ─────────────────────────────────────────────────────────────────────────────

// Returns heap-allocated array; call wlr_free_heads to release
WlrHeadInfo *wlr_manager_get_heads(WlrManagerHandle handle, int32_t *count_out);
void          wlr_free_heads(WlrHeadInfo *heads, int32_t count);

// ─────────────────────────────────────────────────────────────────────────────
// Write
// ─────────────────────────────────────────────────────────────────────────────

bool wlr_manager_apply_config(WlrManagerHandle  handle,
                               const WlrHeadConfig *configs,
                               int32_t              config_count,
                               WlrConfigResultFn    result_cb,
                               void                *user_data);

bool wlr_manager_test_config(WlrManagerHandle   handle,
                              const WlrHeadConfig *configs,
                              int32_t              config_count,
                              WlrConfigResultFn    result_cb,
                              void                *user_data);

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

void wlr_free_string(char *str);

#ifdef __cplusplus
}
#endif

#endif // WLR_FFI_BRIDGE_H
