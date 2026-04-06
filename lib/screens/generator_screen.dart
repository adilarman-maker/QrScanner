import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();
  String qrData = "";
  Color qrColor = Colors.black;
  Color backgroundColor = Colors.white;
  double qrSize = 200;

  void _generateQR() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        qrData = _textController.text;
      });
    }
  }

  Future<void> _saveQR() async {
    try {
      RenderRepaintBoundary boundary = _qrKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final result = await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
        if (result['isSuccess'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR Code saved to gallery!')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    }
  }

  void _shareQR() {
    Share.share('Check out this QR Code content: $qrData');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Generator'),
        centerTitle: true,
        actions: [
          if (qrData.isNotEmpty)
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'save', 
                  child: Row(children: [Icon(Icons.save), SizedBox(width: 10), Text('Save')])
                ),
                const PopupMenuItem(
                  value: 'share', 
                  child: Row(children: [Icon(Icons.share), SizedBox(width: 10), Text('Share')])
                ),
              ],
              onSelected: (value) {
                if (value == 'save') _saveQR();
                if (value == 'share') _shareQR();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3), 
                    spreadRadius: 2, 
                    blurRadius: 10
                  )
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: RepaintBoundary(
                key: _qrKey,
                child: QrImageView(
                  data: qrData.isEmpty ? "Enter text to generate QR" : qrData,
                  version: QrVersions.auto,
                  size: qrSize,
                  eyeStyle: QrEyeStyle(
                    color: qrColor, 
                    eyeShape: QrEyeShape.circle
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    color: qrColor, 
                    dataModuleShape: QrDataModuleShape.circle
                  ),
                  backgroundColor: backgroundColor,
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Enter text or URL',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear), 
                  onPressed: () => _textController.clear()
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _generateQR,
              icon: const Icon(Icons.qr_code),
              label: const Text('Generate QR Code'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50)
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Customization', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('QR Color'),
              trailing: Container(
                width: 50, 
                height: 50, 
                decoration: BoxDecoration(
                  color: qrColor, 
                  border: Border.all(), 
                  borderRadius: BorderRadius.circular(10)
                )
              ),
              onTap: () async {
                Color? color = await showDialog(
                  context: context, 
                  builder: (context) => const ColorPickerDialog()
                );
                if (color != null) setState(() => qrColor = color);
              },
            ),
            ListTile(
              title: const Text('Background Color'),
              trailing: Container(
                width: 50, 
                height: 50, 
                decoration: BoxDecoration(
                  color: backgroundColor, 
                  border: Border.all(), 
                  borderRadius: BorderRadius.circular(10)
                )
              ),
              onTap: () async {
                Color? color = await showDialog(
                  context: context, 
                  builder: (context) => const ColorPickerDialog()
                );
                if (color != null) setState(() => backgroundColor = color);
              },
            ),
            ListTile(
              title: const Text('Size'),
              subtitle: Slider(
                value: qrSize, 
                min: 100, 
                max: 300, 
                onChanged: (value) => setState(() => qrSize = value)
              ),
              trailing: Text('${qrSize.toInt()}px'),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorPickerDialog extends StatelessWidget {
  const ColorPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Color'),
      content: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          Colors.red, Colors.green, Colors.blue, Colors.black, 
          Colors.purple, Colors.orange, Colors.teal, Colors.pink
        ].map((color) => GestureDetector(
          onTap: () => Navigator.pop(context, color),
          child: Container(
            width: 50, 
            height: 50, 
            decoration: BoxDecoration(
              color: color, 
              borderRadius: BorderRadius.circular(10), 
              border: Border.all()
            )
          ),
        )).toList(),
      ),
    );
  }
}