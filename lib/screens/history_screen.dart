import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../models/scan_history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  List<ScanHistory> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    _history = await _historyService.getHistory();
    setState(() => _isLoading = false);
  }

  Future<void> _clearHistory() async {
    await _historyService.clearHistory();
    await _loadHistory();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('History cleared!')));
  }

  Future<void> _deleteItem(String id) async {
    await _historyService.deleteScan(id);
    await _loadHistory();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item deleted!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        centerTitle: true,
        actions: [if (_history.isNotEmpty) IconButton(icon: const Icon(Icons.delete_sweep), onPressed: _clearHistory)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 20),
                      Text('No scan history yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                      const SizedBox(height: 10),
                      const Text('Scan a QR code to see it here'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final scan = _history[index];
                    return Dismissible(
                      key: Key(scan.id),
                      direction: DismissDirection.endToStart,
                      background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                      onDismissed: (_) => _deleteItem(scan.id),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.qr_code)),
                          title: Text(scan.content.length > 50 ? '${scan.content.substring(0, 50)}...' : scan.content, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const SizedBox(height: 5),
                            Text('Type: ${scan.type}', style: const TextStyle(fontSize: 12)),
                            Text('${scan.timestamp.day}/${scan.timestamp.month}/${scan.timestamp.year} ${scan.timestamp.hour}:${scan.timestamp.minute}', style: const TextStyle(fontSize: 12)),
                          ]),
                          onTap: () => _showDetailsDialog(scan),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showDetailsDialog(ScanHistory scan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Content:'),
            Container(padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(top: 5, bottom: 10), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(5)), child: SelectableText(scan.content)),
            Text('Type: ${scan.type}'),
            Text('Time: ${scan.timestamp.day}/${scan.timestamp.month}/${scan.timestamp.year} ${scan.timestamp.hour}:${scan.timestamp.minute}'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }
}