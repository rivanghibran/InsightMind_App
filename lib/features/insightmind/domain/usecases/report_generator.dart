import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Import Firebase Auth

class ReportGenerator {
  // Palet Warna Tema (Konversi Hex ke PdfColor)
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF6C5CE7); // Ungu
  static const PdfColor accentColor = PdfColor.fromInt(0xFFFF7675);  // Pink
  static const PdfColor lightBg = PdfColor.fromInt(0xFFF3F0FF);      // Ungu Muda Pudar
  static const PdfColor darkText = PdfColor.fromInt(0xFF2D3436);
  static const PdfColor white = PdfColor.fromInt(0xFFFFFFFF);

  Future<Uint8List> generateReport({
    // Parameter username dihapus karena diambil otomatis dari Firebase
    required List<Map<String, dynamic>> history,
  }) async {
    final pdf = pw.Document();

    // 2. AMBIL DATA USER DARI FIREBASE
    final user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? 'Tanpa Nama';
    final String email = user?.email ?? '-';

    final now = DateTime.now();
    // Format Tanggal
    final String printedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(now);
    // Format Jam
    final String printedTime = DateFormat('HH:mm').format(now);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(40),
          buildBackground: (context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Container(
                // Dekorasi watermark atau garis tepi jika diinginkan
              ),
            );
          },
        ),
        header: (context) => _buildHeader(printedDate, printedTime),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Pass nama dan email ke fungsi builder
          _buildUserInfo(displayName, email, history),
          pw.SizedBox(height: 20),
          _buildTable(history),
          pw.SizedBox(height: 20),
          _buildSummary(history),
        ],
      ),
    );

    return pdf.save();
  }

  // 1. Header
  pw.Widget _buildHeader(String date, String time) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Bagian Kiri: Teks Nama Aplikasi
            pw.Text(
              'InsightMind App',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
            
            // Bagian Kanan: Judul Laporan, Tanggal, dan JAM
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('MENTAL HEALTH REPORT', style: pw.TextStyle(fontSize: 10, color: accentColor, letterSpacing: 2)),
                pw.SizedBox(height: 4),
                pw.Text('$date', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                pw.Text('Pukul $time', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: primaryColor, thickness: 1.5),
        pw.SizedBox(height: 20),
      ],
    );
  }

  // 2. Info Pengguna (Updated dengan Email)
  pw.Widget _buildUserInfo(String username, String email, List<Map<String, dynamic>> history) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: lightBg,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: primaryColor.flatten(), width: 0.5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Informasi Pengguna', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              pw.SizedBox(height: 4),
              // Nama User
              pw.Text(username, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: darkText)),
              // Email User (Baru)
              pw.Text(email, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Total Pemeriksaan', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              pw.SizedBox(height: 4),
              pw.Text('${history.length} Kali', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Tabel Modern
  pw.Widget _buildTable(List<Map<String, dynamic>> history) {
    return pw.Table.fromTextArray(
      headers: ['No', 'Tanggal', 'Skor', 'Status Risiko'],
      data: List<List<dynamic>>.generate(history.length, (index) {
        final item = history[index];
        return [
          (index + 1).toString(),
          item['tanggal'] ?? '-',
          item['score']?.toString() ?? '0',
          item['riskLevel'] ?? '-',
        ];
      }),
      border: null, 
      headerStyle: pw.TextStyle(color: white, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(
        color: primaryColor,
        borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(4)),
      ),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
      ),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
      },
      oddRowDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF8F9FA)),
    );
  }

  // 4. Ringkasan & Disclaimer
  pw.Widget _buildSummary(List<Map<String, dynamic>> history) {
    if (history.isEmpty) return pw.SizedBox();
    
    double totalScore = 0;
    for (var h in history) {
      totalScore += (h['score'] as num? ?? 0).toDouble();
    }
    double avgScore = totalScore / history.length;

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: accentColor, width: 4)),
        color: PdfColors.grey50
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("Ringkasan Analisis", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
          pw.SizedBox(height: 5),
          pw.Text("Rata-rata skor kesehatan mental Anda adalah ${avgScore.toStringAsFixed(1)}.", style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 5),
          pw.Text(
            'Laporan ini digenerate secara otomatis oleh sistem InsightMind.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  // 5. Footer Halaman
  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        children: [
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Disclaimer: Bukan pengganti diagnosis medis profesional.',
                style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic, color: PdfColors.grey500),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}