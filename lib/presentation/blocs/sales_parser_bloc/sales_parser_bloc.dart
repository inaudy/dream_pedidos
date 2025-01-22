import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dream_pedidos/data/datasources/external/file_parser.dart';
import 'package:dream_pedidos/data/models/sales_data.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
part 'sales_parser_event.dart';
part 'sales_parser_state.dart';

class SalesParserBloc extends Bloc<SalesParserEvent, SalesParserState> {
  SalesParserBloc() : super(SalesParserInitial()) {
    on<SalesParserUploadEvent>(_onUploadFile);
    on<SalesParserPickFileEvent>(_onPickFile);
  }

  Future<void> _onPickFile(
      SalesParserPickFileEvent event, Emitter<SalesParserState> emit) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        add(SalesParserUploadEvent(filePath));
      } else {
        emit(SalesParserFailure("No file selected"));
      }
    } catch (e) {
      emit(SalesParserFailure("Failed to pick a file: ${e.toString()}"));
    }
  }

  Future<void> _onUploadFile(
      SalesParserUploadEvent event, Emitter<SalesParserState> emit) async {
    emit(SalesParserLoading());

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
        emit(SalesParserFailure('Las ventas no son de ayer'));
      } else {
        emit(SalesParserSuccess(summedSalesData));
      }
    } catch (e) {
      emit(SalesParserFailure(e.toString()));
    }
  }
}
