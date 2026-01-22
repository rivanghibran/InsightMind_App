// WEEK 6: CAMERA-BASED PPG-LIKE PROVIDER
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. STATE: Ditambahkan field 'controller'
class PpgState {
  final bool capturing;
  final List<double> samples;
  final double mean;
  final double variance;
  final CameraController? controller; // <--- TAMBAHAN PENTING

  PpgState({
    required this.capturing,
    required this.samples,
    required this.mean,
    required this.variance,
    this.controller, // <--- Masukkan ke constructor
  });

  PpgState copyWith({
    bool? capturing,
    List<double>? samples,
    double? mean,
    double? variance,
    CameraController? controller, // <--- Tambahkan di copyWith
  }) {
    return PpgState(
      capturing: capturing ?? this.capturing,
      samples: samples ?? this.samples,
      mean: mean ?? this.mean,
      variance: variance ?? this.variance,
      controller: controller ?? this.controller, // <--- Update logic
    );
  }
}

/// Provider untuk state PPG
final ppgProvider = StateNotifierProvider<PpgNotifier, PpgState>((ref) {
  return PpgNotifier();
});

class PpgNotifier extends StateNotifier<PpgState> {
  PpgNotifier()
      : super(
          PpgState(
            capturing: false,
            samples: [],
            mean: 0,
            variance: 0,
            controller: null,
          ),
        );

  CameraController? _controller;

  Future<void> startCapture() async {
    try {
      final cameras = await availableCameras();
      
      // Pilih kamera belakang, atau kamera pertama jika tidak ada
      final cam = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        cam,
        ResolutionPreset.low, // Resolusi rendah lebih cepat diproses
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      // PENTING: Nyalakan Flash untuk PPG
      await _controller!.setFlashMode(FlashMode.torch);

      // Update state awal: capturing TRUE dan simpan CONTROLLER
      state = state.copyWith(
        capturing: true,
        controller: _controller,
        samples: [], // Reset sampel lama
      );

      _controller!.startImageStream((image) {
        // Kanal Y (luminance/kecerahan) berada pada plane pertama
        final plane = image.planes[0];
        final buffer = plane.bytes;

        // Sampling per 50 byte agar efisien (mengurangi beban CPU)
        double sum = 0;
        int count = 0;

        for (int i = 0; i < buffer.length; i += 50) {
          sum += buffer[i];
          count++;
        }

        final meanY = sum / count;

        // Sliding window 300 sampel
        final newSamples = [...state.samples, meanY];
        if (newSamples.length > 300) {
          newSamples.removeAt(0);
        }

        // Hitung statistik (Mean & Variance)
        final mean = newSamples.isEmpty 
            ? 0.0 
            : newSamples.reduce((a, b) => a + b) / newSamples.length;

        final variance = newSamples.isEmpty 
            ? 0.0 
            : newSamples.fold<double>(
                  0.0,
                  (s, x) => s + pow(x - mean, 2),
                ) /
                max(1, newSamples.length - 1);

        // Update state secara realtime
        // Catatan: Di production, sebaiknya ini di-throttle agar tidak merender UI 30fps
        if (state.capturing) {
          state = state.copyWith(
            samples: newSamples,
            mean: mean,
            variance: variance,
            // Controller tidak perlu di-pass lagi di sini karena sudah ada di state
          );
        }
      });
    } catch (e) {
      print("Error starting PPG: $e");
      stopCapture();
    }
  }

  Future<void> stopCapture() async {
    if (_controller != null) {
      try {
        // Matikan flash sebelum stop
        await _controller!.setFlashMode(FlashMode.off);
        await _controller!.stopImageStream();
        await _controller!.dispose();
      } catch (e) {
        // Ignore error saat dispose
      }
      _controller = null;
    }

    // Reset state: capturing FALSE dan controller NULL
    state = state.copyWith(
      capturing: false, 
      controller: null
    );
  }
}