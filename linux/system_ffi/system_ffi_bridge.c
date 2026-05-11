/*
 * system_ffi_bridge.c
 *
 * Native FFI bridge for the System Settings page.
 * Replaces all dart:io / Process.run() calls with direct POSIX/C API calls.
 *
 * Exported symbols (all marked __attribute__((visibility("default")))):
 *
 *  — System Info
 *    char* sys_get_hostname()
 *    char* sys_get_os_name()
 *    char* sys_get_kernel_version()
 *    char* sys_get_cpu_info()
 *    char* sys_get_total_memory()
 *    char* sys_get_disk_info()
 *
 *  — Locale / Language
 *    char* sys_get_locale()                        (reads LANG env / locale.conf)
 *
 *  — Date & Time  (timedatectl via D-Bus-less POSIX reads)
 *    char* sys_get_timezone()                      (reads /etc/localtime symlink)
 *    int   sys_get_ntp_enabled()                   (checks timedatectl show via popen)
 *    int   sys_set_ntp(int enabled)                (calls timedatectl set-ntp)
 *    int   sys_set_timezone(const char* tz)        (calls timedatectl set-timezone)
 *    char* sys_list_timezones()                    (returns '\n'-delimited list)
 *
 *  — Users
 *    char* sys_get_users()                         (reads /etc/passwd, returns JSON-like CSV)
 *
 *  — SSH
 *    int   sys_is_ssh_enabled()                    (systemctl is-active ssh/sshd)
 *    int   sys_set_ssh_enabled(int enabled)        (sudo systemctl start/stop)
 *    char* sys_get_ssh_info()                      (hostname + IP)
 *
 *  — Remote Desktop (VNC via vino-server systemctl)
 *    int   sys_is_remote_desktop_enabled()
 *    int   sys_set_remote_desktop_enabled(int enabled)
 *
 *  — Memory management
 *    void  sys_free_string(char* str)
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/utsname.h>
#include <sys/statvfs.h>
#include <sys/sysinfo.h>
#include <pwd.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>

/* ── visibility macro ─────────────────────────────────────────────────────── */
#define EXPORT __attribute__((visibility("default"))) __attribute__((used))

/* ── helper: run command and capture stdout into a malloc'd string ─────────── */
static char* _run_cmd(const char* cmd) {
    FILE* fp = popen(cmd, "r");
    if (!fp) return NULL;

    size_t cap = 4096, len = 0;
    char* buf = malloc(cap);
    if (!buf) { pclose(fp); return NULL; }

    int c;
    while ((c = fgetc(fp)) != EOF) {
        if (len + 1 >= cap) {
            cap *= 2;
            char* tmp = realloc(buf, cap);
            if (!tmp) { free(buf); pclose(fp); return NULL; }
            buf = tmp;
        }
        buf[len++] = (char)c;
    }
    buf[len] = '\0';
    pclose(fp);
    return buf;
}

/* ── helper: strip trailing newline ──────────────────────────────────────── */
static char* _strip_newline(char* s) {
    if (!s) return s;
    size_t l = strlen(s);
    while (l > 0 && (s[l-1] == '\n' || s[l-1] == '\r')) s[--l] = '\0';
    return s;
}

/* ═══════════════════════════════════════════════════════════════════════════
   SYSTEM INFO
   ═══════════════════════════════════════════════════════════════════════════ */

EXPORT char* sys_get_hostname(void) {
    char buf[256] = {0};
    if (gethostname(buf, sizeof(buf) - 1) == 0) return strdup(buf);
    return strdup("Unknown");
}

EXPORT char* sys_get_kernel_version(void) {
    struct utsname u;
    if (uname(&u) == 0) return strdup(u.release);
    return strdup("Unknown");
}

EXPORT char* sys_get_os_name(void) {
    /* Try /etc/os-release PRETTY_NAME first */
    FILE* f = fopen("/etc/os-release", "r");
    if (f) {
        char line[512];
        while (fgets(line, sizeof(line), f)) {
            if (strncmp(line, "PRETTY_NAME=", 12) == 0) {
                fclose(f);
                char* v = line + 12;
                /* remove quotes and newline */
                size_t l = strlen(v);
                while (l > 0 && (v[l-1] == '\n' || v[l-1] == '"' || v[l-1] == '\r')) v[--l] = '\0';
                if (v[0] == '"') v++;
                return strdup(v);
            }
        }
        fclose(f);
    }
    /* fallback: lsb_release */
    char* out = _run_cmd("lsb_release -d -s 2>/dev/null");
    if (out) { _strip_newline(out); return out; }
    return strdup("Linux");
}

EXPORT char* sys_get_cpu_info(void) {
    FILE* f = fopen("/proc/cpuinfo", "r");
    if (f) {
        char line[512];
        while (fgets(line, sizeof(line), f)) {
            if (strncmp(line, "model name", 10) == 0) {
                fclose(f);
                char* colon = strchr(line, ':');
                if (colon) {
                    colon++;
                    while (*colon == ' ' || *colon == '\t') colon++;
                    char* res = strdup(colon);
                    _strip_newline(res);
                    return res;
                }
            }
        }
        fclose(f);
    }
    return strdup("Unknown");
}

EXPORT char* sys_get_total_memory(void) {
    struct sysinfo si;
    if (sysinfo(&si) == 0) {
        unsigned long total_mb = (si.totalram * (unsigned long)si.mem_unit) / (1024 * 1024);
        char buf[64];
        if (total_mb >= 1024)
            snprintf(buf, sizeof(buf), "%.1f GiB", total_mb / 1024.0);
        else
            snprintf(buf, sizeof(buf), "%lu MiB", total_mb);
        return strdup(buf);
    }
    return strdup("Unknown");
}

EXPORT char* sys_get_disk_info(void) {
    struct statvfs sv;
    if (statvfs("/", &sv) == 0) {
        unsigned long long total = (unsigned long long)sv.f_blocks * sv.f_frsize;
        unsigned long long avail = (unsigned long long)sv.f_bavail * sv.f_frsize;
        char buf[128];
        double total_gb = total / (1024.0 * 1024.0 * 1024.0);
        double avail_gb = avail / (1024.0 * 1024.0 * 1024.0);
        snprintf(buf, sizeof(buf), "%.1f GB total, %.1f GB available", total_gb, avail_gb);
        return strdup(buf);
    }
    return strdup("Unknown");
}

/* ═══════════════════════════════════════════════════════════════════════════
   LOCALE / LANGUAGE
   ═══════════════════════════════════════════════════════════════════════════ */

EXPORT char* sys_get_locale(void) {
    /* 1. LANG env var */
    const char* lang = getenv("LANG");
    if (lang && *lang) return strdup(lang);

    /* 2. /etc/locale.conf */
    FILE* f = fopen("/etc/locale.conf", "r");
    if (f) {
        char line[256];
        while (fgets(line, sizeof(line), f)) {
            if (strncmp(line, "LANG=", 5) == 0) {
                fclose(f);
                char* v = line + 5;
                _strip_newline(v);
                return strdup(v);
            }
        }
        fclose(f);
    }

    /* 3. /etc/default/locale */
    f = fopen("/etc/default/locale", "r");
    if (f) {
        char line[256];
        while (fgets(line, sizeof(line), f)) {
            if (strncmp(line, "LANG=", 5) == 0) {
                fclose(f);
                char* v = line + 5;
                _strip_newline(v);
                /* strip quotes */
                if (v[0] == '"') v++;
                size_t l = strlen(v);
                if (l > 0 && v[l-1] == '"') v[l-1] = '\0';
                return strdup(v);
            }
        }
        fclose(f);
    }

    return strdup("en_US.UTF-8");
}

/* ═══════════════════════════════════════════════════════════════════════════
   DATE & TIME
   ═══════════════════════════════════════════════════════════════════════════ */

EXPORT char* sys_get_timezone(void) {
    /* Read /etc/localtime symlink target */
    char buf[512] = {0};
    ssize_t len = readlink("/etc/localtime", buf, sizeof(buf) - 1);
    if (len > 0) {
        buf[len] = '\0';
        /* Extract "America/New_York" from ".../zoneinfo/America/New_York" */
        const char* zi = strstr(buf, "zoneinfo/");
        if (zi) return strdup(zi + 9);
    }

    /* Fallback: timedatectl show */
    char* out = _run_cmd("timedatectl show --property=Timezone --value 2>/dev/null");
    if (out) { _strip_newline(out); if (out[0]) return out; free(out); }

    /* /etc/timezone */
    FILE* f = fopen("/etc/timezone", "r");
    if (f) {
        char line[256] = {0};
        if (fgets(line, sizeof(line), f)) {
            fclose(f);
            _strip_newline(line);
            if (line[0]) return strdup(line);
        } else fclose(f);
    }

    return strdup("UTC");
}

EXPORT int sys_get_ntp_enabled(void) {
    char* out = _run_cmd("timedatectl show --property=NTP --value 2>/dev/null");
    if (!out) return 1;
    int enabled = (strncmp(out, "yes", 3) == 0);
    free(out);
    return enabled;
}

EXPORT int sys_set_ntp(int enabled) {
    char cmd[128];
    snprintf(cmd, sizeof(cmd), "timedatectl set-ntp %s 2>/dev/null", enabled ? "true" : "false");
    int rc = system(cmd);
    return (rc == 0) ? 1 : 0;
}

EXPORT int sys_set_timezone(const char* tz) {
    if (!tz || !*tz) return 0;
    char cmd[512];
    /* Try without sudo first (polkit-enabled timedatectl), then with sudo */
    snprintf(cmd, sizeof(cmd),
             "timedatectl set-timezone '%s' 2>/dev/null || "
             "sudo timedatectl set-timezone '%s' 2>/dev/null", tz, tz);
    int rc = system(cmd);
    return (rc == 0) ? 1 : 0;
}

/*
 * Returns a '\n'-delimited list of all IANA timezones from /usr/share/zoneinfo.
 * The caller owns the returned string and must free it with sys_free_string().
 */
EXPORT char* sys_list_timezones(void) {
    char* out = _run_cmd(
        "find /usr/share/zoneinfo -type f -not -name '*.list' -not -name 'leap-seconds.list' "
        "2>/dev/null | sed 's|.*/zoneinfo/||' | grep -E '^[A-Z][a-zA-Z_+/-]+/[A-Z]' | sort -u"
    );
    if (out && out[0]) return out;
    if (out) free(out);
    /* Fallback: timedatectl */
    return _run_cmd("timedatectl list-timezones 2>/dev/null");
}

/* ═══════════════════════════════════════════════════════════════════════════
   USERS  (reads /etc/passwd directly via POSIX getpwent)
   ═══════════════════════════════════════════════════════════════════════════ */

/*
 * Returns a '\n'-delimited list of records, each record being:
 *   username\tuid\thome
 * Only normal users (UID >= 1000) with interactive shells are included.
 */
EXPORT char* sys_get_users(void) {
    size_t cap = 4096, len = 0;
    char* buf = malloc(cap);
    if (!buf) return strdup("");

    setpwent();
    struct passwd* pw;
    while ((pw = getpwent()) != NULL) {
        if (pw->pw_uid < 1000) continue;
        const char* sh = pw->pw_shell ? pw->pw_shell : "";
        if (!strstr(sh, "bash") && !strstr(sh, "zsh") && !strstr(sh, "fish")) continue;

        char entry[1024];
        int n = snprintf(entry, sizeof(entry), "%s\t%u\t%s\n",
                         pw->pw_name,
                         (unsigned)pw->pw_uid,
                         pw->pw_dir ? pw->pw_dir : "");

        if (n > 0 && (size_t)n + len + 1 >= cap) {
            cap = (cap + (size_t)n + 1) * 2;
            char* tmp = realloc(buf, cap);
            if (!tmp) { free(buf); endpwent(); return strdup(""); }
            buf = tmp;
        }
        if (n > 0) { memcpy(buf + len, entry, (size_t)n); len += (size_t)n; }
    }
    endpwent();
    buf[len] = '\0';
    return buf;
}

/* ═══════════════════════════════════════════════════════════════════════════
   SSH
   ═══════════════════════════════════════════════════════════════════════════ */

static int _systemctl_is_active(const char* service) {
    char cmd[256];
    snprintf(cmd, sizeof(cmd), "systemctl is-active --quiet '%s' 2>/dev/null", service);
    return (system(cmd) == 0) ? 1 : 0;
}

EXPORT int sys_is_ssh_enabled(void) {
    if (_systemctl_is_active("ssh"))  return 1;
    if (_systemctl_is_active("sshd")) return 1;
    return 0;
}

EXPORT int sys_set_ssh_enabled(int enabled) {
    /* Try "ssh" first, fallback to "sshd" */
    const char* services[] = {"ssh", "sshd"};
    for (int i = 0; i < 2; i++) {
        char cmd[512];
        if (enabled) {
            snprintf(cmd, sizeof(cmd),
                     "sudo systemctl enable --now '%s' 2>/dev/null", services[i]);
        } else {
            snprintf(cmd, sizeof(cmd),
                     "sudo systemctl disable --now '%s' 2>/dev/null", services[i]);
        }
        if (system(cmd) == 0) return 1;
    }
    return 0;
}

EXPORT char* sys_get_ssh_info(void) {
    char hostname[256] = {0};
    gethostname(hostname, sizeof(hostname) - 1);

    /* Collect non-loopback IPv4 addresses */
    char ips[512] = {0};
    struct ifaddrs *ifap, *ifa;
    if (getifaddrs(&ifap) == 0) {
        for (ifa = ifap; ifa; ifa = ifa->ifa_next) {
            if (!ifa->ifa_addr) continue;
            if (ifa->ifa_addr->sa_family != AF_INET) continue;
            if (ifa->ifa_flags & IFF_LOOPBACK) continue;
            struct sockaddr_in* sa = (struct sockaddr_in*)ifa->ifa_addr;
            char ip[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, &sa->sin_addr, ip, sizeof(ip));
            if (ips[0]) strncat(ips, ", ", sizeof(ips) - strlen(ips) - 1);
            strncat(ips, ip, sizeof(ips) - strlen(ips) - 1);
        }
        freeifaddrs(ifap);
    }

    char buf[1280];
    if (ips[0])
        snprintf(buf, sizeof(buf), "SSH is enabled\nConnect using: ssh %s@%s", hostname, ips);
    else
        snprintf(buf, sizeof(buf), "SSH is enabled\nHostname: %s", hostname);
    return strdup(buf);
}

/* ═══════════════════════════════════════════════════════════════════════════
   REMOTE DESKTOP  (vino-server via systemctl --user)
   ═══════════════════════════════════════════════════════════════════════════ */

EXPORT int sys_is_remote_desktop_enabled(void) {
    int rc = system("systemctl --user is-active --quiet vino-server 2>/dev/null");
    return (rc == 0) ? 1 : 0;
}

EXPORT int sys_set_remote_desktop_enabled(int enabled) {
    char cmd[256];
    if (enabled) {
        snprintf(cmd, sizeof(cmd),
                 "systemctl --user enable --now vino-server 2>/dev/null");
    } else {
        snprintf(cmd, sizeof(cmd),
                 "systemctl --user disable --now vino-server 2>/dev/null");
    }
    return (system(cmd) == 0) ? 1 : 0;
}

/* ═══════════════════════════════════════════════════════════════════════════
   GENERIC PRIVILEGED SHELL COMMAND
   ═══════════════════════════════════════════════════════════════════════════ */

/*
 * Runs an arbitrary shell command via system(3).
 * Returns the exit code (0 = success).
 * The command string is caller-owned and NOT freed here.
 */
EXPORT int sys_run_shell_command(const char* cmd) {
    if (!cmd || !*cmd) return -1;
    return system(cmd);
}

/* ═══════════════════════════════════════════════════════════════════════════
   MEMORY MANAGEMENT
   ═══════════════════════════════════════════════════════════════════════════ */

EXPORT void sys_free_string(char* str) {
    free(str);
}
