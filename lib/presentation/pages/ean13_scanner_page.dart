import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class EAN13ScannerPage extends StatefulWidget {
  const EAN13ScannerPage({super.key});

  @override
  EAN13ScannerPageState createState() => EAN13ScannerPageState();
}

class EAN13ScannerPageState extends State<EAN13ScannerPage> {
  bool _isScanned = false;
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with optimized parameters.
    _controller = MobileScannerController(
      autoStart: true, formats: [BarcodeFormat.ean13],
      detectionSpeed: DetectionSpeed.unrestricted, // Faster detection
      // Avoid duplicate detections
      // You can also enable autofocus or torch if needed:
      // autoStart: true,
      // torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define a smaller, centered scan area to speed up detection.
    const double scanAreaWidth = 300;
    const double scanAreaHeight = 150;
    final double leftOffset =
        (MediaQuery.of(context).size.width / 2) - (scanAreaWidth / 2);
    final double topOffset =
        (MediaQuery.of(context).size.height / 2) - (scanAreaHeight / 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Busqueda artículo por código EAN13'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
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
                  // Stop further scanning immediately.
                  _controller.stop();
                  // Brief delay to let the user see that the scan was successful,
                  // then pop the page with the scanned code.
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (!context.mounted) return;
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
