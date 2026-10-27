// Bump versi otomatis Claymo (SemVer + Conventional Commits) -> menulis `version: X.Y.Z+N`
// ke pubspec.yaml sebelum `flutter build apk --release`.
//
// Jalankan dari root proyek:
//   dart run tool/version_bumper.dart                 # hitung & tulis ke pubspec.yaml
//   dart run tool/version_bumper.dart --dry-run       # hanya tampilkan hasilnya
//   dart run tool/version_bumper.dart --tag           # + buat git tag lokal vX.Y.Z (tidak di-push)
//   dart run tool/version_bumper.dart --bump minor    # paksa jenis bump (major|minor|patch|none)
//   dart run tool/version_bumper.dart --set 1.4.0     # paksa versi (dipakai CI)
//   dart run tool/version_bumper.dart --build-number 42
//
// Aturan (sejak git tag `vX.Y.Z` terakhir):
//   MAJOR  `feat!:` / `fix!:` (tipe apa pun dengan `!`) atau footer `BREAKING CHANGE:`
//   MINOR  `feat:`
//   PATCH  `fix:` `perf:` `refactor:`
//   (docs/chore/style/test/ci/build tidak menaikkan versi)
// Build number = `git rev-list --count HEAD` kecuali diberikan lewat --build-number.
//
// Basis versi adalah tag terakhir (bukan pubspec.yaml) supaya menjalankan skrip berulang kali
// tidak menaikkan versi dua kali. Tanpa tag sama sekali, pubspec.yaml dipakai apa adanya
// (hanya build number yang diperbarui); buat tag awal dengan `git tag v0.1.0 <commit>`.
import 'dart:convert';
import 'dart:io';

/// Jenis kenaikan versi; urutan enum = tingkat keparahan (yang lebih besar menang).
enum BumpType { none, patch, minor, major }

class SemVer {
  const SemVer(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  static final _pattern = RegExp(r'^(\d+)\.(\d+)\.(\d+)$');

  static SemVer? tryParse(String text) {
    final m = _pattern.firstMatch(text.trim());
    if (m == null) return null;
    return SemVer(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
  }

  SemVer bump(BumpType type) => switch (type) {
        BumpType.major => SemVer(major + 1, 0, 0),
        BumpType.minor => SemVer(major, minor + 1, 0),
        BumpType.patch => SemVer(major, minor, patch + 1),
        BumpType.none => this,
      };

  @override
  String toString() => '$major.$minor.$patch';
}

final _header = RegExp(r'^(\w+)(?:\([^)]*\))?(!)?:\s');
final _breakingFooter = RegExp(r'^BREAKING[ -]CHANGE:', multiLine: true);

/// Jenis bump untuk satu pesan commit (Conventional Commits).
BumpType bumpForCommit(String message) {
  final text = message.trim();
  if (_breakingFooter.hasMatch(text)) return BumpType.major;
  final m = _header.firstMatch(text);
  if (m == null) return BumpType.none;
  if (m[2] != null) return BumpType.major;
  return switch (m[1]!.toLowerCase()) {
    'feat' => BumpType.minor,
    'fix' || 'perf' || 'refactor' => BumpType.patch,
    _ => BumpType.none,
  };
}

/// Bump tertinggi dari sekumpulan pesan commit.
BumpType determineBump(Iterable<String> messages) {
  var result = BumpType.none;
  for (final message in messages) {
    final b = bumpForCommit(message);
    if (b.index > result.index) result = b;
  }
  return result;
}

final _versionLine = RegExp(r'^version:.*$', multiLine: true);

/// Mengganti baris `version:` pertama pada isi pubspec; sisa file (termasuk CRLF) tidak disentuh.
String replaceVersionLine(String pubspec, String version) {
  if (!_versionLine.hasMatch(pubspec)) {
    throw const FormatException('Baris "version:" tidak ditemukan di pubspec.yaml.');
  }
  return pubspec.replaceFirst(_versionLine, 'version: $version');
}

final _pubspecVersion = RegExp(r'^version:\s*(\d+\.\d+\.\d+)(?:\+(\d+))?', multiLine: true);

({SemVer version, int build})? readPubspecVersion(String pubspec) {
  final m = _pubspecVersion.firstMatch(pubspec);
  if (m == null) return null;
  return (version: SemVer.tryParse(m[1]!)!, build: int.tryParse(m[2] ?? '') ?? 0);
}

/// Build number dari jumlah commit, tetapi tidak pernah <= build yang sudah ada di pubspec:
/// versionCode Android yang turun/sama membuat APK tidak bisa meng-update aplikasi terpasang.
int nextBuildNumber(int commitCount, int currentBuild) =>
    commitCount > currentBuild ? commitCount : currentBuild + 1;

// --- Git ----------------------------------------------------------------------

late final String _root;

String _git(List<String> args) {
  final r = Process.runSync(
    'git',
    args,
    workingDirectory: _root,
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  if (r.exitCode != 0) {
    throw ProcessException('git', args, '${r.stderr}'.trim(), r.exitCode);
  }
  return '${r.stdout}';
}

/// Tag `vX.Y.Z` tertinggi yang terjangkau dari HEAD (pre-release seperti v1.0.0-rc.1 diabaikan).
({String name, SemVer version})? _latestTag() {
  final names = _git(['tag', '--merged', 'HEAD', '--list', 'v*', '--sort=-v:refname'])
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty);
  for (final name in names) {
    final v = SemVer.tryParse(name.substring(1));
    if (v != null) return (name: name, version: v);
  }
  return null;
}

/// (hash pendek, pesan lengkap) untuk setiap commit di [range].
List<({String hash, String message})> _commits(String range) {
  final raw = _git(['log', range, '--format=%h%x1f%B%x1e']);
  return [
    for (final record in raw.split('\x1e'))
      if (record.trim().isNotEmpty)
        (
          hash: record.trim().split('\x1f').first,
          message: record.trim().split('\x1f').skip(1).join('\x1f'),
        ),
  ];
}

// --- CLI ----------------------------------------------------------------------

class _Options {
  bool dryRun = false;
  bool tag = false;
  BumpType? bump;
  SemVer? set;
  int? buildNumber;
}

Never _usageError(String message) {
  stderr.writeln('ERROR: $message');
  exit(64);
}

_Options _parseArgs(List<String> args) {
  final o = _Options();
  String value(int i, String flag) {
    if (i + 1 >= args.length) _usageError('$flag butuh nilai.');
    return args[i + 1];
  }

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--dry-run':
        o.dryRun = true;
      case '--tag':
        o.tag = true;
      case '--bump':
        final name = value(i++, '--bump');
        o.bump = BumpType.values.where((b) => b.name == name).firstOrNull ??
            _usageError('--bump harus major|minor|patch|none, bukan "$name".');
      case '--set':
        final text = value(i++, '--set');
        o.set = SemVer.tryParse(text) ?? _usageError('--set harus berformat X.Y.Z, bukan "$text".');
      case '--build-number':
        final text = value(i++, '--build-number');
        final n = int.tryParse(text);
        if (n == null || n < 1) _usageError('--build-number harus bilangan bulat >= 1.');
        o.buildNumber = n;
      case '-h' || '--help':
        stdout.writeln('Lihat komentar di bagian atas tool/version_bumper.dart.');
        exit(0);
      default:
        _usageError('Argumen tidak dikenal: ${args[i]}');
    }
  }
  return o;
}

void main(List<String> args) {
  final opts = _parseArgs(args);
  _root = File.fromUri(Platform.script).parent.parent.path;

  final pubspecFile = File('$_root${Platform.pathSeparator}pubspec.yaml');
  final pubspec = pubspecFile.readAsStringSync();
  final current = readPubspecVersion(pubspec) ??
      _usageError('Versi di pubspec.yaml tidak berformat X.Y.Z[+N].');
  final fromPubspec = current.version;

  final tag = _latestTag();
  final base = tag?.version ?? fromPubspec;

  BumpType bump;
  var triggers = <({String hash, String message})>[];
  if (opts.set != null) {
    bump = BumpType.none;
  } else if (opts.bump != null) {
    bump = opts.bump!;
  } else if (tag == null) {
    bump = BumpType.none;
    stdout.writeln('Belum ada tag vX.Y.Z -> versi pubspec.yaml ($fromPubspec) dipakai apa adanya.\n'
        'Buat tag awal: git tag v$fromPubspec <commit>');
  } else {
    final commits = _commits('${tag.name}..HEAD');
    bump = determineBump(commits.map((c) => c.message));
    triggers = [for (final c in commits) if (bumpForCommit(c.message) == bump && bump != BumpType.none) c];
    stdout.writeln('${commits.length} commit sejak ${tag.name}.');
  }

  final next = opts.set ?? base.bump(bump);
  final build = opts.buildNumber ??
      nextBuildNumber(int.parse(_git(['rev-list', '--count', 'HEAD']).trim()), current.build);
  final full = '$next+$build';

  for (final c in triggers) {
    stdout.writeln('  ${bump.name.toUpperCase()}  ${c.hash}  ${c.message.split('\n').first}');
  }
  stdout.writeln('Bump: ${opts.set != null ? 'set manual' : bump.name} | $base -> $next | build $build');

  if (opts.dryRun) {
    stdout.writeln('[dry-run] version: $full (pubspec.yaml tidak diubah)');
    return;
  }

  pubspecFile.writeAsStringSync(replaceVersionLine(pubspec, full));
  stdout.writeln('pubspec.yaml -> version: $full');

  if (opts.tag && next != base) {
    final name = 'v$next';
    _git(['tag', '-a', name, '-m', 'Release $name']);
    stdout.writeln('Tag dibuat: $name (kirim dengan: git push origin $name)');
  }
}
