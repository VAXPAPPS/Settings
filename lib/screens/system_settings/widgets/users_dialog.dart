import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:settings/features/system_settings/services/system_service.dart';

class UsersDialog extends StatefulWidget {
  const UsersDialog({super.key});

  @override
  State<UsersDialog> createState() => _UsersDialogState();
}

class _UsersDialogState extends State<UsersDialog> {
  final _service = SystemService();
  List<Map<String, String>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _service.getUsers();
      if (!mounted) return;
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Load users error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Password change ────────────────────────────────────────────────────────

  Future<void> _changePassword(String username) async {
    final adminPassword = await _showPasswordDialog(
      title: 'Enter Administrator Password',
      hint: 'Password',
    );
    if (adminPassword == null || adminPassword.isEmpty) return;

    final newPassword = await _showPasswordDialog(
      title: 'Enter New Password for $username',
      hint: 'New Password',
      confirm: true,
    );
    if (newPassword == null || newPassword.isEmpty) return;

    final passwordLine = '$username:$newPassword';
    // Build the sudo chpasswd command entirely in Dart; it is executed via
    // the native system() call inside sys_run_shell_command() — no dart:io.
    // We escape the password fields to avoid shell injection.
    final escapedAdmin = adminPassword.replaceAll("'", r"'\''");
    final escapedPasswd = passwordLine.replaceAll("'", r"'\''");
    final chpasswdCmd =
        "printf '%s\\n' '$escapedAdmin' | sudo -S bash -c "
        "\"printf '%s\\n' '$escapedPasswd' | chpasswd\"";

    try {
      final result = await _runPrivilegedCommand(chpasswdCmd);

      if (!mounted) return;
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password changed successfully for $username'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to change password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ── Create new user ────────────────────────────────────────────────────────

  Future<void> _createNewUser() async {
    final adminPassword = await _showPasswordDialog(
      title: 'Enter Administrator Password',
      hint: 'Password',
    );
    if (adminPassword == null || adminPassword.isEmpty) return;

    final username = await _showTextInputDialog(
      title: 'Create New User',
      hint: 'Username',
    );
    if (username == null || username.isEmpty) return;

    final password = await _showPasswordDialog(
      title: 'Enter Password for $username',
      hint: 'Password',
      confirm: true,
    );
    if (password == null || password.isEmpty) return;

    try {
      final escapedAdmin = adminPassword.replaceAll("'", r"'\''");
      final escapedUser = username.replaceAll("'", r"'\''");
      final createCmd =
          "printf '%s\\n' '$escapedAdmin' | sudo -S useradd -m -s /bin/bash '$escapedUser'";

      final created = await _runPrivilegedCommand(createCmd);

      if (!mounted) return;
      if (!created) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create user'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final passwordLine = '$username:$password';
      final escapedPasswd = passwordLine.replaceAll("'", r"'\''");
      final setPassCmd =
          "printf '%s\\n' '$escapedAdmin' | sudo -S bash -c "
          "\"printf '%s\\n' '$escapedPasswd' | chpasswd\"";

      await _runPrivilegedCommand(setPassCmd);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User $username created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// Runs a privileged shell command via the native system() C function.
  /// Returns true on success (exit code 0).
  Future<bool> _runPrivilegedCommand(String cmd) async {
    final rc = await _service.runShellCommand(cmd);
    return rc == 0;
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  Future<String?> _showPasswordDialog({
    required String title,
    required String hint,
    bool confirm = false,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        String? password;
        String? confirmPassword;
        bool obscureText = true;
        bool obscureConfirmText = true;

        return AlertDialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(100, 0, 0, 0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    StatefulBuilder(
                      builder: (context, setState) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            onChanged: (value) => password = value,
                            obscureText: obscureText,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: hint,
                              hintStyle: const TextStyle(color: Colors.white54),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white54,
                                ),
                                onPressed: () =>
                                    setState(() => obscureText = !obscureText),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ),
                          if (confirm) ...[
                            const SizedBox(height: 16),
                            TextField(
                              onChanged: (value) => confirmPassword = value,
                              obscureText: obscureConfirmText,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                hintStyle: const TextStyle(
                                  color: Colors.white54,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureConfirmText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () => setState(
                                    () => obscureConfirmText =
                                        !obscureConfirmText,
                                  ),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white24),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (confirm && password != confirmPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Passwords do not match'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            Navigator.pop(context, password);
                          },
                          child: const Text(
                            'OK',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String?> _showTextInputDialog({
    required String title,
    required String hint,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        String? value;

        return AlertDialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(100, 0, 0, 0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (v) => value = v,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, value),
                          child: const Text(
                            'OK',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 500,
            height: 500,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color.fromARGB(100, 0, 0, 0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Users',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _users.isEmpty
                      ? Center(
                          child: Text(
                            'No users found',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 156, 39, 176),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  user['username'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  'UID: ${user['uid']}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white70,
                                  ),
                                  color: const Color.fromARGB(255, 45, 45, 45),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'password',
                                      child: Text(
                                        'Change Password',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'password') {
                                      _changePassword(user['username'] ?? '');
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _createNewUser,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Create User'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
