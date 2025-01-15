import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../utils/file_parser.dart'; // Utility for parsing files
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

        final yesterday = DateTime.now().subtract(const Duration(days: 1));

// Normalize 'yesterday' to have no time component
        final normalizedYesterday =
            DateTime(yesterday.year, yesterday.month, yesterday.day);

// Check if any date in the sales data list does not match yesterday's date
        final hasInvalidDate = summedSalesData.every((row) {
          final normalizedRowDate =
              DateTime(row.date.year, row.date.month, row.date.day);

          return normalizedRowDate != normalizedYesterday;
        });

        if (hasInvalidDate) {
          emit(FileUploadFailure('Las ventas no son de ayer'));
        } else {
          emit(FileUploadSuccess(summedSalesData));
        }
      } catch (e) {
        emit(FileUploadFailure(e.toString()));
      }
    });
  }
}
