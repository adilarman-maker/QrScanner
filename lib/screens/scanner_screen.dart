import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/history_service.dart';
import '../models/scan_history.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController scannerController = MobileScannerController();
  bool isTorchOn = false;
  bool isScanning = true;
  String? lastScannedCode;
  final HistoryService historyService = HistoryService();

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (!isScanning) return;
    
    final String? code = capture.barcodes.first.rawValue;
    if (code != null && code != lastScannedCode) {
      lastScannedCode = code;
      setState(() => isScanning = false);
      
      HapticFeedback.selectionClick();
      
      final scanHistory = ScanHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: code,
        type: capture.barcodes.first.type.name,
        timestamp: DateTime.now(),
      );
      historyService.saveScan(scanHistory);
      
      _showResultDialog(code);
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => isScanning = true);
          lastScannedCode = null;
        }
      });
    }
  }

  void _showResultDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Scan Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Scanned Content:'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(code),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard!')),
              );
            },
            child: const Text('Copy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _toggleTorch() {
    setState(() {
      isTorchOn = !isTorchOn;
      scannerController.toggleTorch();
    });
  }

  void _switchCamera() {
    scannerController.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleTorch,
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: scannerController,
            onDetect: _handleBarcode,
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0, left: 0,
                      child: Container(width: 30, height: 30,
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.blue, width: 4), left: BorderSide(color: Colors.blue, width: 4)),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0, right: 0,
                      child: Container(width: 30, height: 30,
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.blue, width: 4), right: BorderSide(color: Colors.blue, width: 4)),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, left: 0,
                      child: Container(width: 30, height: 30,
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.blue, width: 4), left: BorderSide(color: Colors.blue, width: 4)),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(width: 30, height: 30,
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.blue, width: 4), right: BorderSide(color: Colors.blue, width: 4)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}