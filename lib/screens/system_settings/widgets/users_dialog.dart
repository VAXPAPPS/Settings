import 'dart:io';
import 'package:flutter/material.dart';

class UsersDialog extends StatefulWidget {
  const UsersDialog({super.key});

  @override
  State<UsersDialog> createState() => _UsersDialogState();
}

class _UsersDialogState extends State<UsersDialog> {
  List<Map<String, String>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final result = await Process.run('getent', ['passwd']);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().split('\n');
        final List<Map<String, String>> users = [];

        for (final line in lines) {
          final parts = line.split(':');
          if (parts.length >= 7) {
            final username = parts[0];
            final uid = parts[2];
            final home = parts[5];
            final shell = parts[6];

            
            final uidInt = int.tryParse(uid) ?? 0;
            if (uidInt >= 1000 &&
                (shell.contains('bash') ||
                    shell.contains('zsh') ||
                    shell.contains('fish'))) {
              users.add({'username': username, 'uid': uid, 'home': home});
            }
          }
        }

        setState(() => _users = users);
      }
    } catch (e) {
      debugPrint('Load users error: $e');
    }
  }

  Future<void> _changePassword(String username) async {
    
    final adminPassword = await _showPasswordDialog(
      title: 'Enter Administrator Password',
      hint: 'Password',
    );

    if (adminPassword == null || adminPassword.isEmpty) {
      return;
    }

    
    final newPassword = await _showPasswordDialog(
      title: 'Enter New Password for $username',
      hint: 'New Password',
      confirm: true,
    );

    if (newPassword == null || newPassword.isEmpty) {
      return;
    }

    try {
      
      
      final passwordLine = '$username:$newPassword';

      
      
      final result = await Process.run('bash', [
        '-c',
        r'printf "%s\n" "$1" | sudo -S bash -c "printf \"%s\n\" \"$2\" | chpasswd"',
        '--',
        adminPassword,
        passwordLine,
      ]);

      if (result.exitCode == 0) {
        if (mounted) {
          // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password changed successfully for $username'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to change password: ${result.stderr}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _createNewUser() async {
    
    final adminPassword = await _showPasswordDialog(
      title: 'Enter Administrator Password',
      hint: 'Password',
    );

    if (adminPassword == null || adminPassword.isEmpty) {
      return;
    }

    
    final username = await _showTextInputDialog(
      title: 'Create New User',
      hint: 'Username',
    );

    if (username == null || username.isEmpty) {
      return;
    }

    
    final password = await _showPasswordDialog(
      title: 'Enter Password for $username',
      hint: 'Password',
      confirm: true,
    );

    if (password == null || password.isEmpty) {
      return;
    }

    try {
      
      final createResult = await Process.run('bash', [
        '-c',
        r'printf "%s\n" "$1" | sudo -S useradd -m -s /bin/bash "$2"',
        '--',
        adminPassword,
        username,
      ]);

      if (createResult.exitCode != 0) {
        if (mounted) {
          // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create user: ${createResult.stderr}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      
      final passwordLine = '$username:$password';
      final passwdResult = await Process.run('bash', [
        '-c',
        r'printf "%s\n" "$1" | sudo -S bash -c "printf \"%s\n\" \"$2\" | chpasswd"',
        '--',
        adminPassword,
        passwordLine,
      ]);

      if (passwdResult.exitCode == 0) {
        if (mounted) {
          // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User $username created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          await _loadUsers();
        }
      } else {
        if (mounted) {
          // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'User created but password setting failed: ${passwdResult.stderr}',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          await _loadUsers();
        }
      }
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

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
          backgroundColor: const Color.fromARGB(255, 18, 22, 32),
          surfaceTintColor: Colors.transparent,
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: StatefulBuilder(
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
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white54,
                      ),
                      onPressed: () =>
                          setState(() => obscureText = !obscureText),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
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
                      hintStyle: const TextStyle(color: Colors.white54),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirmText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white54,
                        ),
                        onPressed: () => setState(
                          () => obscureConfirmText = !obscureConfirmText,
                        ),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => // ignore: use_build_context_synchronously
      Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () {
                if (confirm && password != confirmPassword) {
                  // ignore: use_build_context_synchronously
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
          backgroundColor: const Color.fromARGB(255, 18, 22, 32),
          surfaceTintColor: Colors.transparent,
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: TextField(
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
          actions: [
            TextButton(
              onPressed: () => // ignore: use_build_context_synchronously
      Navigator.pop(context),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 18, 22, 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 500,
        height: 500,
        padding: const EdgeInsets.all(24),
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
              child: _users.isEmpty
                  ? Center(
                      child: Text(
                        'No users found',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
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
                  onPressed: () => // ignore: use_build_context_synchronously
      Navigator.pop(context),
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
    );
  }
}
