import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScreenA extends StatefulWidget {
  const ScreenA({super.key});

  @override
  State<ScreenA> createState() => _ScreenAState();
}

class _ScreenAState extends State<ScreenA> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "🎉",
                  style: TextStyle(fontSize: 48),
                ),
                SizedBox(height: 16),
                Text(
                  "Congratulations",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen A"),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.tag,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                "Hashtag App",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Create and manage your hashtags",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () => context.go("/a/b"),
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Get Started"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
