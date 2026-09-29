@echo off
REM --- XHeadphones: сборка прошивки ESP32 (Windows) ---

REM Использование:
REM   BUILD.bat          - только сборка
REM   BUILD.bat flash    - сборка и прошивка по USB, порт задаётся переменной PORT
REM   BUILD.bat ota      - сборка и прошивка по OTA
REM   BUILD.bat monitor  - сборка и запуск монитора порта
REM   BUILD.bat clean    - очистка

setlocal

set "PROJECT_DIR=%~dp0.."
set "FIRMWARE_DIR=%PROJECT_DIR%\FIRMWARE"
set "BUILD_DIR=%FIRMWARE_DIR%\build"
if "%PORT%"=="" set "PORT=COM5"

REM --- Проверка окружения ESP-IDF ---

where idf.py >nul 2>&1
if errorlevel 1 (
    echo Ошибка: idf.py не найден в PATH.
    echo Установите ESP-IDF версии 5.x и выполните export.bat
    exit /b 1
)

REM --- Проверка структуры проекта ---

if not exist "%FIRMWARE_DIR%\CMakeLists.txt" (
    echo Ошибка: нет %FIRMWARE_DIR%\CMakeLists.txt
    echo Исходники прошивки ещё не созданы, структура описана в DOCS\SOFTWARE.md.
    exit /b 1
)

REM --- Сборка ---

if "%1"=="" goto build
if "%1"=="build" goto build
if "%1"=="flash" goto flash
if "%1"=="ota" goto ota
if "%1"=="monitor" goto monitor
if "%1"=="clean" goto clean

echo Неизвестная цель: %1
echo Доступные цели: build, flash, ota, monitor, clean
exit /b 1

:build
idf.py --project-dir "%PROJECT_DIR%" -B "%BUILD_DIR%" build
goto done

:flash
idf.py --project-dir "%PROJECT_DIR%" -B "%BUILD_DIR%" -p %PORT% flash
goto done

:ota
idf.py --project-dir "%PROJECT_DIR%" -B "%BUILD_DIR%" ota
goto done

:monitor
idf.py --project-dir "%PROJECT_DIR%" -B "%BUILD_DIR%" -p %PORT% monitor
goto done

:clean
idf.py --project-dir "%PROJECT_DIR%" -B "%BUILD_DIR%" fullclean
goto done

:done
echo Готово: %1
endlocal
exit /b 0
