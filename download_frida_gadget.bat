@echo off
REM BioShield - Frida Gadget Downloader (Windows)
REM Downloads the correct Frida Gadget binary for your device

setlocal enabledelayedexpansion

set FRIDA_VERSION=16.5.9

echo ===== BioShield Frida Gadget Downloader =====
echo.

REM Detect architecture
echo Select your target architecture:
echo   1) x86_64 (Android Emulator)
echo   2) arm64 (Physical Device - 64-bit)
echo   3) arm (Physical Device - 32-bit, older devices)
echo.
set /p arch_choice="Enter choice [1-3]: "

if "%arch_choice%"=="1" (
    set ARCH=x86_64
) else if "%arch_choice%"=="2" (
    set ARCH=arm64
) else if "%arch_choice%"=="3" (
    set ARCH=arm
) else (
    echo Invalid choice. Exiting.
    exit /b 1
)

echo.
echo Selected architecture: %ARCH%
echo Frida version: %FRIDA_VERSION%
echo.

REM Construct download URL
set FILENAME=frida-gadget-%FRIDA_VERSION%-android-%ARCH%.so.xz
set URL=https://github.com/frida/frida/releases/download/%FRIDA_VERSION%/%FILENAME%

echo Downloading from:
echo   %URL%
echo.

REM Check if curl is available
where curl >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: curl not found. Please install curl or download manually from:
    echo   %URL%
    exit /b 1
)

REM Download
echo Downloading...
curl -L -o "%FILENAME%" "%URL%"

if not exist "%FILENAME%" (
    echo Error: Download failed
    exit /b 1
)

echo √ Downloaded successfully
echo.

REM Extract (Windows doesn't have xz by default)
echo Extracting...
echo.
echo NOTE: Windows doesn't include 'xz' by default.
echo.
echo Option 1: Install 7-Zip and extract manually:
echo   - Right-click %FILENAME%
echo   - 7-Zip ^> Extract Here
echo   - Rename extracted file to libfrida-gadget.so
echo.
echo Option 2: Use WSL (Windows Subsystem for Linux):
echo   wsl xz -d "%FILENAME%"
echo.
echo Option 3: Download from Python:
pause

REM Try to extract using Python if available
where python >nul 2>&1
if %errorlevel% equ 0 (
    echo Attempting to extract using Python...
    python -c "import lzma; open('%FILENAME:~0,-3%', 'wb').write(lzma.open('%FILENAME%').read())"

    if exist "%FILENAME:~0,-3%" (
        ren "%FILENAME:~0,-3%" libfrida-gadget.so
        del "%FILENAME%"
        goto :success
    )
)

echo.
echo Manual extraction required. File downloaded: %FILENAME%
echo Please extract using 7-Zip or another tool that supports .xz format
goto :end

:success
echo √ Extracted successfully
echo.
echo ===== SUCCESS =====
echo.
echo Frida Gadget ready:
echo   File: libfrida-gadget.so
echo   Architecture: %ARCH%
echo   Version: %FRIDA_VERSION%
echo.
echo Next steps:
echo   1. Copy libfrida-gadget.so to app_decompiled\lib\%ARCH%\
echo   2. Copy libfrida-gadget.config.so to app_decompiled\lib\%ARCH%\
echo   3. Copy libfrida-gadget.script.so to app_decompiled\lib\%ARCH%\
echo.
echo See README.md for complete instructions

:end
pause
