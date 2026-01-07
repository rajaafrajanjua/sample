import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/hashtag_textfield.dart';

class ScreenC extends StatefulWidget {
  const ScreenC({super.key});

  @override
  State<ScreenC> createState() => _ScreenCState();
}

class _ScreenCState extends State<ScreenC> {
  final phraseCtrl = TextEditingController();
  final hashtagCtrl = TextEditingController();

  final Set<String> hashtagSet = {};
  final RegExp regex = RegExp(r'#\w+');
  bool isEditing = false;
  int? editIndex;

  void updateFromPhrase(String text) {
    final phraseMatches = regex.allMatches(text);

    for (var match in phraseMatches) {
      hashtagSet.add(match.group(0)!);
    }

    final manualMatches = regex.allMatches(hashtagCtrl.text);
    for (var match in manualMatches) {
      hashtagSet.add(match.group(0)!);
    }

    hashtagCtrl.text = hashtagSet.join(" ");
  }

  void updateFromHashtagField(String text) {
    final matches = regex.allMatches(text);
    for (var m in matches) {
      hashtagSet.add(m.group(0)!);
    }
  }

  @override
  void initState() {
    super.initState();
    phraseCtrl.addListener(() => updateFromPhrase(phraseCtrl.text));
    hashtagCtrl.addListener(() => updateFromHashtagField(hashtagCtrl.text));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEditData();
    });
  }

  void _loadEditData() {
    final data = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (data != null && data.containsKey('index')) {
      isEditing = true;
      editIndex = data["index"] as int;
      phraseCtrl.text = data["phrase"] ?? "";
      hashtagCtrl.text = data["hashtags"] ?? "";

      final matches = regex.allMatches(hashtagCtrl.text);
      for (var m in matches) {
        hashtagSet.add(m.group(0)!);
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    phraseCtrl.dispose();
    hashtagCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAndSubmit() async {
    if (phraseCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a phrase"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Collect hashtags from both phrase and hashtag field
    final allHashtags = <String>{};
    
    // From phrase
    for (var match in regex.allMatches(phraseCtrl.text)) {
      allHashtags.add(match.group(0)!);
    }
    
    // From hashtag field
    for (var match in regex.allMatches(hashtagCtrl.text)) {
      allHashtags.add(match.group(0)!);
    }

    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString('records');
    List<Map<String, String>> records = [];

    if (recordsJson != null) {
      final List<dynamic> decoded = jsonDecode(recordsJson);
      records = decoded.map((e) => Map<String, String>.from(e)).toList();
    }

    final newRecord = {
      'phrase': phraseCtrl.text,
      'hashtags': allHashtags.join(" "),
    };

    if (isEditing && editIndex != null) {
      records[editIndex!] = newRecord;
    } else {
      records.add(newRecord);
    }

    await prefs.setString('records', jsonEncode(records));

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Content" : "Screen C"),
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Phrase",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Type your text with #hashtags",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      HashtagTextField(
                        controller: phraseCtrl,
                        label: "Enter your phrase...",
                        onChanged: updateFromPhrase,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hashtags",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Auto-populated from phrase, add more manually",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: hashtagCtrl,
                        decoration: const InputDecoration(
                          hintText: "#hashtag1 #hashtag2",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveAndSubmit,
                  icon: Icon(isEditing ? Icons.save : Icons.check),
                  label: Text(isEditing ? "Save Changes" : "Submit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
