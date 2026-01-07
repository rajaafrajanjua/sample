import 'package:flutter/material.dart';

class HashtagTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Function(String) onChanged;

  const HashtagTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, __, ___) {
              String text = controller.text;

              List<TextSpan> spans = [];
              RegExp regex = RegExp(r'#\w+');
              int start = 0;

              for (final match in regex.allMatches(text)) {
                if (match.start > start) {
                  spans.add(TextSpan(text: text.substring(start, match.start)));
                }

                spans.add(TextSpan(
                  text: match.group(0),
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ));

                start = match.end;
              }

              if (start < text.length) {
                spans.add(TextSpan(text: text.substring(start)));
              }

              return IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: RichText(
                    text: TextSpan(
                      children: spans,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          TextField(
            controller: controller,
            maxLines: null,
            minLines: 3,
            decoration: InputDecoration(
              hintText: label,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              filled: false,
            ),
            style: const TextStyle(
              color: Colors.transparent,
              fontSize: 16,
              height: 1.5,
            ),
            cursorColor: Colors.indigo,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
