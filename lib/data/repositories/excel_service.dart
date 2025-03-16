import 'dart:io';
import 'dart:typed_data';
import 'package:dream_pedidos/data/repositories/stock_repository.dart';
import 'package:excel/excel.dart';
import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';

class ExcelService {
  static const String senderEmail =
      "pedidos.tigotan@gmail.com"; // Your Gmail address
  static const String appPassword =
      "emid yjau sxow wzho"; // Your Gmail App Password
  static const String recipientEmail = "correojuant@gmail.com";
  // You can adjust the recipient email if needed.

  /// Generates an Excel file from the provided stock items.
  static Future<Uint8List> generateStockExcel(
      List<StockItem> stockItems, String posName) async {
    var excel = Excel.createExcel();
    // Get the default sheet (named "Sheet1" by default) or create one called "Stock".
    Sheet sheetObject = excel['Sheet1'];
    int rowIndex = 0;

    // Build header row using the new CellValue classes from excel 4.0.6.
    List<CellValue> headerRow = [
      TextCellValue("Item Name"),
      TextCellValue("Actual Stock"),
      TextCellValue("Minimum Level"),
      TextCellValue("Maximum Level"),
      TextCellValue("Category"),
      TextCellValue("Traspaso"),
      TextCellValue("EAN Code"),
      TextCellValue("Error Percentage"),
    ];
    sheetObject.insertRowIterables(headerRow, rowIndex);
    rowIndex++;

    // Insert a data row for each stock item.
    for (var item in stockItems) {
      List<CellValue> dataRow = [
        TextCellValue(item.itemName),
        DoubleCellValue(item.actualStock),
        DoubleCellValue(item.minimumLevel),
        DoubleCellValue(item.maximumLevel),
        TextCellValue(item.category),
        TextCellValue(item.traspaso ?? ""),
        TextCellValue(item.eanCode ?? ""),
        TextCellValue(item.errorPercentage.toString()),
      ];
      sheetObject.insertRowIterables(dataRow, rowIndex);
      rowIndex++;
    }

    final fileBytes = excel.encode();
    return Uint8List.fromList(fileBytes!);
  }

  /// Sends the Excel file via email as an attachment.
  static Future<void> sendEmailWithExcelFromDB(
      StockRepository repository, String posName) async {
    try {
      // Get the full, updated stock list directly from SQLite.
      List<StockItem> stockItems = await repository.getAllStockItems();

      // Generate the Excel file from the stock list.
      final excelBytes = await generateStockExcel(stockItems, posName);

      // Write the Excel file to a temporary file.
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/stock_$posName.xlsx';
      final tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(excelBytes);

      // Configure the Gmail SMTP server.
      final smtpServer = gmail(senderEmail, appPassword);

      final message = Message()
        ..from = Address(senderEmail, "Pedidos App")
        ..recipients.add(recipientEmail)
        ..subject =
            "Stock List for $posName ${DateFormat('dd/MM/yy').format(DateTime.now())}"
        ..text = "Please find attached the stock list for $posName."
        ..attachments.add(FileAttachment(File(tempFilePath)));

      final sendReport = await send(message, smtpServer);
      print("✅ Email sent successfully: ${sendReport.toString()}");

      // Optionally, delete the temporary file.
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      print("Error sending email: $e");
    }
  }
}
