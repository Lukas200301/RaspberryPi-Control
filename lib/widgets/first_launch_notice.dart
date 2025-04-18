import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstLaunchNotice extends StatefulWidget {
  const FirstLaunchNotice({Key? key}) : super(key: key);

  @override
  State<FirstLaunchNotice> createState() => _FirstLaunchNoticeState();
}

class _FirstLaunchNoticeState extends State<FirstLaunchNotice> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowNotice();
    });
  }

  Future<void> _checkAndShowNotice() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = !prefs.containsKey('hasSeenNotice');

    if (isFirstLaunch && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber,
                size: 30,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'IMPORTANT NOTICE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.amber,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'The Raspberry Pi must be set to English locale for all features to work correctly.\n\nSome monitoring features may not work properly with other system languages.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await prefs.setBool('hasSeenNotice', true);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text(
                'I UNDERSTAND',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}