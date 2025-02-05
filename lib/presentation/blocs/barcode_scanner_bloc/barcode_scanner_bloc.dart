import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'barcode_scanner_event.dart';
part 'barcode_scanner_state.dart';

class BarcodeScannerBloc
    extends Bloc<BarcodeScannerEvent, BarcodeScannerState> {
  BarcodeScannerBloc() : super(BarcodeScannerInitial()) {
    on<ScanBarcodeEvent>(_onScanBarcode);
  }

  /// 🔹 Handle Barcode Scanning Result
  void _onScanBarcode(
      ScanBarcodeEvent event, Emitter<BarcodeScannerState> emit) {
    if (event.eanCode.isNotEmpty) {
      emit(BarcodeScannedState(event.eanCode));
    } else {
      emit(BarcodeScannerError('Código de barras no válido.'));
    }
  }
}
