part of 'barcode_scanner_bloc.dart';

abstract class BarcodeScannerState extends Equatable {
  @override
  List<Object> get props => [];
}

/// 🔹 Initial State
class BarcodeScannerInitial extends BarcodeScannerState {}

/// 🔹 State When Barcode is Scanned Successfully
class BarcodeScannedState extends BarcodeScannerState {
  final String eanCode;

  BarcodeScannedState(this.eanCode);

  @override
  List<Object> get props => [eanCode];
}

/// 🔹 Error State if Scanning Fails
class BarcodeScannerError extends BarcodeScannerState {
  final String message;

  BarcodeScannerError(this.message);

  @override
  List<Object> get props => [message];
}
