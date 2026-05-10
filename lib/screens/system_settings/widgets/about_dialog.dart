import 'dart:io';
import 'package:flutter/material.dart';

class SystemAboutDialog extends StatefulWidget {
  const SystemAboutDialog({super.key});

  @override
  State<SystemAboutDialog> createState() => _SystemAboutDialogState();
}

class _SystemAboutDialogState extends State<SystemAboutDialog> {
  String _hostname = 'Unknown';
  String _osVersion = 'Unknown';
  String _kernel = 'Unknown';
  String _cpu = 'Unknown';
  String _memory = 'Unknown';
  String _disk = 'Unknown';

  @override
  void initState() {
    super.initState();
    _loadSystemInfo();
  }

  Future<void> _loadSystemInfo() async {
    try {
      
      final hostnameResult = await Process.run('hostname', []);
      if (hostnameResult.exitCode == 0) {
        setState(() => _hostname = hostnameResult.stdout.toString().trim());
      }

      
      final osResult = await Process.run('lsb_release', ['-d']);
      if (osResult.exitCode == 0) {
        setState(
          () => _osVersion = osResult.stdout.toString().split(':')[1].trim(),
        );
      } else {
        
        final osRelease = await Process.run('cat', ['/etc/os-release']);
        if (osRelease.exitCode == 0) {
          final lines = osRelease.stdout.toString().split('\n');
          for (final line in lines) {
            if (line.startsWith('PRETTY_NAME=')) {
              setState(
                () => _osVersion = line.split('=')[1].replaceAll('"', ''),
              );
              break;
            }
          }
        }
      }

      
      final kernelResult = await Process.run('uname', ['-r']);
      if (kernelResult.exitCode == 0) {
        setState(() => _kernel = kernelResult.stdout.toString().trim());
      }

      
      final cpuResult = await Process.run('lscpu', []);
      if (cpuResult.exitCode == 0) {
        final lines = cpuResult.stdout.toString().split('\n');
        for (final line in lines) {
          if (line.startsWith('Model name:')) {
            setState(() => _cpu = line.split(':')[1].trim());
            break;
          }
        }
      }

      
      final memResult = await Process.run('free', ['-h']);
      if (memResult.exitCode == 0) {
        final lines = memResult.stdout.toString().split('\n');
        if (lines.length > 1) {
          final memLine = lines[1].split(RegExp(r'\s+'));
          if (memLine.length > 1) {
            setState(() => _memory = '${memLine[1]} total');
          }
        }
      }

      
      final diskResult = await Process.run('df', ['-h', '/']);
      if (diskResult.exitCode == 0) {
        final lines = diskResult.stdout.toString().split('\n');
        if (lines.length > 1) {
          final diskLine = lines[1].split(RegExp(r'\s+'));
          if (diskLine.length > 2) {
            setState(
              () => _disk = '${diskLine[1]} total, ${diskLine[3]} available',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Load system info error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 18, 22, 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow('Hostname', _hostname),
            const SizedBox(height: 12),
            _buildInfoRow('OS Version', _osVersion),
            const SizedBox(height: 12),
            _buildInfoRow('Kernel', _kernel),
            const SizedBox(height: 12),
            _buildInfoRow('CPU', _cpu),
            const SizedBox(height: 12),
            _buildInfoRow('Memory', _memory),
            const SizedBox(height: 12),
            _buildInfoRow('Disk', _disk),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
