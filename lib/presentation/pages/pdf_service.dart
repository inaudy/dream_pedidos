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
      "servicios.tigotan@dreamplacehotels.com"; // Change to recipient email

  /// Generates the PDF in memory and returns it as Uint8List.
  static Future<Uint8List> generateStockPdf(
      List<StockItem> stockItems, String posName) async {
    final pdf = pw.Document();
    final categorizedData = _categorizeStockItems(stockItems);
    pdf.addPage(
      pw.MultiPage(
        margin: pw.EdgeInsets.all(25),
        pageFormat: PdfPageFormat.a4,
        // ✅ Minimized margins
        build: (pw.Context context) {
          List<List<String>> tableData = [];
          List<pw.Widget> tableWidgets = [];

          // ✅ Headers only at the start of each page
          tableData.add(["Producto", "Reponer", "Enviado"]); // Header Row

          // ✅ Generate table with category and stock rows
          categorizedData.forEach((category, items) {
            // ✅ Category row (Bold, Gray Background)
            tableData.add([category.toUpperCase(), "", ""]);

            // ✅ Item rows
            for (var item in items) {
              final double refillQuantity =
                  (item.maximumLevel - item.actualStock)
                      .clamp(0, item.maximumLevel);

              tableData.add([
                item.itemName.isNotEmpty ? item.itemName : "Desconocido",
                formatForDisplay(refillQuantity),
                "", // Placeholder
              ]);
            }
          });

          // ✅ Create structured table
          tableWidgets.add(
            pw.Table(
              border: pw.TableBorder.all(
                  width: 0.5, color: PdfColors.black), // ✅ Uniform Borders
              columnWidths: {
                0: pw.FlexColumnWidth(2), // ✅ Make "Producto" column wider
                1: pw.FlexColumnWidth(1), // ✅ Keep "Reponer" smaller
                2: pw.FlexColumnWidth(1), // ✅ "Enviado" column width
              },
              children: tableData.map((row) {
                final isHeader = row[0] == "Producto";
                final isCategory = row[1] == "" && row[2] == "";

                return pw.TableRow(
                  decoration: isCategory
                      ? pw.BoxDecoration(
                          color: PdfColors.grey300) // ✅ Category Background
                      : null,
                  children: row.map((cell) {
                    return _tableCell(cell, bold: isHeader || isCategory);
                  }).toList(),
                );
              }).toList(),
            ),
          );

          return [
            pw.Text(
              "Pedido de $posName",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            ...tableWidgets, // ✅ Structured table
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildStockTable(List<StockItem> stockItems) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellStyle: pw.TextStyle(fontSize: 9),
      cellPadding: const pw.EdgeInsets.symmetric(
          vertical: 2, horizontal: 2), // ✅ Reduce cell padding

      cellAlignments: {
        1: pw.Alignment.center, // Center "Reponer"
      },

      data: stockItems.map((item) {
        final double refillQuantity =
            (item.maximumLevel - item.actualStock).clamp(0, item.maximumLevel);
        return [
          item.itemName.isNotEmpty ? item.itemName : "Desconocido",
          formatForDisplay(refillQuantity),
          "", // Placeholder to avoid empty columns
        ];
      }).toList(),
    );
  }

  static pw.Widget _tableCell(String text, {bool bold = false}) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(
          vertical: 4, horizontal: 2), // ✅ Consistent Padding
      alignment: pw.Alignment.centerLeft, // ✅ Keep alignment consistent
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static Map<String, List<StockItem>> _categorizeStockItems(
      List<StockItem> stockItems) {
    final Map<String, List<StockItem>> categorizedData = {};

    for (var item in stockItems) {
      final String category =
          item.category.isEmpty ? 'Sin Categoría' : item.category;
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
        ..from = Address(senderEmail, "Pedidos App")
        ..recipients.add(recipientEmail)
        ..subject =
            "Pedidos del $posName ${DateFormat('dd/MM/yy').format(DateTime.now())}"
        ..text = "Pedido de $posName adjunto."
        // Attach the file from the temporary folder.
        ..attachments.add(FileAttachment(File(tempFilePath)));

      // Send the email.
      final sendReport = await send(message, smtpServer);
      print("✅ Email sent successfully: ${sendReport.toString()}");

      // Optionally, delete the temporary file after sending.
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      print("❌ Error sending email: $e");
    }
  }
}
