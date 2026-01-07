import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenB extends StatefulWidget {
  final Map<String, dynamic>? data;
  const ScreenB({super.key, this.data});

  @override
  State<ScreenB> createState() => _ScreenBState();
}

class _ScreenBState extends State<ScreenB> {
  List<Map<String, String>> records = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString('records');
    if (recordsJson != null) {
      final List<dynamic> decoded = jsonDecode(recordsJson);
      setState(() {
        records = decoded.map((e) => Map<String, String>.from(e)).toList();
      });
    }
  }

  Future<void> _deleteRecord(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      records.removeAt(index);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('records', jsonEncode(records));
      setState(() {});
    }
  }

  List<TextSpan> formatText(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'#\w+');
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
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen B"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: records.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_add_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No content yet",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Create your first phrase with hashtags",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        final phrase = record['phrase'] ?? '';
                        final hashtags = record['hashtags'] ?? '';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Record ${index + 1}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            await context
                                                .push("/a/b/c", extra: {
                                              "index": index,
                                              "phrase": phrase,
                                              "hashtags": hashtags,
                                            });
                                            _loadData();
                                          },
                                          icon: const Icon(Icons.edit, size: 20),
                                          tooltip: "Edit",
                                          style: IconButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed: () => _deleteRecord(index),
                                          icon: const Icon(Icons.delete,
                                              size: 20),
                                          tooltip: "Delete",
                                          style: IconButton.styleFrom(
                                            backgroundColor:
                                                Colors.red.shade50,
                                            foregroundColor: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(),
                                const SizedBox(height: 8),
                                Text(
                                  "Phrase",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 4),
                                RichText(
                                  text: TextSpan(
                                    children: formatText(phrase),
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Hashtags",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: hashtags
                                      .split(' ')
                                      .where((tag) => tag.startsWith('#'))
                                      .map((tag) => Chip(
                                            label: Text(
                                              tag,
                                              style: const TextStyle(
                                                color: Colors.indigo,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            backgroundColor:
                                                Colors.indigo.shade50,
                                            padding: EdgeInsets.zero,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await context.push("/a/b/c");
                    _loadData();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add New"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
