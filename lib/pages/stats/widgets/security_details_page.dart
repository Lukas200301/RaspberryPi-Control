import 'package:flutter/material.dart';

class SecurityDetailsPage extends StatefulWidget {
  final Map<String, dynamic> securityInfo;

  const SecurityDetailsPage({
    Key? key,
    required this.securityInfo,
  }) : super(key: key);

  @override
  State<SecurityDetailsPage> createState() => _SecurityDetailsPageState();
}

class _SecurityDetailsPageState extends State<SecurityDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final warnings = widget.securityInfo['warnings'] ?? [];
    final suggestions = widget.securityInfo['suggestions'] ?? [];
    final openPorts = widget.securityInfo['open_ports'] ?? [];
    final hardeningIndex = widget.securityInfo['hardening_index'] ?? 0.0;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Warnings'),
            Tab(text: 'Suggestions'),
            Tab(text: 'Open Ports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListTab(
            warnings,
            icon: Icons.warning_amber,
            color: Colors.red,
            emptyText: 'No security warnings found',
          ),
          
          _buildListTab(
            suggestions,
            icon: Icons.lightbulb_outline,
            color: Colors.blue,
            emptyText: 'No security suggestions available',
          ),
          
          _buildPortsTab(openPorts),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: hardeningIndex / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getHardeningColor(hardeningIndex)),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'System Hardening Index',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getHardeningColor(hardeningIndex).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${hardeningIndex.toInt()}/100',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getHardeningColor(hardeningIndex),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildListTab(List<dynamic> items, {
    required IconData icon,
    required Color color,
    required String emptyText,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              emptyText,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(icon, color: color),
            title: Text(
              item.toString(),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPortsTab(List<dynamic> ports) {
    if (ports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cable, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No open ports detected',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: ports.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final port = ports[index];
        String portDescription = _getPortDescription(port.toString());
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.cable, color: Colors.deepOrange),
            title: Text(
              'Port ${port.toString()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              portDescription,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        );
      },
    );
  }
  
  Color _getHardeningColor(double index) {
    if (index >= 90) return Colors.green;
    if (index >= 75) return Colors.lightGreen;
    if (index >= 50) return Colors.amber;
    if (index >= 25) return Colors.orange;
    return Colors.red;
  }
  
  String _getPortDescription(String port) {
    final int portNum = int.tryParse(port) ?? 0;
    
    final Map<int, String> commonPorts = {
      22: 'SSH (Secure Shell)',
      80: 'HTTP (Web Server)',
      443: 'HTTPS (Secure Web Server)',
      21: 'FTP (File Transfer)',
      25: 'SMTP (Email)',
      110: 'POP3 (Email Retrieval)',
      143: 'IMAP (Email Access)',
      53: 'DNS (Domain Name System)',
      3306: 'MySQL Database',
      5432: 'PostgreSQL Database',
      27017: 'MongoDB',
      6379: 'Redis',
      8080: 'Alternative HTTP/Proxy',
      1194: 'OpenVPN',
      137: 'NetBIOS Name Service',
      138: 'NetBIOS Datagram Service',
      139: 'NetBIOS Session Service',
      445: 'SMB (File Sharing)',
      3389: 'RDP (Remote Desktop)',
      5900: 'VNC (Remote Desktop)',
      8888: 'Common Proxy/Web Server',
      9090: 'Common Proxy/Web Server',
    };
    
    return commonPorts[portNum] ?? 'Unknown service';
  }
}
