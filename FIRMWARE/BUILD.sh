# --- XHeadphones: сборка прошивки ESP32 (Linux) ---

# Использование:
#   ./BUILD.sh            - только сборка
#   ./BUILD.sh flash      - сборка и прошивка по USB
#   ./BUILD.sh ota        - сборка и прошивка по OTA
#   ./BUILD.sh monitor    - сборка и запуск монитора порта
#   ./BUILD.sh clean      - очистка

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FIRMWARE_DIR="$PROJECT_DIR/FIRMWARE"
BUILD_DIR="$FIRMWARE_DIR/build"
IDF_EXPORT="$HOME/esp/esp-idf/export.sh"

# --- Проверка окружения ESP-IDF ---

if [ -f "$IDF_EXPORT" ]; then
    # shellcheck source=/dev/null
    . "$IDF_EXPORT"
fi

if ! command -v idf.py > /dev/null 2>&1; then
    echo "Ошибка: idf.py не найден в PATH."
    echo "Установите ESP-IDF версии 5.x и выполните . $IDF_EXPORT"
    exit 1
fi

# --- Проверка целевого чипа ---

if [ ! -f "$FIRMWARE_DIR/CMakeLists.txt" ]; then
    echo "Ошибка: нет $FIRMWARE_DIR/CMakeLists.txt"
    echo "Исходники прошивки ещё не созданы, структура описана в DOCS/SOFTWARE.md."
    exit 1
fi

# --- Сборка ---

case "${1:-build}" in
    build)
        idf.py --project-dir "$PROJECT_DIR" -B "$BUILD_DIR" build
        ;;
    flash)
        idf.py --project-dir "$PROJECT_DIR" -B "$BUILD_DIR" -p "${PORT:-/dev/ttyUSB0}" flash
        ;;
    ota)
        idf.py --project-dir "$PROJECT_DIR" -B "$BUILD_DIR" ota
        ;;
    monitor)
        idf.py --project-dir "$PROJECT_DIR" -B "$BUILD_DIR" -p "${PORT:-/dev/ttyUSB0}" monitor
        ;;
    clean)
        idf.py --project-dir "$PROJECT_DIR" -B "$BUILD_DIR" fullclean
        ;;
    *)
        echo "Неизвестная цель: $1"
        echo "Доступные цели: build, flash, ota, monitor, clean"
        exit 1
        ;;
esac

# --- Готово ---

echo "Готово: $1"
