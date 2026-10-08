import 'package:flutter/material.dart';
import '../theme/evently_theme.dart';

class EventlyTextField extends StatefulWidget {
  const EventlyTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.password = false,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.textInputAction,
  });
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final bool password;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final TextInputAction? textInputAction;

  @override
  State<EventlyTextField> createState() => _EventlyTextFieldState();
}

class _EventlyTextFieldState extends State<EventlyTextField> {
  bool hidden = true;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    keyboardType: widget.keyboardType,
    maxLines: widget.maxLines,
    obscureText: widget.password && hidden,
    validator: widget.validator,
    style: const TextStyle(fontSize: 13),
    textInputAction: widget.textInputAction ?? (widget.maxLines > 1
        ? TextInputAction.newline : TextInputAction.next),
    decoration: InputDecoration(
      hintText: widget.hint,
      prefixIcon: widget.icon == null ? null : Icon(widget.icon, size: 21),
      suffixIcon: widget.password ? IconButton(
        onPressed: () => setState(() => hidden = !hidden),
        icon: Icon(hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
      ) : null,
      alignLabelWithHint: widget.maxLines > 1,
    ),
  );
}

class EventlyActionButton extends StatelessWidget {
  const EventlyActionButton({super.key, required this.label,
    required this.onPressed, this.loading = false});
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 46,
    child: ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white))
          : Text(label),
    ),
  );
}

class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.title, this.actions = const []});
  final String title;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 55,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        SizedBox.square(dimension: 32, child: Material(
          color: EventlyColors.isDark(context)
              ? EventlyColors.navy : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
            side: BorderSide(color: EventlyColors.outline(context)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(7),
            onTap: () => Navigator.maybePop(context),
            child: Icon(Icons.arrow_back_ios_new, size: 16,
                color: EventlyColors.primary(context)),
          ),
        )),
        Expanded(child: Text(title, textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
        if (actions.isEmpty)
          const SizedBox(width: 32)
        else
          SizedBox(width: actions.length * 36, child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions.map((action) => SizedBox(width: 36, child: action)).toList(),
          )),
      ]),
    ),
  );
}

class EmptyEvents extends StatelessWidget {
  const EmptyEvents({super.key, this.message = 'No events yet', this.action});
  final String message;
  final VoidCallback? action;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.event_note_outlined, color: EventlyColors.primary(context), size: 55),
        const SizedBox(height: 14),
        Text(message, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        if (action != null) ...[
          const SizedBox(height: 16),
          TextButton.icon(onPressed: action, icon: const Icon(Icons.add),
              label: const Text('Create an event')),
        ],
      ]),
    ),
  );
}
