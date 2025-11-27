import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FocusDialog extends StatelessWidget {
  const FocusDialog({
    super.key,
    required this.child,
    required this.onClose,
  });

  final Widget child;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).pop();
          onClose();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                onClose();
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              elevation: 16.0,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
