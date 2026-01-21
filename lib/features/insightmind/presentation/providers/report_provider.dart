import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import 'package:tugas_kelompok/features/insightmind/domain/usecases/report_generator.dart';

/// Provider untuk usecase ReportGenerator
/// Jika nanti implementasi berubah, cukup ganti di sini
final reportGeneratorProvider = Provider<ReportGenerator>((ref) {
  return ReportGenerator();
});

/// Provider untuk layanan preview/print PDF
/// Dibuat sebagai provider agar UI tetap bersih
final reportPreviewProvider = Provider<ReportPreviewService>((ref) {
  return ReportPreviewService();
});

class ReportPreviewService {
  Future<void> previewPdf({
    required Future<Uint8List> Function(PdfPageFormat format) onLayout,
  }) async {
    await Printing.layoutPdf(onLayout: onLayout);
  }
}
