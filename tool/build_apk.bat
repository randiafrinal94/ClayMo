@echo off
rem Wrapper build APK release Claymo: bisa diklik dua kali atau dijalankan dari cmd/PowerShell.
rem Argumen diteruskan ke tool\build_apk.ps1, mis.:
rem   tool\build_apk.bat -SplitAbi
rem   tool\build_apk.bat -NoBump
rem   tool\build_apk.bat -Clean -Install
rem Hasil: dist\claymo-<versi>-release.apk
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_apk.ps1" %*
set EXITCODE=%ERRORLEVEL%
if %EXITCODE% neq 0 echo.& echo Build GAGAL (exit %EXITCODE%).
rem Tahan jendela hanya bila dibuka via klik dua kali (bukan dari terminal).
echo %cmdcmdline% | find /i "%~nx0" >nul && pause
exit /b %EXITCODE%
