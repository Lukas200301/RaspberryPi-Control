import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

class SystemLogsWidget extends StatefulWidget {
  final List<dynamic> logs;

  const SystemLogsWidget({
    Key? key,
    required this.logs,
  }) : super(key: key);

  @override
  State<SystemLogsWidget> createState() => _SystemLogsWidgetState();
}

class _SystemLogsWidgetState extends State<SystemLogsWidget> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Error', 'Warning', 'Info'];
  final _searchController = TextEditingController();
  bool _showSearch = false;
  
  List<dynamic> _filteredLogs = [];
  Map<String, int> _logStats = {'errors': 0, 'warnings': 0, 'info': 0, 'total': 0};
  Timer? _searchDebounce;
  
  final Map<String, LogSeverity> _severityCache = {};
  final ScrollController _scrollController = ScrollController();
  bool _initialScrollDone = false;

  @override
  void initState() {
    super.initState();
    _updateFilteredLogs();
    _updateLogStats();
  }

  @override
  void didUpdateWidget(SystemLogsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logs != oldWidget.logs) {
      _updateFilteredLogs();
      _updateLogStats();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  LogSeverity _getLogSeverity(String log) {
    if (_severityCache.containsKey(log)) {
      return _severityCache[log]!;
    }
    
    final lowercaseLog = log.toLowerCase();
    LogSeverity severity;
    
    if (lowercaseLog.contains('error') || 
        lowercaseLog.contains('fail') || 
        lowercaseLog.contains('critical')) {
      severity = LogSeverity.error;
    } else if (lowercaseLog.contains('warn') || 
               lowercaseLog.contains('could not') || 
               lowercaseLog.contains('unable to')) {
      severity = LogSeverity.warning;
    } else {
      severity = LogSeverity.info;
    }
    
    _severityCache[log] = severity;
    return severity;
  }

  void _updateFilteredLogs() {
    if (widget.logs.isEmpty) {
      setState(() {
        _filteredLogs = [];
      });
      return;
    }
    
    _searchDebounce?.cancel();
    
    _searchDebounce = Timer(const Duration(milliseconds: 100), () {
      final filtered = widget.logs.where((log) {
        final logStr = log.toString();
        final severity = _getLogSeverity(logStr);
        
        if (_selectedFilter != 'All' && 
            _selectedFilter.toLowerCase() != severity.toString().split('.').last.toLowerCase()) {
          return false;
        }
        
        if (_showSearch && _searchController.text.isNotEmpty) {
          return logStr.toLowerCase().contains(_searchController.text.toLowerCase());
        }
        
        return true;
      }).toList();
      
      if (mounted) {
        setState(() {
          _filteredLogs = filtered;
          if (!_initialScrollDone && _filteredLogs.isNotEmpty) {
            _initialScrollDone = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
          }
        });
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _updateLogStats() {
    int errors = 0;
    int warnings = 0;
    int info = 0;
    
    for (var log in widget.logs) {
      final severity = _getLogSeverity(log.toString());
      if (severity == LogSeverity.error) {
        errors++;
      } else if (severity == LogSeverity.warning) {
        warnings++;
      } else {
        info++;
      }
    }
    
    setState(() {
      _logStats = {
        'errors': errors,
        'warnings': warnings,
        'info': info,
        'total': widget.logs.length,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.grey[100];
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Card(
      margin: EdgeInsets.zero, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'System Logs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_logStats['errors']! > 0)
                      _buildStatChip(
                        _logStats['errors']!.toString(), 
                        Colors.red,
                        Icons.error_outline
                      ),
                    if (_logStats['warnings']! > 0) 
                      _buildStatChip(
                        _logStats['warnings']!.toString(), 
                        Colors.orange,
                        Icons.warning_amber_outlined
                      ),
                    IconButton(
                      icon: Icon(_showSearch ? Icons.search_off : Icons.search),
                      onPressed: () {
                        setState(() {
                          _showSearch = !_showSearch;
                          if (!_showSearch) {
                            _searchController.clear();
                            _updateFilteredLogs();
                          }
                        });
                      },
                      tooltip: 'Search logs',
                      iconSize: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search in logs...',
                  isDense: true,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _updateFilteredLogs();
                          });
                        },
                      )
                    : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (_) {
                  _updateFilteredLogs();
                },
              ),
            ),
          
          SizedBox(
            height: 40,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  
                  Color chipColor;
                  IconData? chipIcon;
                  
                  switch (filter) {
                    case 'Error':
                      chipColor = Colors.red;
                      chipIcon = Icons.error_outline;
                      break;
                    case 'Warning':
                      chipColor = Colors.orange;
                      chipIcon = Icons.warning_amber_outlined;
                      break;
                    case 'Info':
                      chipColor = Colors.blue;
                      chipIcon = Icons.info_outline;
                      break;
                    default:
                      chipColor = Theme.of(context).colorScheme.primary;
                      chipIcon = Icons.all_inbox;
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                          _updateFilteredLogs();
                        });
                      },
                      avatar: Icon(chipIcon, size: 16, color: isSelected ? Colors.white : chipColor),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: chipColor.withOpacity(0.1),
                      selectedColor: chipColor,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  'Showing ${_filteredLogs.length} of ${widget.logs.length} logs',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (_filteredLogs.isNotEmpty)
                  TextButton.icon(
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Reset Filters'),
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'All';
                        _searchController.clear();
                        _updateFilteredLogs();
                      });
                    },
                  ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          SizedBox(
            height: 300, 
            child: _filteredLogs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _selectedFilter == 'All' && !_showSearch
                            ? Icons.article_outlined
                            : Icons.filter_alt_off,
                        size: 40,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFilter == 'All' && !_showSearch && widget.logs.isEmpty
                            ? 'No system logs available'
                            : 'No logs match the current filter',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredLogs.length,
                  itemBuilder: (context, index) {
                    final log = _filteredLogs[index];
                    final logStr = log.toString();
                    final severity = _getLogSeverity(logStr);
                    
                    Color severityColor;
                    IconData severityIcon;
                    
                    switch (severity) {
                      case LogSeverity.error:
                        severityColor = Colors.red;
                        severityIcon = Icons.error_outline;
                        break;
                      case LogSeverity.warning:
                        severityColor = Colors.orange;
                        severityIcon = Icons.warning_amber_outlined;
                        break;
                      default:
                        severityColor = Colors.blue;
                        severityIcon = Icons.info_outline;
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: severityColor.withOpacity(0.3), 
                            width: 1
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showSimpleLogDialog(context, logStr),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(severityIcon, size: 16, color: severityColor),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      logStr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                        color: textColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _navigateToAllLogs();
                    },
                    icon: const Icon(Icons.article),
                    label: const Text('View All Logs'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 40,
                  child: TextButton.icon(
                    onPressed: () {
                      final logsToProcess = widget.logs.length > 200 ? widget.logs.sublist(0, 200) : widget.logs;
                      final logsText = logsToProcess.join('\n');
                      Clipboard.setData(ClipboardData(text: logsText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${logsToProcess.length} logs copied to clipboard'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAllLogs() {
    final maxLogs = 500;
    final logsToShow = widget.logs.length > maxLogs 
        ? widget.logs.sublist(0, maxLogs) 
        : widget.logs;
        
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllLogsPage(
          logs: logsToShow,
          initialSortOption: _selectedFilter,
          totalLogsCount: widget.logs.length,
        ),
      ),
    );
  }

  Widget _buildStatChip(String count, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showSimpleLogDialog(BuildContext context, String log) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Log Detail',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8), 
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      log,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[900],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: log));
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Log copied to clipboard'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Text('Copy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AllLogsPage extends StatefulWidget {
  final List<dynamic> logs;
  final String initialSortOption;
  final int totalLogsCount;

  const AllLogsPage({
    Key? key,
    required this.logs,
    this.initialSortOption = 'All',
    this.totalLogsCount = 0,
  }) : super(key: key);

  @override
  State<AllLogsPage> createState() => _AllLogsPageState();
}

class _AllLogsPageState extends State<AllLogsPage> {
  late String _selectedFilter;
  final List<String> _filters = ['All', 'Error', 'Warning', 'Info'];
  final _searchController = TextEditingController();
  List<dynamic> _filteredLogs = [];
  final Map<String, LogSeverity> _severityCache = {};
  Timer? _searchDebounce;
  bool _isFiltering = false;
  final ScrollController _scrollController = ScrollController();
  bool _initialScrollDone = false;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialSortOption;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.logs.length > 500) {
        setState(() {
          _isFiltering = false;
        });
        _updateFilteredLogs();
      } else {
        _preProcessLogsSimply();
      }
    });
  }
  
  void _preProcessLogsSimply() {
    if (widget.logs.length > 500) {
      setState(() {
        _isFiltering = false;
      });
      _updateFilteredLogs();
      return;
    }
    
    setState(() {
      _isFiltering = true;
    });
    
    Timer(const Duration(milliseconds: 100), () {
      final maxLogsToProcess = math.min(200, widget.logs.length);
      
      try {
        for (int i = 0; i < maxLogsToProcess; i++) {
          try {
            final logStr = widget.logs[i].toString();
            if (!_severityCache.containsKey(logStr)) {
              _severityCache[logStr] = _getSafeSeverity(logStr);
            }
          } catch (e) {
            print('Error processing log: $e');
          }
        }
      } catch (e) {
        print('Error in pre-processing: $e');
      }
      
      if (mounted) {
        _updateFilteredLogs();
      }
    });
  }
  
  LogSeverity _getSafeSeverity(String log) {
    try {
      if (log.isEmpty) return LogSeverity.info;
      
      final lowercaseLog = log.toLowerCase();
      
      if (lowercaseLog.contains('no more sessions')) {
        return LogSeverity.warning;
      }
      else if (lowercaseLog.contains('error') || 
          lowercaseLog.contains('fail') || 
          lowercaseLog.contains('critical')) {
        return LogSeverity.error;
      } else if (lowercaseLog.contains('warn') || 
                lowercaseLog.contains('could not') || 
                lowercaseLog.contains('unable to')) {
        return LogSeverity.warning;
      } else {
        return LogSeverity.info;
      }
    } catch (e) {
      print('Error determining log severity: $e');
      return LogSeverity.info;
    }
  }

  LogSeverity _getLogSeverity(String log) {
    if (_severityCache.containsKey(log)) {
      return _severityCache[log]!;
    }
    
    LogSeverity severity = _getSafeSeverity(log);
    _severityCache[log] = severity;
    return severity;
  }

  void _updateFilteredLogs() {
    if (widget.logs.isEmpty) {
      setState(() {
        _filteredLogs = [];
        _isFiltering = false;
      });
      return;
    }
    
    _searchDebounce?.cancel();
    
    setState(() {
      _isFiltering = true;
    });
    
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      try {
        final searchQuery = _searchController.text.toLowerCase();
        final maxLogsToProcess = math.min(300, widget.logs.length);
        final logsToProcess = widget.logs.sublist(0, maxLogsToProcess);
        
        final filtered = logsToProcess.where((log) {
          try {
            final logStr = log.toString();
            
            bool matchesFilter = true;
            if (_selectedFilter != 'All') {
              final severity = _severityCache[logStr] ?? _getSafeSeverity(logStr);
              matchesFilter = 
                _selectedFilter.toLowerCase() == severity.toString().split('.').last.toLowerCase();
            }
            
            if (!matchesFilter) return false;
            
            if (searchQuery.isNotEmpty) {
              return logStr.toLowerCase().contains(searchQuery);
            }
            
            return true;
          } catch (e) {
            print('Error filtering log: $e');
            return false; 
          }
        }).toList();
        
        final displayingAllLogs = maxLogsToProcess >= widget.logs.length;
        
        if (mounted) {
          setState(() {
            _filteredLogs = filtered;
            _isFiltering = false;
            _displayingFullList = displayingAllLogs;
            
            if (!_initialScrollDone && _filteredLogs.isNotEmpty) {
              _initialScrollDone = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }
          });
        }
      } catch (e) {
        print('Error in _updateFilteredLogs: $e');
        if (mounted) {
          setState(() {
            _filteredLogs = [];
            _isFiltering = false;
          });
        }
      }
    });
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  bool _displayingFullList = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.grey[100];

    return Scaffold(
      appBar: AppBar(
        title: Text('System Logs ${widget.totalLogsCount > widget.logs.length ? "(Showing ${widget.logs.length} of ${widget.totalLogsCount})" : ""}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              final logsText = _filteredLogs.join('\n');
              Clipboard.setData(ClipboardData(text: logsText));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_filteredLogs.length} logs copied to clipboard'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Copy filtered logs',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search logs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _updateFilteredLogs();
                        });
                      },
                    )
                  : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (_) => _updateFilteredLogs(),
            ),
          ),
          
          SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  
                  Color chipColor;
                  IconData? chipIcon;
                  
                  switch (filter) {
                    case 'Error':
                      chipColor = Colors.red;
                      chipIcon = Icons.error_outline;
                      break;
                    case 'Warning':
                      chipColor = Colors.orange;
                      chipIcon = Icons.warning_amber_outlined;
                      break;
                    case 'Info':
                      chipColor = Colors.blue;
                      chipIcon = Icons.info_outline;
                      break;
                    default:
                      chipColor = Theme.of(context).colorScheme.primary;
                      chipIcon = Icons.all_inbox;
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                          _updateFilteredLogs();
                        });
                      },
                      avatar: Icon(chipIcon, size: 16, color: isSelected ? Colors.white : chipColor),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: chipColor.withOpacity(0.1),
                      selectedColor: chipColor,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  'Showing ${_filteredLogs.length} of ${widget.logs.length} logs',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (_filteredLogs.isNotEmpty)
                  TextButton.icon(
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Reset Filters'),
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'All';
                        _searchController.clear();
                        _updateFilteredLogs();
                      });
                    },
                  ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          Expanded(
            child: _filteredLogs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isFiltering 
                            ? Icons.hourglass_empty
                            : Icons.filter_alt_off,
                        size: 48,
                        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isFiltering
                            ? 'Filtering logs...'
                            : (widget.logs.isEmpty
                                ? 'No system logs available'
                                : 'No logs match the current filter'),
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _filteredLogs.length,
                  itemBuilder: (context, index) {
                    final log = _filteredLogs[index].toString();
                    final severity = _severityCache[log] ?? _getLogSeverity(log);
                    
                    Color severityColor;
                    IconData severityIcon;
                    
                    switch (severity) {
                      case LogSeverity.error:
                        severityColor = Colors.red;
                        severityIcon = Icons.error_outline;
                        break;
                      case LogSeverity.warning:
                        severityColor = Colors.orange;
                        severityIcon = Icons.warning_amber_outlined;
                        break;
                      default:
                        severityColor = Colors.blue;
                        severityIcon = Icons.info_outline;
                    }
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: severityColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      color: backgroundColor,
                      child: ListTile(
                        leading: Icon(severityIcon, color: severityColor),
                        title: Text(
                          log,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _showLogDetailDialog(context, log, severity),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: log));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Log copied to clipboard'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
          ),
          
          if (!_displayingFullList)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text(
                'Note: For performance reasons, only showing the first 300 matching logs',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[700],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
          if (widget.totalLogsCount > widget.logs.length)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Note: Only showing the first ${widget.logs.length} logs for performance reasons',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
      floatingActionButton: _filteredLogs.isNotEmpty 
          ? FloatingActionButton(
              mini: true,
              onPressed: _scrollToBottom,
              tooltip: 'Latest logs',
              child: const Icon(Icons.arrow_downward),
            )
          : null,
    );
  }

  void _showLogDetailDialog(BuildContext context, String log, LogSeverity severity) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Log Detail',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8), 
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      log,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[900],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4), 
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: log));
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Log copied to clipboard'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Text('Copy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum LogSeverity {
  error,
  warning,
  info,
}
