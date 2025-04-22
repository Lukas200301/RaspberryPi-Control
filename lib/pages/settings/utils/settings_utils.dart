import 'package:flutter/material.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class SettingsUtils {
  static Widget buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
  
  static String cleanMarkdown(String markdown) {
    String text = markdown;
    
    text = text.replaceAllMapped(RegExp(r'#{1,6}\s+(.+?)$', multiLine: true), (match) {
      return '\n${match.group(1)}\n';
    });
    
    text = text.replaceAllMapped(RegExp(r'^(\s*[-*+]|\s*\d+\.)\s+(.+?)$', multiLine: true), (match) {
      return '• ${match.group(2)}\n';
    });
    
    text = text.replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (match) {
      return match.group(1) ?? '';
    });
    text = text.replaceAllMapped(RegExp(r'__(.+?)__'), (match) {
      return match.group(1) ?? '';
    });
    text = text.replaceAllMapped(RegExp(r'\*(.+?)\*'), (match) {
      return match.group(1) ?? '';
    });
    text = text.replaceAllMapped(RegExp(r'_(.+?)_'), (match) {
      return match.group(1) ?? '';
    });
    text = text.replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), (match) {
      return match.group(1) ?? '';
    });
    text = text.replaceAllMapped(RegExp(r'```(?:\w+)?\n(.*?)```', dotAll: true), (match) {
      return '\n${match.group(1)}\n';
    });
    text = text.replaceAllMapped(RegExp(r'`([^`]+)`'), (match) {
      return match.group(1) ?? '';
    });
    text = text.replaceAll(RegExp(r'^(---|\*\*\*|___)$', multiLine: true), '\n—————\n');
    text = text.replaceAllMapped(RegExp(r'^>\s+(.+?)$', multiLine: true), (match) {
      return '″${match.group(1)}″\n';
    });
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return text.trim();
  }
}
