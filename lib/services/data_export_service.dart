import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:wealthwise/features/transactions/transaction_model.dart';
import 'package:share_plus/share_plus.dart';

class DataExportService {
  Future<void> exportToCSV(List<TransactionModel> transactions) async {
    List<List<dynamic>> rows = [];
    rows.add(['ID', 'Date', 'Type', 'Category', 'Merchant', 'Amount (Cents)', 'Payment Method', 'Notes']);

    for (var tx in transactions) {
      rows.add([
        tx.id,
        tx.date.toIso8601String(),
        tx.type.name,
        tx.category,
        tx.merchantName ?? '',
        tx.amount,
        tx.paymentMethod,
        tx.notes ?? ''
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/wealthwise_export.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'My Wealthwise Transactions');
  }

  Future<void> exportToPDF(List<TransactionModel> transactions, String userName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Wealthwise Financial Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Report for: $userName'),
              pw.Text('Generated on: ${DateTime.now().toLocal()}'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Category', 'Merchant', 'Amount'],
                data: transactions.map((tx) => [
                  tx.date.toString().substring(0, 10),
                  tx.category,
                  tx.merchantName ?? '-',
                  '${(tx.amount / 100).toStringAsFixed(2)}'
                ]).toList(),
              ),
            ],
          );
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/wealthwise_report.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: 'My Wealthwise Financial Report');
  }
}
