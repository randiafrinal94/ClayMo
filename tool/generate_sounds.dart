// Menghasilkan efek suara interaksi Claymo (WAV 16-bit mono) tanpa aset eksternal.
//
// Jalankan dari root proyek:
//   dart run tool/generate_sounds.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int _sampleRate = 44100;

/// Satu nada: [freqStart] -> [freqEnd] (sweep), selubung atack cepat + decay eksponensial.
List<double> _note({
  required double freqStart,
  double? freqEnd,
  required double seconds,
  double amp = 0.6,
  double decay = 6,
  double harmonic = 0.0,
}) {
  final n = (seconds * _sampleRate).round();
  final out = List<double>.filled(n, 0);
  double phase = 0;
  for (var i = 0; i < n; i++) {
    final t = i / _sampleRate;
    final k = i / n;
    final f = freqStart + ((freqEnd ?? freqStart) - freqStart) * k;
    phase += 2 * math.pi * f / _sampleRate;
    final attack = math.min(1.0, t / 0.004);
    final env = attack * math.exp(-decay * k);
    final s = math.sin(phase) + harmonic * math.sin(phase * 2);
    out[i] = s * env * amp;
  }
  return out;
}

/// Gabungkan beberapa nada pada offset waktu tertentu.
List<double> _mix(List<MapEntry<double, List<double>>> parts) {
  var total = 0;
  for (final p in parts) {
    total = math.max(total, (p.key * _sampleRate).round() + p.value.length);
  }
  final out = List<double>.filled(total, 0);
  for (final p in parts) {
    final start = (p.key * _sampleRate).round();
    for (var i = 0; i < p.value.length; i++) {
      out[start + i] += p.value[i];
    }
  }
  return out;
}

Uint8List _wav(List<double> samples) {
  final peak = samples.fold<double>(0, (m, s) => math.max(m, s.abs()));
  final gain = peak > 0.9 ? 0.9 / peak : 1.0;
  final data = ByteData(samples.length * 2);
  for (var i = 0; i < samples.length; i++) {
    final v = (samples[i] * gain).clamp(-1.0, 1.0);
    data.setInt16(i * 2, (v * 32767).round(), Endian.little);
  }
  final header = ByteData(44);
  void tag(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      header.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  tag(0, 'RIFF');
  header.setUint32(4, 36 + data.lengthInBytes, Endian.little);
  tag(8, 'WAVE');
  tag(12, 'fmt ');
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little); // PCM
  header.setUint16(22, 1, Endian.little); // mono
  header.setUint32(24, _sampleRate, Endian.little);
  header.setUint32(28, _sampleRate * 2, Endian.little);
  header.setUint16(32, 2, Endian.little);
  header.setUint16(34, 16, Endian.little);
  tag(36, 'data');
  header.setUint32(40, data.lengthInBytes, Endian.little);
  return (BytesBuilder()
        ..add(header.buffer.asUint8List())
        ..add(data.buffer.asUint8List()))
      .toBytes();
}

void main() {
  final dir = Directory('assets/sounds')..createSync(recursive: true);

  final sounds = <String, List<double>>{
    // Pop empuk saat tombol clay ditekan.
    'pop': _note(freqStart: 720, freqEnd: 260, seconds: 0.14, decay: 7, harmonic: 0.15),
    // Tap ringan.
    'tap': _note(freqStart: 440, freqEnd: 340, seconds: 0.09, amp: 0.5, decay: 8),
    // Huruf masuk ke slot: bloop naik.
    'place': _note(freqStart: 480, freqEnd: 820, seconds: 0.16, decay: 5, harmonic: 0.2),
    // Chime sukses: arpeggio C5-E5-G5-C6.
    'success': _mix([
      for (final e in [
        MapEntry(0.00, 523.25),
        MapEntry(0.09, 659.25),
        MapEntry(0.18, 783.99),
        MapEntry(0.27, 1046.5),
      ])
        MapEntry(e.key, _note(freqStart: e.value, seconds: 0.55, amp: 0.45, decay: 5, harmonic: 0.3)),
    ]),
    // Bintang: lonceng berkilau.
    'star': _mix([
      MapEntry(0.00, _note(freqStart: 1318.5, seconds: 0.7, amp: 0.4, decay: 5, harmonic: 0.25)),
      MapEntry(0.08, _note(freqStart: 1975.5, seconds: 0.7, amp: 0.35, decay: 5, harmonic: 0.2)),
      MapEntry(0.16, _note(freqStart: 2637.0, seconds: 0.6, amp: 0.25, decay: 6)),
    ]),
    // Chime sambutan splash (~1.4 dtk): arpeggio naik C5-E5-G5-C6, ditutup akord manis.
    'welcome': _mix([
      for (final e in [
        MapEntry(0.00, 523.25),
        MapEntry(0.12, 659.25),
        MapEntry(0.24, 783.99),
        MapEntry(0.36, 1046.5),
      ])
        MapEntry(e.key, _note(freqStart: e.value, seconds: 0.5, amp: 0.4, decay: 5, harmonic: 0.3)),
      for (final f in [523.25, 659.25, 783.99, 1046.5, 1318.5])
        MapEntry(0.55, _note(freqStart: f, seconds: 0.85, amp: 0.22, decay: 4, harmonic: 0.25)),
    ]),
    // Salah: boop turun yang lembut (tidak menakutkan).
    'wrong': _note(freqStart: 340, freqEnd: 210, seconds: 0.26, amp: 0.5, decay: 4, harmonic: 0.1),
  };

  sounds.forEach((name, samples) {
    final file = File('${dir.path}/$name.wav')..writeAsBytesSync(_wav(samples));
    stdout.writeln('${file.path} (${file.lengthSync()} bytes)');
  });
}
