import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vendervpn/core/res/styles/colors.dart';

/// A titled card that groups related editor fields.
class EditorSection extends StatelessWidget {
  const EditorSection({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      decoration: BoxDecoration(
        color: Colours.cardSurface(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colours.subtleBorder(context)),
        boxShadow: Colours.softCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Colours.subtitleGrey,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class EditorChip extends StatelessWidget {
  const EditorChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colours.softChipBg(context),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colours.orbViolet,
        ),
      ),
    );
  }
}

InputDecoration _decoration(
  BuildContext context, {
  required String label,
  String? hint,
  Widget? suffix,
}) {
  OutlineInputBorder border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color),
  );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    isDense: true,
    filled: true,
    fillColor: Colours.softChipBg(context),
    suffixIcon: suffix,
    labelStyle: const TextStyle(fontSize: 13, color: Colours.subtitleGrey),
    hintStyle: TextStyle(
      fontSize: 13,
      color: Colours.subtitleGrey.withValues(alpha: 0.6),
    ),
    border: border(Colours.subtleBorder(context)),
    enabledBorder: border(Colours.subtleBorder(context)),
    focusedBorder: border(Colours.orbViolet),
  );
}

/// A text field that keeps its own text; [fieldKey] must be unique per field.
class EditorTextField extends StatelessWidget {
  const EditorTextField({
    super.key,
    required this.fieldKey,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.suffix,
  });

  final String fieldKey;
  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        key: ValueKey('editor-$fieldKey'),
        initialValue: initialValue,
        onChanged: onChanged,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        autocorrect: false,
        enableSuggestions: false,
        style: TextStyle(
          fontSize: 14,
          color: Colours.classicAdabtiveTextColor(context),
        ),
        decoration: _decoration(
          context,
          label: label,
          hint: hint,
          suffix: suffix,
        ),
      ),
    );
  }
}

/// A dropdown over [options]; the current [value] is always offered, even
/// when it isn't one of the presets. An empty string reads as "Default".
class EditorDropdown extends StatelessWidget {
  const EditorDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [...options, if (!options.contains(value)) value];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        key: ValueKey('editor-dd-$label-$value'),
        initialValue: value,
        isExpanded: true,
        borderRadius: BorderRadius.circular(14),
        dropdownColor: Colours.cardSurface(context),
        style: TextStyle(
          fontSize: 14,
          color: Colours.classicAdabtiveTextColor(context),
        ),
        decoration: _decoration(context, label: label),
        items: [
          for (final item in items)
            DropdownMenuItem(
              value: item,
              child: Text(item.isEmpty ? 'Default' : item),
            ),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

/// Full-screen message for when the editor can't open a node.
class EditorMessage extends StatelessWidget {
  const EditorMessage({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colours.pastelRoseFg),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colours.subtitleGrey),
            ),
          ],
        ),
      ),
    );
  }
}
