#!/usr/bin/env bash
# install-telefonica-sans.sh — helper para instalar los binarios de Telefonica Sans
# en ofelia-shared/fonts/.
#
# Telefonica Sans está disponible públicamente en el CDN de Movistar Colombia:
#   https://www.movistar.com.co/assets/fonts/Telefonica-{Regular,Bold,Light,...}.woff2
#
# Pesos disponibles públicamente (a 2026-09-24):
#   - Light (300)
#   - Regular (400)
#   - Bold (700)
# Pesos NO disponibles públicamente: Medium (500), Black, Thin, Italic.
#
# Uso:
#   bash scripts/install-telefonica-sans.sh              # descarga automática desde CDN Movistar
#   bash scripts/install-telefonica-sans.sh --check      # solo verifica
#   bash scripts/install-telefonica-sans.sh --help       # ayuda

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FONTS_DIR="$REPO_ROOT/fonts"

EXPECTED_FILES=(
  "TelefonicaSans-Light.woff2"
  "TelefonicaSans-Regular.woff2"
  "TelefonicaSans-Bold.woff2"
)

CDN_BASE="https://www.movistar.com.co/assets/fonts"

usage() {
  cat <<EOF
Uso: $0 [OPCION]

Opciones:
  --check    Verifica que los 3 pesos públicos estén en $FONTS_DIR
  --help     Muestra esta ayuda
  (sin arg)  Descarga automáticamente desde el CDN de Movistar Colombia

Pesos públicos (descargados del CDN):
  - TelefonicaSans-Light.woff2    (300)
  - TelefonicaSans-Regular.woff2  (400)
  - TelefonicaSans-Bold.woff2     (700)

Pesos NO públicos — pedir al equipo de marca de Telefónica:
  - Medium (500), Black (900), Thin (100), Italic variants

Fuente: https://www.movistar.com.co/assets/fonts/Telefonica-<weight>.woff2
EOF
}

check_installed() {
  echo "Verificando binarios en $FONTS_DIR:"
  local all_ok=true
  for f in "${EXPECTED_FILES[@]}"; do
    if [ -f "$FONTS_DIR/$f" ]; then
      local size
      size=$(wc -c < "$FONTS_DIR/$f")
      printf "  [OK]      %s (%s bytes)\n" "$f" "$size"
    else
      printf "  [MISSING] %s\n" "$f"
      all_ok=false
    fi
  done
  if [ "$all_ok" = true ]; then
    echo ""
    echo "Telefonica Sans instalado correctamente."
    return 0
  else
    echo ""
    echo "Faltan binarios. Ejecutar sin --check para descargar desde el CDN."
    return 1
  fi
}

download_from_cdn() {
  mkdir -p "$FONTS_DIR"
  echo "Descargando Telefonica Sans desde $CDN_BASE ..."
  echo ""
  local count=0
  for weight in "Light:300" "Regular:400" "Bold:700"; do
    local name="${weight%:*}"
    local weight_num="${weight#*:}"
    local url="$CDN_BASE/Telefonica-${name}.woff2"
    local out="$FONTS_DIR/TelefonicaSans-${name}.woff2"
    local code
    code=$(curl -sL -o "$out" -w "%{http_code}" "$url" 2>/dev/null)
    if [ "$code" = "200" ] && [ -s "$out" ]; then
      local size
      size=$(wc -c < "$out")
      printf "  [DOWNLOADED] TelefonicaSans-%s.woff2 (%s bytes, weight=%s)\n" "$name" "$size" "$weight_num"
      count=$((count + 1))
    else
      printf "  [FAILED]     HTTP %s, %s\n" "$code" "$url"
      rm -f "$out"
    fi
  done
  echo ""
  echo "Descargados: $count / ${#EXPECTED_FILES[@]} pesos"
  echo ""
  check_installed
}

case "${1:-}" in
  --check)
    check_installed
    ;;
  --help|-h)
    usage
    ;;
  "")
    download_from_cdn
    ;;
  *)
    echo "Opción desconocida: $1" >&2
    usage
    exit 1
    ;;
esac
