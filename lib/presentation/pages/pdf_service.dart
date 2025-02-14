import 'dart:io';
import 'dart:typed_data';
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Pedido de $posName",
                style:
                    pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              _buildStockTable(stockItems),
            ],
          );
        },
      ),
    );

    return pdf.save(); // Returns PDF as Uint8List (in memory)
  }

  /// Builds the stock refill table for the PDF.
  static pw.Widget _buildStockTable(List<StockItem> stockItems) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(width: 1, color: PdfColors.black),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellAlignment: pw.Alignment.centerLeft,
      headers: ['Producto', 'Reponer', 'Enviado'],
      data: stockItems.map((item) {
        final double refillQuantity =
            (item.maximumLevel - item.actualStock).clamp(0, item.maximumLevel);
        return [
          item.itemName,
          formatForDisplay(refillQuantity),
          "", // Placeholder for "Enviado" column
        ];
      }).toList(),
    );
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
        ..subject = "Pedidos del $posName"
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
