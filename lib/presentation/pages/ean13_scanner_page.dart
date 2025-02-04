import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class EAN13ScannerPage extends StatefulWidget {
  const EAN13ScannerPage({Key? key}) : super(key: key);

  @override
  _EAN13ScannerPageState createState() => _EAN13ScannerPageState();
}

class _EAN13ScannerPageState extends State<EAN13ScannerPage> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    // Define a small, centered scan area.
    final double scanAreaWidth = 200;
    final double scanAreaHeight = 100;
    final double leftOffset =
        (MediaQuery.of(context).size.width / 2) - (scanAreaWidth / 2);
    final double topOffset =
        (MediaQuery.of(context).size.height / 2) - (scanAreaHeight / 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EAN13 Scanner'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            // Restrict scanning to a small, centered area.
            scanWindow: Rect.fromLTWH(
                leftOffset, topOffset, scanAreaWidth, scanAreaHeight),
            onDetect: (BarcodeCapture capture) {
              if (!_isScanned) {
                final barcode =
                    capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
                final code = barcode?.rawValue;
                if (code != null && code.length == 13) {
                  setState(() {
                    _isScanned = true;
                  });
                  // Pop the page with the scanned code.
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.of(context).pop(code);
                  });
                }
              }
            },
          ),
          // Draw an overlay rectangle to indicate the scanning area.
          Align(
            alignment: Alignment.center,
            child: Container(
              width: scanAreaWidth,
              height: scanAreaHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
