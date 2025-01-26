import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatelessWidget {
  const BarcodeScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Barcode"),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (BarcodeCapture barcodeCapture) {
              final barcode = barcodeCapture.barcodes.first;
              if (barcode.rawValue != null) {
                Navigator.pop(
                    context, barcode.rawValue); // Return the scanned barcode
              }
            },
          ),
          Center(
            child: Container(
              height: 100,
              width: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
