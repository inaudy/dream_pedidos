import 'package:bloc/bloc.dart';
import 'package:dream_pedidos/models/conversion.dart';
import 'package:dream_pedidos/services/repositories/escandallo_repository.dart';
import 'package:dream_pedidos/utils/event_bus.dart';
import 'package:equatable/equatable.dart';
import '../../utils/file_parser.dart';

part 'file_escandallos_event.dart';
part 'file_escandallos_state.dart';

class FileEscandallosBloc
    extends Bloc<FileEscandallosEvent, FileEscandallosState> {
  final ConversionRepository _conversionRepository;
  FileEscandallosBloc(this._conversionRepository)
      : super(FileEscandallosInitial()) {
    on<FileEscandallosUploadEvent>((event, emit) async {
      emit(FileEscandallosLoading());
      try {
        final conversionDataList =
            await FileParser.parseConversionFile(event.filePath);

        await _conversionRepository.addConversionItems(conversionDataList);

        emit(FileEscandallosUploadSuccess(conversionDataList));
        eventBus.emit('stock_updated');
      } catch (e) {
        emit(FileEscandallosUploadFailure(e.toString()));
      }
    });
  }
}
