#!/usr/bin/env bash
# install-movistar-sans.sh — helper para instalar los binarios de Movistar Sans
# en ofelia-shared/fonts/.
#
# Movistar Sans NO está disponible públicamente. Hay que obtener los .woff2
# del brand portal interno de Telefónica. Este script simplemente valida y
# copia los archivos al directorio esperado.
#
# Uso:
#   bash scripts/install-movistar-sans.sh /ruta/a/los/woff2/*.woff2
#   bash scripts/install-movistar-sans.sh --check     # solo verifica
#   bash scripts/install-movistar-sans.sh --help      # esta ayuda

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FONTS_DIR="$REPO_ROOT/fonts"

EXPECTED_FILES=(
  "MovistarSans-Light.woff2"
  "MovistarSans-Regular.woff2"
  "MovistarSans-Medium.woff2"
  "MovistarSans-Bold.woff2"
)

usage() {
  cat <<EOF
Uso: $0 [OPCION] [ARCHIVO...]

Opciones:
  --check              Verifica que los 4 pesos estén en $FONTS_DIR
  --help               Muestra esta ayuda
  ARCHIVO...           Instala los .woff2 especificados en $FONTS_DIR

Para obtener los binarios Movistar Sans: contactar al equipo de marca
de Telefónica o revisar el brand portal interno. NO están en GitHub,
npm, Google Fonts ni en el CDN público.

Pesos esperados:
  - MovistarSans-Light.woff2    (300)
  - MovistarSans-Regular.woff2  (400)
  - MovistarSans-Medium.woff2   (500)
  - MovistarSans-Bold.woff2     (700)
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
    echo "Movistar Sans instalado correctamente."
    return 0
  else
    echo ""
    echo "Faltan binarios. Obtener del brand portal de Telefónica y ejecutar:"
    echo "  $0 /ruta/a/MovistarSans-{Light,Regular,Medium,Bold}.woff2"
    return 1
  fi
}

install_files() {
  local installed=0
  for src in "$@"; do
    if [ ! -f "$src" ]; then
      echo "  [SKIP] $src (no existe)"
      continue
    fi
    # Detectar qué peso es por el nombre
    local basename
    basename=$(basename "$src")
    case "$basename" in
      *Light*|*light*|*300*)
        cp "$src" "$FONTS_DIR/MovistarSans-Light.woff2"
        echo "  [INSTALLED] $basename → MovistarSans-Light.woff2"
        ;;
      *Regular*|*regular*|*400*|*Normal*)
        cp "$src" "$FONTS_DIR/MovistarSans-Regular.woff2"
        echo "  [INSTALLED] $basename → MovistarSans-Regular.woff2"
        ;;
      *Medium*|*medium*|*500*)
        cp "$src" "$FONTS_DIR/MovistarSans-Medium.woff2"
        echo "  [INSTALLED] $basename → MovistarSans-Medium.woff2"
        ;;
      *Bold*|*bold*|*700*)
        cp "$src" "$FONTS_DIR/MovistarSans-Bold.woff2"
        echo "  [INSTALLED] $basename → MovistarSans-Bold.woff2"
        ;;
      *)
        echo "  [WARN] $basename — peso no reconocido por nombre. Esperado uno de:"
        echo "         Light, Regular, Medium, Bold (o 300/400/500/700 en el nombre)"
        ;;
    esac
    installed=$((installed + 1))
  done
  echo ""
  echo "Archivos instalados: $installed"
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
    usage
    exit 1
    ;;
  *)
    install_files "$@"
    ;;
esac
