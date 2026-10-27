import 'package:flutter_test/flutter_test.dart';

import '../tool/version_bumper.dart';

void main() {
  group('bumpForCommit', () {
    test('feat! / fix! / footer BREAKING CHANGE -> major', () {
      expect(bumpForCommit('feat!: ganti seluruh UI'), BumpType.major);
      expect(bumpForCommit('fix(tts)!: ubah API suara'), BumpType.major);
      expect(bumpForCommit('chore: x\n\nBREAKING CHANGE: hapus mode lama'), BumpType.major);
      expect(bumpForCommit('docs: x\n\nBREAKING-CHANGE: hapus mode lama'), BumpType.major);
    });

    test('feat -> minor', () {
      expect(bumpForCommit('feat: layar belajar baru'), BumpType.minor);
      expect(bumpForCommit('feat(quiz): kuis tebak gambar'), BumpType.minor);
    });

    test('fix / perf / refactor -> patch', () {
      expect(bumpForCommit('fix: perbaiki fonik e-taling'), BumpType.patch);
      expect(bumpForCommit('perf: percepat TTS'), BumpType.patch);
      expect(bumpForCommit('refactor(audio): rapikan'), BumpType.patch);
    });

    test('tipe lain & non-conventional -> none', () {
      expect(bumpForCommit('docs: update README'), BumpType.none);
      expect(bumpForCommit('chore: bump deps'), BumpType.none);
      expect(bumpForCommit('Merge branch main'), BumpType.none);
      expect(bumpForCommit('feature: bukan tipe resmi'), BumpType.none);
    });
  });

  test('determineBump mengambil yang tertinggi', () {
    expect(determineBump(['fix: a', 'feat: b', 'docs: c']), BumpType.minor);
    expect(determineBump(['fix: a', 'feat!: b']), BumpType.major);
    expect(determineBump(['docs: a', 'chore: b']), BumpType.none);
    expect(determineBump(const []), BumpType.none);
  });

  test('SemVer.bump mereset digit di bawahnya', () {
    const v = SemVer(1, 2, 3);
    expect(v.bump(BumpType.major).toString(), '2.0.0');
    expect(v.bump(BumpType.minor).toString(), '1.3.0');
    expect(v.bump(BumpType.patch).toString(), '1.2.4');
    expect(v.bump(BumpType.none).toString(), '1.2.3');
  });

  test('replaceVersionLine hanya mengubah baris version dan mempertahankan CRLF', () {
    const src = 'name: claymo\r\nversion: 0.1.0+3\r\n\r\nenvironment:\r\n  sdk: ^3.0.0\r\n';
    expect(
      replaceVersionLine(src, '0.2.0+9'),
      'name: claymo\r\nversion: 0.2.0+9\r\n\r\nenvironment:\r\n  sdk: ^3.0.0\r\n',
    );
    expect(() => replaceVersionLine('name: x\n', '1.0.0+1'), throwsFormatException);
  });

  test('readPubspecVersion membaca versi dan build', () {
    final r = readPubspecVersion('name: x\nversion: 1.2.3+45\n')!;
    expect(r.version.toString(), '1.2.3');
    expect(r.build, 45);
    expect(readPubspecVersion('version: 1.2.3\n')!.build, 0);
  });

  test('nextBuildNumber tidak pernah turun atau sama', () {
    expect(nextBuildNumber(120, 3), 120);
    expect(nextBuildNumber(2, 3), 4);
    expect(nextBuildNumber(3, 3), 4);
  });
}
