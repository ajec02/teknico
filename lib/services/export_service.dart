// Serviço de Exportação para Excel (.xlsx) e PDF com Suporte às Regras do Relatório (Relrel)

import 'dart:io';
import 'package:excel/excel.dart' as xl;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExportService {
  /// Exporta a lista de registos para Excel (.xlsx)
  static Future<String?> exportToExcel({
    required String title,
    required String tableName,
    required List<String> columns,
    required List<Map<String, dynamic>> records,
  }) async {
    try {
      final excel = xl.Excel.createExcel();
      final sheet = excel[excel.getDefaultSheet() ?? 'Folha1'];

      // Cabeçalho do Relatório
      sheet.appendRow([
        xl.TextCellValue('SISTEMA SUPORTE - RELATÓRIO DE DADOS'),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Tabela: $tableName | Data de Emissão: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}'),
      ]);
      sheet.appendRow([]); // Linha em branco

      // Nomes das Colunas
      sheet.appendRow(columns.map((c) => xl.TextCellValue(c)).toList());

      // Linhas de Registos
      for (final row in records) {
        final List<xl.CellValue> cellValues = [];
        for (final col in columns) {
          final val = row[col];
          cellValues.add(xl.TextCellValue(val?.toString() ?? ''));
        }
        sheet.appendRow(cellValues);
      }

      final fileBytes = excel.encode();
      if (fileBytes == null) return null;

      final String fileName = 'Relatorio_${tableName}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final result = await FilePicker.saveFile(
        dialogTitle: 'Guardar Ficheiro Excel',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsBytes(fileBytes);
        return result;
      }
    } catch (e) {
      print("Aviso ao guardar Excel: $e");
    }
    return null;
  }

  /// Exporta a lista de registos para PDF com layout corporativo elegante (Relrel)
  static Future<void> exportToPdf({
    required String title,
    required String databaseName,
    required String tableName,
    required List<String> columns,
    required List<Map<String, dynamic>> records,
    required String emittedBy,
  }) async {
    final pdf = pw.Document();
    final creationDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    final qrData = "Sistema: Suporte OS\nBase de Dados: $databaseName\nTabela: $tableName\nEmitido por: $emittedBy\nData: $creationDate\nTotal Registos: ${records.length}";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SUPORTE - GESTÃO DE BASES DE DADOS',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        'Empresa: Antigravity Tech Solutions',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Contacto: suporte@antigravity.pt | +244 923 000 000',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue800,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      'LOGÓTIPO SUPORTE',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1, color: PdfColors.blue900),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Relatório: $title (Tabela: $tableName)',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Emitido Por: $emittedBy | Data: $creationDate',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                ],
              ),
              pw.SizedBox(height: 10),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Software: Sistema Operativo Suporte OS (v1.0.0)',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.Text('Página ${context.pageNumber} de ${context.pagesCount}',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: qrData,
                    width: 40,
                    height: 40,
                  ),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            pw.TableHelper.fromTextArray(
              headers: columns,
              data: records.map((r) => columns.map((c) => r[c]?.toString() ?? '').toList()).toList(),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Relatorio_${tableName}.pdf',
    );
  }
}
