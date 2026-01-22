import 'dart:io'; // Tambahan untuk operasi File
import 'dart:typed_data'; // Tambahan untuk Uint8List
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'; // Tambahan
import 'package:share_plus/share_plus.dart'; // Tambahan
import 'dart:math' as math;

// --- IMPORTS ---
// Pastikan path ini sesuai dengan struktur folder project Anda
import '../providers/history_providers.dart';
import '../providers/report_provider.dart';
import 'history_list_page.dart'; 

// --- PALET WARNA ---
const Color _bgPurple = Color(0xFF6C5CE7);
const Color _accentPink = Color(0xFFFF7675);
const Color _cardWhite = Color(0xFFFFFFFF);
const Color _textDark = Color(0xFF2D3436);

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mengambil data histori dari Provider
    final historyAsync = ref.watch(historyListProvider);

    return Scaffold(
      backgroundColor: _bgPurple,
      appBar: AppBar(
        title: const Text(
          'Analitik & Laporan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (e, _) => Center(
          child: Text(
            'Terjadi kesalahan memuat data: $e',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
        data: (records) {
          if (records.isEmpty) {
            return _EmptyState();
          }

          // --- 1. LOGIKA STATISTIK ---
          final tinggi = records.where((r) => r.riskLevel == 'Tinggi').length;
          final sedang = records.where((r) => r.riskLevel == 'Sedang').length;
          final rendah = records.where((r) => r.riskLevel == 'Rendah').length;

          // --- 2. LOGIKA INSIGHT ---
          String insight = 'Pertahankan pola hidup positif Anda!';
          if (tinggi > sedang && tinggi > rendah) {
            insight = 'Risiko tinggi terdeteksi. Pertimbangkan konsultasi profesional.';
          } else if (sedang > rendah) {
            insight = 'Risiko sedang. Coba teknik relaksasi 10 menit hari ini.';
          } else if (rendah > 0) {
            insight = 'Kondisi stabil. Terus jaga kesehatan mental Anda.';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  "Ringkasan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Banner Insight Gradient
                _InsightBanner(insight: insight),
                
                const SizedBox(height: 24),

                // Grafik Sparkline
                _SparklineCard(records: records),

                const SizedBox(height: 24),

                // Statistik Risiko
                const Text(
                  "Statistik Risiko",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _RiskCard(
                        label: 'Rendah',
                        count: rendah,
                        color: const Color(0xFF00B894),
                        icon: Icons.sentiment_satisfied_alt,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RiskCard(
                        label: 'Sedang',
                        count: sedang,
                        color: const Color(0xFFFDCB6E),
                        icon: Icons.sentiment_neutral,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RiskCard(
                        label: 'Tinggi',
                        count: tinggi,
                        color: const Color(0xFFE17055),
                        icon: Icons.sentiment_very_dissatisfied,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Divider Pemisah Area Aksi
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),

                // Area Tombol Aksi (History & PDF & Share)
                _ActionButtonsArea(ref: ref, records: records),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =========================================================
// WIDGET AREA TOMBOL AKSI
// =========================================================

class _ActionButtonsArea extends StatelessWidget {
  final WidgetRef ref;
  final List records;

  const _ActionButtonsArea({
    required this.ref,
    required this.records,
  });

  // --- Helper: Generate PDF Data ---
  Future<Uint8List> _generatePdfData() async {
    final generator = ref.read(reportGeneratorProvider);
    
    // Transform data agar sesuai format ReportGenerator
    final historyData = records.map((r) {
      return {
        'tanggal': DateFormat('dd MMM yyyy').format(r.timestamp),
        'score': r.score,
        'riskLevel': r.riskLevel,
      };
    }).toList();

    // FIXED: Menghapus parameter 'username' agar tidak error
    return await generator.generateReport(
      history: List<Map<String, dynamic>>.from(historyData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tombol History (Navigasi ke Halaman Baru)
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _bgPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryListPage(),
                ),
              );
            },
            icon: const Icon(Icons.history_edu),
            label: const Text(
              'Lihat Riwayat Lengkap',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Baris Tombol PDF & Share
        Row(
          children: [
            // --- TOMBOL UNDUH PDF ---
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Unduh PDF'),
                onPressed: () async {
                  try {
                    // Indikator Loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Membuka PDF...'), duration: Duration(milliseconds: 800)),
                    );

                    final pdfBytes = await _generatePdfData();
                    final previewer = ref.read(reportPreviewProvider);

                    await previewer.previewPdf(
                      onLayout: (_) async => pdfBytes,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gagal membuka PDF: $e")),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            
            // --- TOMBOL SHARE (LOGIKA BARU) ---
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.share),
                label: const Text('Bagikan'),
                onPressed: () async {
                  try {
                    // 1. Tampilkan loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Menyiapkan file untuk dibagikan...'),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    // 2. Generate PDF Bytes
                    final pdfBytes = await _generatePdfData();

                    // 3. Simpan File Sementara di Cache HP
                    final tempDir = await getTemporaryDirectory();
                    final timeStamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
                    final fileName = 'Laporan_InsightMind_$timeStamp.pdf';
                    final file = File('${tempDir.path}/$fileName');
                    
                    await file.writeAsBytes(pdfBytes, flush: true);

                    // 4. Panggil Native Share (WA, Telegram, Email, dll)
                    await Share.shareXFiles(
                      [XFile(file.path)],
                      text: 'Halo, ini hasil laporan kesehatan mental saya dari aplikasi InsightMind.',
                      subject: 'Laporan Kesehatan Mental - InsightMind App', // Subject untuk email
                    );

                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gagal membagikan: $e")),
                    );
                  }
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}

// =========================================================
// WIDGET UI LAINNYA
// =========================================================

class _InsightBanner extends StatelessWidget {
  final String insight;
  const _InsightBanner({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF74B9FF), Color(0xFF0984E3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0984E3).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.lightbulb_outline,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Insight Harian',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _RiskCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bar_chart_rounded,
                size: 80, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          const Text(
            'Data Kosong',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lakukan screening minimal sekali\nuntuk melihat analitik.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: _bgPurple),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Kembali ke Home'),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// LOGIC SPARKLINE CHART
// =========================================================

class _SparklineCard extends StatefulWidget {
  final List records;
  const _SparklineCard({required this.records});

  @override
  State<_SparklineCard> createState() => _SparklineCardState();
}

class _SparklineCardState extends State<_SparklineCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _drawAnimation;
  Offset? _hoveredPoint;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _drawAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String? _getTooltipText() {
    if (_hoveredPoint == null) return null;
    final values = widget.records
        .map<double>((r) => (r.score as num).toDouble())
        .toList();
    if (values.isEmpty) return null;

    final chartWidth = MediaQuery.of(context).size.width - 48;
    final dx = chartWidth / math.max(1, values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = dx * i;
      if ((_hoveredPoint!.dx - x).abs() < 20) {
        return values[i].toStringAsFixed(0);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final values = widget.records
        .map<double>((r) => (r.score as num).toDouble())
        .toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tren Kesehatan Mental',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (values.isNotEmpty)
                    Text(
                      'Skor Terakhir: ${values.last.toInt()}',
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _bgPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.show_chart, color: _bgPurple),
              )
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: MouseRegion(
              onHover: (event) =>
                  setState(() => _hoveredPoint = event.localPosition),
              onExit: (_) => setState(() => _hoveredPoint = null),
              child: GestureDetector(
                onPanUpdate: (details) =>
                    setState(() => _hoveredPoint = details.localPosition),
                onTapDown: (details) =>
                    setState(() => _hoveredPoint = details.localPosition),
                child: Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _drawAnimation,
                      builder: (_, __) {
                        return CustomPaint(
                          painter: _SparklinePainter(
                            values,
                            color: _bgPurple,
                            animationProgress: _drawAnimation.value,
                            hoveredPoint: _hoveredPoint,
                          ),
                          child: const SizedBox.expand(),
                        );
                      },
                    ),
                    if (_hoveredPoint != null && _getTooltipText() != null)
                      Positioned(
                        left: (_hoveredPoint!.dx - 20).clamp(0.0, 300.0),
                        top: (_hoveredPoint!.dy - 50).clamp(0.0, 150.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _accentPink,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _accentPink.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Text(
                            "Skor: ${_getTooltipText()}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tanggal Awal & Akhir
          if (widget.records.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('d MMM').format(widget.records.first.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                Text(
                  DateFormat('d MMM').format(widget.records.last.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final double animationProgress;
  final Offset? hoveredPoint;

  _SparklinePainter(
    this.values, {
    this.color = Colors.indigo,
    this.animationProgress = 1.0,
    this.hoveredPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.3 * animationProgress),
          color.withOpacity(0.0 * animationProgress),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    double min = values.reduce(math.min);
    double max = values.reduce(math.max);
    if (max == min) {
      max += 5;
      min -= 5;
    }
    final range = max - min;
    final bottomPadding = 10.0;

    final dx = size.width / math.max(1, values.length - 1);
    final maxIndex = (values.length * animationProgress).ceil();

    final path = Path();

    for (int i = 0; i < values.length; i++) {
      if (i > maxIndex) break;
      final x = dx * i;
      final normalizedY = (values[i] - min) / range;
      final y = (size.height - bottomPadding) -
          (normalizedY * (size.height - bottomPadding));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(math.min(size.width, dx * (maxIndex - 1).clamp(0, values.length)),
          size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw Markers
    for (int i = 0; i <= maxIndex && i < values.length; i++) {
      final x = dx * i;
      final normalizedY = (values[i] - min) / range;
      final y = (size.height - bottomPadding) -
          (normalizedY * (size.height - bottomPadding));

      canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(x, y), 4,
          Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2);

      if (hoveredPoint != null &&
          (Offset(x, y) - hoveredPoint!).distance < 30) {
        canvas.drawCircle(
          Offset(x, y),
          15,
          Paint()..color = _accentPink.withOpacity(0.3),
        );
        canvas.drawCircle(
          Offset(x, y),
          8,
          Paint()..color = _accentPink,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.hoveredPoint != hoveredPoint;
  }
}