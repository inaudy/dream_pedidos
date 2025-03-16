import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:dream_pedidos/data/models/stock_item.dart';
import 'package:dream_pedidos/utils/format_utils.dart';

class PdfService {
  static const String senderEmail =
      "pedidos.tigotan@gmail.com"; // Your Gmail address
  static const String appPassword =
      "emid yjau sxow wzho"; // Your Gmail App Password
  static const String recipientEmail = //"correojuant@gmail.com";
      "servicios.tigotan@dreamplacehotels.com";

  /// Generates the PDF in memory and returns it as Uint8List.
  static Future<Uint8List> generateStockPdf(
      List<StockItem> stockItems, String posName) async {
    final filteredStockItems = stockItems.where((item) {
      final double refillQuantity =
          (item.maximumLevel - item.actualStock).floorToDouble();
      if (refillQuantity < 1) return false;
      return item.actualStock < item.minimumLevel;
    }).toList();

    final pdf = pw.Document();
    final categorizedData = _categorizeStockItems(filteredStockItems);

    // Build all table rows using a similar approach as before.
    // The first row will be the header.
    List<List<String>> tableRows = [];
    tableRows.add(["Producto", "Cant", "Env?"]); // header row

    categorizedData.forEach((category, items) {
      // Category row (will be styled differently later)
      tableRows.add([category.toUpperCase(), "", ""]);
      // Each item row
      for (var item in items) {
        final double defaultRefill = item.maximumLevel - item.actualStock;
        final double adjustedRefillQuantity = item.errorPercentage > 0
            ? defaultRefill * (1 + (item.errorPercentage / 100)).floorToDouble()
            : defaultRefill.floorToDouble();

        tableRows.add([
          item.itemName.isNotEmpty ? item.itemName : "Desconocido",
          formatForDisplay(adjustedRefillQuantity.floorToDouble()),
          "" // Placeholder for 'Enviado'
        ]);
      }
    });

    // Separate header row from data rows.
    List<List<String>> headerRow = [tableRows.first];
    List<List<String>> dataRows = tableRows.sublist(1);

    // Split data rows evenly into two lists.
    int mid = (dataRows.length / 2).ceil();
    List<List<String>> leftRows = headerRow + dataRows.sublist(0, mid);
    List<List<String>> rightRows = headerRow + dataRows.sublist(mid);

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10), // Smaller margins
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                "Pedido de $posName",
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left Column Table
                pw.Expanded(
                  child: pw.Table(
                    border:
                        pw.TableBorder.all(width: 0.5, color: PdfColors.black),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2.7),
                      1: const pw.FlexColumnWidth(0.3),
                      2: const pw.FlexColumnWidth(0.3),
                    },
                    children: leftRows.map((row) {
                      final bool isHeader = row == headerRow.first;
                      final bool isCategory =
                          row[1] == "" && row[2] == "" && !isHeader;
                      return pw.TableRow(
                        decoration: isCategory
                            ? const pw.BoxDecoration(color: PdfColors.grey300)
                            : null,
                        children: row.map((cell) {
                          return _tableCell(cell, bold: isHeader || isCategory);
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
                pw.SizedBox(width: 10),
                // Right Column Table
                pw.Expanded(
                  child: pw.Table(
                    border:
                        pw.TableBorder.all(width: 0.5, color: PdfColors.black),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2.7),
                      1: const pw.FlexColumnWidth(0.3),
                      2: const pw.FlexColumnWidth(0.3),
                    },
                    children: rightRows.map((row) {
                      final bool isHeader = row == headerRow.first;
                      final bool isCategory =
                          row[1] == "" && row[2] == "" && !isHeader;
                      return pw.TableRow(
                        decoration: isCategory
                            ? const pw.BoxDecoration(color: PdfColors.grey300)
                            : null,
                        children: row.map((cell) {
                          return _tableCell(cell, bold: isHeader || isCategory);
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _tableCell(String text, {bool bold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
          vertical: 4, horizontal: 2), // Consistent padding
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 8, // Smaller font size for compact display
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static Map<String, List<StockItem>> _categorizeStockItems(
      List<StockItem> stockItems) {
    final Map<String, List<StockItem>> categorizedData = {};

    for (var item in stockItems) {
      // If the item has a valid 'traspaso' value, categorize it under that category.
      final String category = (item.traspaso != null &&
              item.traspaso != 'null' &&
              item.traspaso!.isNotEmpty)
          ? 'TRASPASOS ${item.traspaso}-BEACH CLUB'
          : (item.category.isEmpty ? 'Sin Categoría' : item.category);

      categorizedData.putIfAbsent(category, () => []).add(item);
    }

    return categorizedData;
  }

  /// Sends the PDF via Gmail SMTP by writing it to a temporary file.
  static Future<void> sendEmailWithPdf(
      List<StockItem> stockItems, String posName) async {
    try {
      // Generate the PDF in memory.
      final pdfBytes = await generateStockPdf(stockItems, posName);

      // Write the PDF to a temporary file.
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/pedidos_$posName.pdf';
      final tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(pdfBytes);

      // Configure the Gmail SMTP server.
      final smtpServer = gmail(senderEmail, appPassword);

      final message = Message()
        ..from = const Address(senderEmail, "Pedidos App")
        ..recipients.add(recipientEmail)
        ..subject =
            "Pedidos del $posName ${DateFormat('dd/MM/yy').format(DateTime.now())}"
        ..text = "Pedido de $posName adjunto."
        ..attachments.add(FileAttachment(File(tempFilePath)));

      // Send the email.
      final sendReport = await send(message, smtpServer);
      print("✅ Email sent successfully: ${sendReport.toString()}");

      // Optionally, delete the temporary file after sending.
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      print("Error sending email: $e");
    }
  }
}
