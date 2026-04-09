#!/bin/sh
set -eu

TARGET_FILE="scripts/is_contain.sh"
COMMIT_HASH="$(git rev-parse --short=12 HEAD)"
TMP_FILE="$(mktemp)"

if [ ! -f "$TARGET_FILE" ]; then
  echo "Target file not found: $TARGET_FILE" >&2
  exit 1
fi

if tail -n 1 "$TARGET_FILE" | grep -q '^# commit-hash:'; then
  sed -e "\$s|^# commit-hash:.*$|# commit-hash: ${COMMIT_HASH}|" "$TARGET_FILE" > "$TMP_FILE"
else
  cat "$TARGET_FILE" > "$TMP_FILE"
  printf '\n# commit-hash: %s\n' "$COMMIT_HASH" >> "$TMP_FILE"
fi

mv "$TMP_FILE" "$TARGET_FILE"
