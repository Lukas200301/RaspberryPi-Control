import 'package:flutter/material.dart';

class SecurityStatusWidget extends StatefulWidget {
  final Map<String, dynamic> securityInfo;

  const SecurityStatusWidget({
    Key? key,
    required this.securityInfo,
  }) : super(key: key);

  @override
  State<SecurityStatusWidget> createState() => _SecurityStatusWidgetState();
}

class _SecurityStatusWidgetState extends State<SecurityStatusWidget> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final hardeningIndex = widget.securityInfo['hardening_index'] as int? ?? 0;
    final vulnerablePackages = widget.securityInfo['vulnerable_packages'] as int? ?? 0;
    final updatesAvailable = widget.securityInfo['updates_available'] as int? ?? 0;
    final securityUpdates = widget.securityInfo['security_updates'] as int? ?? 0;
    final firewallStatus = widget.securityInfo['firewall_status'] as String? ?? 'Unknown';
    final sshRootLogin = widget.securityInfo['ssh_root_login'] as String? ?? 'UNKNOWN';
    final warnings = widget.securityInfo['warnings'] as List? ?? [];
    final suggestions = widget.securityInfo['suggestions'] as List? ?? [];
    final openPorts = widget.securityInfo['open_ports'] as List? ?? [];
    
    
    final bool firewallEnabled = firewallStatus.toLowerCase() == 'active' || 
                               firewallStatus.toLowerCase() == 'enabled';
    
    final securityScore = _calculateSecurityScore(
      hardeningIndex: hardeningIndex,
      vulnerablePackages: vulnerablePackages,
      updatesNeeded: updatesAvailable > 0,
      securityUpdatesNeeded: securityUpdates > 0,
      firewallEnabled: firewallEnabled,
      openPortsCount: openPorts.length,
      warningsCount: warnings.length,
      sshRootLoginAllowed: sshRootLogin.toUpperCase() == 'PERMITTED',
    );
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Security Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildSecurityScoreChip(securityScore),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(height: 1),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hardeningIndex > 0) ...[
                  _buildHardeningMeter(hardeningIndex),
                  const SizedBox(height: 16),
                ],
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusCard(
                        title: 'Firewall',
                        status: firewallEnabled ? 'Enabled' : 'Disabled',
                        icon: Icons.security,
                        isPositive: firewallEnabled,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatusCard(
                        title: 'Updates',
                        status: updatesAvailable > 0 ? '$updatesAvailable Available' : 'Up to date',
                        icon: Icons.system_update,
                        isPositive: updatesAvailable == 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusCard(
                        title: 'Security Updates',
                        status: securityUpdates > 0 ? '$securityUpdates Needed' : 'None needed',
                        icon: Icons.security_update_warning,
                        isPositive: securityUpdates == 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatusCard(
                        title: 'Vulnerable Pkgs',
                        status: vulnerablePackages > 0 ? '$vulnerablePackages Found' : 'None',
                        icon: Icons.bug_report,
                        isPositive: vulnerablePackages == 0,
                      ),
                    ),
                  ],
                ),
                
                if (warnings.isNotEmpty || suggestions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showDetails = !_showDetails;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _showDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  const TextSpan(
                                    text: 'Security Issues ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '(${warnings.length} warnings, ${suggestions.length} suggestions)',
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (_showDetails) ...[
                    const SizedBox(height: 12),
                    if (warnings.isNotEmpty) ...[
                      const Text(
                        'Warnings',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...warnings.take(3).map((warning) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber, size: 16, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                warning.toString(),
                                style: const TextStyle(fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                      if (warnings.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '+ ${warnings.length - 3} more warnings',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ],
                ],
                
                if (openPorts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Open Ports',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${openPorts.length} Open',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: openPorts.take(8).map<Widget>((port) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? 
                                 Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark ? 
                                   Colors.grey[700]! : Colors.grey[400]!,
                          ),
                        ),
                        child: Text(
                          port.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).brightness == Brightness.dark ? 
                                  Colors.white : Colors.black87,
                          ),
                        ),
                      );
                    }).toList()..add(
                      openPorts.length > 8 ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? 
                                 Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark ? 
                                   Colors.grey[700]! : Colors.grey[400]!,
                          ),
                        ),
                        child: Text(
                          '+${openPorts.length - 8} more',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).brightness == Brightness.dark ? 
                                  Colors.white : Colors.black87,
                          ),
                        ),
                      ) : Container(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHardeningMeter(int index) {
    Color getHardeningColor(double value) {
      if (value >= 90) return Colors.green;
      if (value >= 75) return Colors.lightGreen;
      if (value >= 50) return Colors.amber;
      if (value >= 25) return Colors.orange;
      return Colors.red;
    }
    
    final color = getHardeningColor(index.toDouble());
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'System Hardening Index',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${index.toInt()}/100',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: index / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getHardeningDescription(index.toDouble()),
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
  
  String _getHardeningDescription(double index) {
    if (index >= 90) return 'Excellent - System is well hardened';
    if (index >= 75) return 'Good - System has good security measures';
    if (index >= 50) return 'Moderate - Some security measures in place';
    if (index >= 25) return 'Weak - System needs security improvements';
    return 'Poor - System is vulnerable, needs immediate attention';
  }
  
  int _calculateSecurityScore({
    required int hardeningIndex,
    required int vulnerablePackages,
    required bool updatesNeeded,
    required bool securityUpdatesNeeded,
    required bool firewallEnabled,
    required int openPortsCount,
    required int warningsCount,
    required bool sshRootLoginAllowed,
  }) {
    if (hardeningIndex > 0) {
      return hardeningIndex;
    }
    
    int score = 100;
    
    if (!firewallEnabled) score -= 20;
    if (updatesNeeded) score -= 10;
    if (securityUpdatesNeeded) score -= 20;
    score -= (vulnerablePackages * 5).clamp(0, 20);
    score -= (openPortsCount * 3).clamp(0, 20);
    score -= (warningsCount * 2).clamp(0, 20);
    if (sshRootLoginAllowed) score -= 15;
    
    return score.clamp(0, 100);
  }
  
  Widget _buildSecurityScoreChip(int score) {
    Color scoreColor;
    IconData icon;
    
    if (score >= 80) {
      scoreColor = Colors.green;
      icon = Icons.verified;
    } else if (score >= 60) {
      scoreColor = Colors.orange;
      icon = Icons.security;
    } else {
      scoreColor = Colors.red;
      icon = Icons.warning;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: scoreColor,
          ),
          const SizedBox(width: 6),
          Text(
            'Score: $score',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusCard({
    required String title,
    required String status,
    required IconData icon,
    required bool isPositive,
  }) {
    final color = isPositive ? Colors.green : Colors.red;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
