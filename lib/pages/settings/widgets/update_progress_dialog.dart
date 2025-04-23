import 'package:flutter/material.dart';
import '../../../services/in_app_updater.dart';

class UpdateProgressDialog extends StatefulWidget {
  final String version;
  final VoidCallback onClose;

  const UpdateProgressDialog({
    Key? key, 
    required this.version,
    required this.onClose,
  }) : super(key: key);

  @override
  State<UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<UpdateProgressDialog> {
  double _progress = 0.0;
  String _status = 'Preparing...';
  bool _isCompleted = false;
  final InAppUpdater _updater = InAppUpdater();

  @override
  void initState() {
    super.initState();
    _subscribeToUpdates();
  }

  void _subscribeToUpdates() {
    _updater.progressStream.listen((progress) {
      setState(() {
        _progress = progress;
      });
    });

    _updater.statusStream.listen((status) {
      setState(() {
        _status = status;
      });
    });

    _updater.completedStream.listen((completed) {
      setState(() {
        _isCompleted = completed;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _isCompleted ? Icons.check_circle : Icons.system_update_alt,
                  color: _isCompleted ? Colors.green : Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _isCompleted 
                        ? 'Update Complete!' 
                        : 'Updating to version ${widget.version}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _isCompleted ? Colors.green : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _status,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isCompleted
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: widget.onClose,
                    child: const Text('Close'),
                  )
                : const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Please keep the app open while the update is being installed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
