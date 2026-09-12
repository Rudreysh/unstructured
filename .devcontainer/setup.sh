#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export DO_NOT_TRACK=1
export SCARF_NO_ANALYTICS=true

sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  libmagic1 \
  libmagic-dev \
  poppler-utils \
  tesseract-ocr \
  tesseract-ocr-eng \
  libreoffice-writer \
  libreoffice-impress \
  pandoc \
  curl \
  ca-certificates

# Point Tesseract at distro tessdata without hard-coding a Debian version.
for tessdata_dir in \
  /usr/share/tesseract-ocr/5/tessdata \
  /usr/share/tesseract-ocr/4.00/tessdata \
  /usr/share/tessdata
do
  if [[ -d "${tessdata_dir}" ]]; then
    export TESSDATA_PREFIX="${tessdata_dir}"
    break
  fi
done

if [[ -n "${TESSDATA_PREFIX:-}" ]]; then
  grep -q 'TESSDATA_PREFIX' ~/.bashrc 2>/dev/null || \
    echo "export TESSDATA_PREFIX=${TESSDATA_PREFIX}" >> ~/.bashrc
fi

if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi
export PATH="${HOME}/.local/bin:${PATH}"
grep -q '.local/bin' ~/.bashrc 2>/dev/null || \
  echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> ~/.bashrc

uv python install 3.12
uv sync --locked --all-groups \
  --extra pdf \
  --extra docx \
  --extra pptx \
  --extra xlsx \
  --extra csv \
  --extra md \
  --extra epub \
  --extra odt \
  --extra rtf \
  --extra rst \
  --extra org

uv run unstructured doctor || true
