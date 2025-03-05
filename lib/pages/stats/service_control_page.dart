import 'package:flutter/material.dart';

class ServiceControlPage extends StatefulWidget {
  @override
  _ServiceControlPageState createState() => _ServiceControlPageState();
}

class _ServiceControlPageState extends State<ServiceControlPage> {
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> filteredServices = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _applyFilter() {
    final searchQuery = searchController.text.toLowerCase();
    
    try {
      if (searchQuery.isEmpty) {
        filteredServices = List.from(services);
      } else {
        filteredServices = services.where((service) {
          final name = (service['name'] ?? '').toLowerCase();
          final description = (service['description'] ?? '').toLowerCase();
          return name.contains(searchQuery) || description.contains(searchQuery);
        }).toList();
      }
    } catch (e) {
      debugPrint('Error during filtering: $e');
      filteredServices = List.from(services);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Control'),
      ),
      body: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search',
            ),
            onChanged: (value) {
              setState(() {
                _applyFilter();
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];
                return ListTile(
                  title: Text(service['name'] ?? ''),
                  subtitle: Text(service['description'] ?? ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
