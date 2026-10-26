# Build APK release Claymo yang siap di-install di HP Android.
#
# Jalankan dari root proyek (PowerShell):
#   .\tool\build_apk.ps1                # APK universal (1 file, jalan di semua HP)
#   .\tool\build_apk.ps1 -SplitAbi      # APK per arsitektur (lebih kecil)
#   .\tool\build_apk.ps1 -Clean         # flutter clean dulu
#   .\tool\build_apk.ps1 -Install       # langsung install ke HP via adb (USB debugging)
#
# Pertama kali dijalankan, script membuat keystore rilis (android/claymo-release.jks)
# + android/key.properties. SIMPAN kedua file itu: APK versi berikutnya harus
# ditandatangani kunci yang sama agar bisa meng-update aplikasi yang sudah terpasang.
# Hasil: dist/claymo-<versi>-release.apk
[CmdletBinding()]
param(
    [switch]$SplitAbi,
    [switch]$Clean,
    [switch]$Install
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Fail($msg) { Write-Host "ERROR: $msg" -ForegroundColor Red; exit 1 }

# Jalankan perintah native dan hentikan script bila exit code != 0.
function Run {
    param([string]$Exe, [string[]]$Arguments)
    # PS 5.1 menganggap tulisan stderr native (mis. warning flutter) sebagai error; cukup andalkan exit code.
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & $Exe @Arguments
    $ErrorActionPreference = $prev
    if ($LASTEXITCODE -ne 0) { Fail "'$Exe $($Arguments -join ' ')' gagal (exit $LASTEXITCODE)." }
}

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { Fail 'flutter tidak ditemukan di PATH.' }

# --- Keystore rilis -----------------------------------------------------------
$keyProps = Join-Path $root 'android\key.properties'
$keystore = Join-Path $root 'android\claymo-release.jks'

if (-not (Test-Path $keyProps)) {
    Step 'Membuat keystore rilis (sekali saja)'
    $keytool = Get-Command keytool -ErrorAction SilentlyContinue
    if (-not $keytool -and $env:JAVA_HOME) { $keytool = Get-Command (Join-Path $env:JAVA_HOME 'bin\keytool.exe') -ErrorAction SilentlyContinue }
    if (-not $keytool) { Fail 'keytool tidak ditemukan. Pastikan JDK terpasang / JAVA_HOME diset.' }
    if (Test-Path $keystore) { Fail "$keystore sudah ada tapi key.properties hilang. Buat android\key.properties manual (storeFile, storePassword, keyAlias, keyPassword)." }

    $chars = [char[]]'abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
    $password = -join (1..20 | ForEach-Object { $chars | Get-Random })
    Run $keytool.Source @(
        '-genkeypair', '-v', '-keystore', $keystore, '-alias', 'claymo',
        '-storetype', 'PKCS12', '-keyalg', 'RSA', '-keysize', '2048', '-validity', '10000',
        '-storepass', $password, '-keypass', $password,
        '-dname', 'CN=Claymo, OU=Mobile, O=Claymo, C=ID'
    )
    @(
        "storePassword=$password"
        "keyPassword=$password"
        'keyAlias=claymo'
        'storeFile=claymo-release.jks'
    ) | Set-Content -Path $keyProps -Encoding ASCII
    Write-Host "Keystore dibuat: $keystore" -ForegroundColor Yellow
    Write-Host 'BACKUP android\claymo-release.jks dan android\key.properties di tempat aman!' -ForegroundColor Yellow
}

# --- Build --------------------------------------------------------------------
if ($Clean) { Step 'flutter clean'; Run flutter @('clean') }

Step 'flutter pub get'
Run flutter @('pub', 'get')

Step 'flutter gen-l10n'
Run flutter @('gen-l10n')

Step 'flutter build apk --release'
$buildArgs = @('build', 'apk', '--release')
if ($SplitAbi) { $buildArgs += '--split-per-abi' }
Run flutter $buildArgs

# --- Kumpulkan hasil ----------------------------------------------------------
$version = ((Select-String -Path (Join-Path $root 'pubspec.yaml') -Pattern '^version:\s*(\S+)').Matches[0].Groups[1].Value) -replace '\+', '-b'
$outDir = Join-Path $root 'dist'
New-Item -ItemType Directory -Force $outDir | Out-Null

$apkDir = Join-Path $root 'build\app\outputs\flutter-apk'
$built = Get-ChildItem $apkDir -Filter 'app-*release.apk' | Where-Object { $_.Name -notmatch 'debug' }
if (-not $built) { Fail "APK tidak ditemukan di $apkDir." }

$copied = foreach ($apk in $built) {
    $abi = $apk.Name -replace '^app-?', '' -replace '-?release\.apk$', ''
    $suffix = if ($abi) { "-$abi" } else { '' }
    $dest = Join-Path $outDir "claymo-$version$suffix-release.apk"
    Copy-Item $apk.FullName $dest -Force
    Get-Item $dest
}

Step 'Selesai'
foreach ($f in $copied) {
    '{0}  ({1:N1} MB)' -f $f.FullName, ($f.Length / 1MB) | Write-Host -ForegroundColor Green
}

# --- Install via adb (opsional) -----------------------------------------------
if ($Install) {
    Step 'Install ke HP via adb'
    if (-not (Get-Command adb -ErrorAction SilentlyContinue)) { Fail 'adb tidak ditemukan di PATH.' }
    # Pada split-per-abi, HP 64-bit modern memakai arm64-v8a.
    $target = $copied | Where-Object { $_.Name -match 'arm64-v8a' } | Select-Object -First 1
    if (-not $target) { $target = $copied | Select-Object -First 1 }
    Run adb @('install', '-r', $target.FullName)
}
else {
    Write-Host "`nCara install: kirim file APK ke HP (kabel/WhatsApp/Drive), buka, lalu izinkan 'Install dari sumber tidak dikenal'." -ForegroundColor Gray
    Write-Host 'Atau colok HP (USB debugging aktif) lalu jalankan: .\tool\build_apk.ps1 -Install' -ForegroundColor Gray
}
