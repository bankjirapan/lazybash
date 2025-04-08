#!/bin/bash

RECYCLE_BIN="/tmp/recycle_bin"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create the recycle bin directory if it doesn't exist
mkdir -p "$RECYCLE_BIN"


IF [ "$#" -eq 0 ]; then
    echo "Usage: $0 <file_or_directory> [more_files_or_directories...]"
    exit 1
fi

for TARGET in "$@"; do
    if [ ! -e "$TARGET" ]; then
        echo "Error: $TARGET does not exist."
        continue
    fi

    ABS_PATH=$(realpath "$TARGET")
    BASENAME=$(basename "$ABS_PATH")
    NEW_ID="${BASENAME}_${TIMESTAMP}_$(uuidgen)"

    DEST="$RECYCLE_BIN/$NEW_ID"
    METADATA_FILE="$RECYCLE_BIN/$NEW_ID.info"

    # Check ownership and permissions
    FILE_OWNER=$(stat -c '%U' "$TARGET")
    FILE_GROUP=$(stat -c '%G' "$TARGET")
    FILE_PERMISSIONS=$(stat -c '%a' "$TARGET")
    FILE_SIZE=$(stat -c '%s' "$TARGET")

    if [ -d "$TARGET"]; then
        # Use rsync for directories to preserve permissions and structure
        rsync -a --remove-source-files "$TARGET/" "$DEST/"
        # Create metadata file with original location and other info
        echo "Original path: $ABS_PATH" > "$METADATA_FILE"
        echo "Deleted on: $TIMESTAMP" >> "$METADATA_FILE"
        echo "Owner: $FILE_OWNER" >> "$METADATA_FILE"
        echo "Group: $FILE_GROUP" >> "$METADATA_FILE"
        echo "Permissions: $FILE_PERMISSIONS" >> "$METADATA_FILE"
        echo "Size: $FILE_SIZE bytes" >> "$METADATA_FILE"
        echo "Directory moved to recycle bin: $DEST"
    else
        # Move the file to the recycle bin
        mv "$TARGET" "$DEST"
        # Create metadata file with original location and other info
        echo "Original path: $ABS_PATH" > "$METADATA_FILE"
        echo "Deleted on: $TIMESTAMP" >> "$METADATA_FILE"
        echo "Owner: $FILE_OWNER" >> "$METADATA_FILE"
        echo "Group: $FILE_GROUP" >> "$METADATA_FILE"
        echo "Permissions: $FILE_PERMISSIONS" >> "$METADATA_FILE"
        echo "Size: $FILE_SIZE bytes" >> "$METADATA_FILE"
        echo "File moved to recycle bin: $DEST"
    fi

done

