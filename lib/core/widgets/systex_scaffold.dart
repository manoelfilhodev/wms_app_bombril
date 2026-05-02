import 'package:flutter/material.dart';

import '../app_theme.dart';

class SystexScaffold extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool useSafeArea;
  final EdgeInsetsGeometry? padding;
  final Widget? floatingActionButton;

  const SystexScaffold({
    super.key,
    this.title,
    required this.child,
    this.actions,
    this.centerTitle = false,
    this.useSafeArea = true,
    this.padding,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final bodyContent = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B0B0B), Color(0xFF0F0F10), Color(0xFF121214)],
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    return Scaffold(
      backgroundColor: SystexColors.background,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              actions: actions,
              centerTitle: centerTitle,
            ),
      floatingActionButton: floatingActionButton,
      body: useSafeArea ? SafeArea(child: bodyContent) : bodyContent,
    );
  }
}
