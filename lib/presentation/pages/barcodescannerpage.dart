import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatelessWidget {
  const BarcodeScannerPage({super.key, required this.onScanned});
  final Function(String) onScanned;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Barcode"),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (barcodeCapture) {
              final barcode = barcodeCapture.barcodes.first;
              if (barcode.rawValue != null) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  onScanned(code);
                  Navigator.pop(context, barcode.rawValue);
                } // Return the scanned barcode
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
