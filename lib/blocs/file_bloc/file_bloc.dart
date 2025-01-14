import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '/utils/file_parser.dart'; // Utility for parsing files
import '/models/sales_data.dart';

part 'file_event.dart';
part 'file_state.dart';

class FileBloc extends Bloc<FileEvent, FileState> {
  FileBloc() : super(FileInitial()) {
    on<FileUploadEvent>((event, emit) async {
      emit(FileLoading());
      try {
        final salesDataList = await FileParser.parseFile(event.filePath);
        // Sum the sales data for the same items
        final summedSalesData = FileParser.sumSales(salesDataList);
        emit(FileUploadSuccess(summedSalesData));
      } catch (e) {
        emit(FileUploadFailure(e.toString()));
      }
    });
  }
}
