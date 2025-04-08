#!/bin/bash

RECYCLE_BIN="/tmp/recycle_bin"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$RECYCLE_BIN"

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <file_or_directory> [more files...]"
  exit 1
fi

for TARGET in "$@"; do
  if [ ! -e "$TARGET" ]; then
    echo "Error: '$TARGET' not found"
    continue
  fi

  ABS_PATH=$(realpath "$TARGET")
  BASENAME=$(basename "$TARGET")
  NEW_ID="${BASENAME}_${TIMESTAMP}_$RANDOM"

  DEST="$RECYCLE_BIN/$NEW_ID"
  METADATA="$RECYCLE_BIN/$NEW_ID.info"

  FILE_OWNER=$(stat -c '%U' "$TARGET")
  FILE_GROUP=$(stat -c '%G' "$TARGET")
  PERMISSIONS=$(stat -c '%a' "$TARGET")

  if [ -d "$TARGET" ]; then
    # ถ้าเป็น directory ให้สร้าง directory ใหม่ใน recycle bin
    mkdir -p "$DEST"
    rsync -a "$TARGET/" "$DEST/"
    rm -rf "$TARGET"
  else
    mv "$TARGET" "$DEST"
  fi

  # สร้าง metadata เก็บข้อมูลที่จำเป็น
  echo "original_path=\"$ABS_PATH\"" > "$METADATA"
  echo "deleted_at=\"$TIMESTAMP\"" >> "$METADATA"
  echo "owner=\"$FILE_OWNER\"" >> "$METADATA"
  echo "group=\"$FILE_GROUP\"" >> "$METADATA"
  echo "permissions=\"$PERMISSIONS\"" >> "$METADATA"
  echo "is_directory=\"$(if [ -d "$DEST" ]; then echo "yes"; else echo "no"; fi)\"" >> "$METADATA"

  echo "Moved '$TARGET' to '$DEST'"
  echo "Metadata saved: $METADATA"
done