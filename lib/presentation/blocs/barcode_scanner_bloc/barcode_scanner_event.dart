part of 'barcode_scanner_bloc.dart';

abstract class BarcodeScannerEvent extends Equatable {
  @override
  List<Object> get props => [];
}

/// 🔹 Event to Trigger Barcode Scanning
class ScanBarcodeEvent extends BarcodeScannerEvent {
  final String eanCode;

  ScanBarcodeEvent(this.eanCode);

  @override
  List<Object> get props => [eanCode];
}
