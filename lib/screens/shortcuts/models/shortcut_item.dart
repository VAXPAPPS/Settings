class ShortcutItem {
  String id;
  String modifier;
  String key;
  String command;

  ShortcutItem({
    required this.id,
    required this.modifier,
    required this.key,
    required this.command,
  });

  static Map<String, String> parseWayfireBinding(String binding) {
    String mod = 'None';

    final hasSuper = binding.contains('<super>');
    final hasCtrl = binding.contains('<ctrl>');
    final hasAlt = binding.contains('<alt>');
    final hasShift = binding.contains('<shift>');

    if (hasCtrl && hasAlt) {
      mod = 'Ctrl+Alt';
    } else if (hasCtrl && hasShift) {
      mod = 'Ctrl+Shift';
    } else if (hasSuper && hasShift) {
      mod = 'Super+Shift';
    } else if (hasSuper) {
      mod = 'Super';
    } else if (hasCtrl) {
      mod = 'Ctrl';
    } else if (hasAlt) {
      mod = 'Alt';
    } else if (hasShift) {
      mod = 'Shift';
    }

    String k = binding
        .replaceAll('<super>', '')
        .replaceAll('<ctrl>', '')
        .replaceAll('<alt>', '')
        .replaceAll('<shift>', '')
        .trim();

    // Optionally strip 'KEY_' for cleaner UI
    if (k.startsWith('KEY_')) {
      k = k.substring(4);
    }

    return {'modifier': mod, 'key': k};
  }

  String toWayfireBinding() {
    String wfMod = '';
    switch (modifier) {
      case 'Ctrl': wfMod = '<ctrl> '; break;
      case 'Alt': wfMod = '<alt> '; break;
      case 'Shift': wfMod = '<shift> '; break;
      case 'Super': wfMod = '<super> '; break;
      case 'Ctrl+Alt': wfMod = '<ctrl> <alt> '; break;
      case 'Ctrl+Shift': wfMod = '<ctrl> <shift> '; break;
      case 'Super+Shift': wfMod = '<super> <shift> '; break;
      case 'None':
      default:
        break;
    }
    
    String formattedKey = key.trim();
    if (formattedKey.isNotEmpty && !formattedKey.startsWith('KEY_') && !formattedKey.startsWith('BTN_')) {
      formattedKey = 'KEY_${formattedKey.toUpperCase()}';
    }

    return '$wfMod$formattedKey'.trim();
  }

  // Not used for wayfire, but keeping if required elsewhere, or we can drop it.
  String toCsvLine() => '$modifier,$key,$command';
}
