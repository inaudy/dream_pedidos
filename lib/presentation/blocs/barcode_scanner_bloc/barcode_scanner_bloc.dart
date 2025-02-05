import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'barcode_scanner_event.dart';
part 'barcode_scanner_state.dart';

class BarcodeScannerBloc
    extends Bloc<BarcodeScannerEvent, BarcodeScannerState> {
  String? _lastScannedCode;

  BarcodeScannerBloc() : super(BarcodeScannerInitial()) {
    on<ScanBarcodeEvent>(_onScanBarcode);
  }

  void _onScanBarcode(
      ScanBarcodeEvent event, Emitter<BarcodeScannerState> emit) {
    if (event.eanCode.isEmpty) {
      emit(BarcodeScannerError('Código de barras no válido.'));
      return;
    }

    if (_lastScannedCode == event.eanCode) {
      return; // Ignore duplicate scans
    }

    _lastScannedCode = event.eanCode;
    emit(BarcodeScannedState(event.eanCode));
  }
}
