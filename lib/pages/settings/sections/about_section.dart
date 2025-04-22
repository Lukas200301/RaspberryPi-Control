import 'package:flutter/material.dart';
import '../utils/settings_utils.dart';

class AboutSection extends StatelessWidget {
  final String appVersion;
  final bool isCheckingForUpdates;
  final Map<String, dynamic>? updateInfo;
  final bool isDownloadingUpdate;
  final double downloadProgress;
  final bool highlightUpdateSection;
  final Function() checkForUpdates;
  final Function() downloadAndInstallUpdate;
  final Function() openReleasePage;
  final Function() launchGitHub;
  final GlobalKey updateSectionKey;

  const AboutSection({
    Key? key,
    required this.appVersion,
    required this.isCheckingForUpdates,
    required this.updateInfo,
    required this.isDownloadingUpdate,
    required this.downloadProgress,
    required this.highlightUpdateSection,
    required this.checkForUpdates,
    required this.downloadAndInstallUpdate,
    required this.openReleasePage,
    required this.launchGitHub,
    required this.updateSectionKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsUtils.buildSectionHeader(context, 'About'),
        
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: highlightUpdateSection ? [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ] : [],
          ),
          padding: highlightUpdateSection ? const EdgeInsets.all(4) : EdgeInsets.zero,
          child: Card(
            key: updateSectionKey,
            shape: highlightUpdateSection ? 
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ) : null,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'App Version',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appVersion,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      isCheckingForUpdates
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Check for Updates'),
                              onPressed: checkForUpdates,
                            ),
                    ],
                  ),
                  
                  if (updateInfo != null) ...[
                    const SizedBox(height: 16),
                    if (updateInfo!['updateAvailable'] == true) ...[
                      Text(
                        'New version available: ${updateInfo!['latestVersion']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      
                      if (updateInfo!.containsKey('newerReleases') && (updateInfo!['newerReleases'] as List).length > 1) ...[
                        Text(
                          'Contains ${(updateInfo!['newerReleases'] as List).length} updates since your version',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 12,
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 8),
                      if (updateInfo!['releaseNotes'] != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            SettingsUtils.cleanMarkdown(updateInfo!['releaseNotes']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (isDownloadingUpdate) ...[
                        LinearProgressIndicator(value: downloadProgress),
                        const SizedBox(height: 8),
                        Text(
                          'Downloading... ${(downloadProgress * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.file_download),
                                label: const Text('Download & Install'),
                                onPressed: downloadAndInstallUpdate,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextButton.icon(
                                icon: const Icon(Icons.open_in_new),
                                label: const Text('Open Release Page'),
                                onPressed: openReleasePage,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ] else ...[
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'You are using the latest version ($appVersion).',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
        
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('GitHub Repository'),
          subtitle: const Text('Report issues, view source code, suggest features or contribute code'),
          trailing: const Icon(Icons.open_in_new),
          onTap: launchGitHub,
        ),
      ],
    );
  }
}
