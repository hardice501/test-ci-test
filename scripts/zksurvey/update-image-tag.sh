#!/usr/bin/env bash

set -euo pipefail
export LC_ALL=C

if [[ $# -ne 3 ]]; then
  printf 'Usage: %s <service> <env> <image-tag>\n' "$(basename "$0")" >&2
  printf '   or: %s <service> <image-tag> <env>\n' "$(basename "$0")" >&2
  exit 1
fi

SERVICE="$1"

if [[ "$2" =~ ^(prod|stg|lt|dev)$ ]]; then
  ENV_NAME="$2"
  NEW_TAG="$3"
elif [[ "$3" =~ ^(prod|stg|lt|dev)$ ]]; then
  NEW_TAG="$2"
  ENV_NAME="$3"
else
  printf '지원하지 않는 env: %s\n' "$2" >&2
  exit 1
fi

NAMESPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${NAMESPACE_DIR}/${SERVICE}"

case "${ENV_NAME}" in
  prod) TARGET_FILE="${TARGET_DIR}/values.yaml" ;;
  stg) TARGET_FILE="${TARGET_DIR}/values-stg.yaml" ;;
  lt) TARGET_FILE="${TARGET_DIR}/values-lt.yaml" ;;
  dev) TARGET_FILE="${TARGET_DIR}/values-dev.yaml" ;;
  *)
    printf '지원하지 않는 env: %s\n' "${ENV_NAME}" >&2
    exit 1
    ;;
esac

if [[ ! -d "${TARGET_DIR}" ]]; then
  printf '서비스 폴더 없음: %s\n' "${TARGET_DIR}" >&2
  exit 1
fi

if [[ ! -f "${TARGET_FILE}" ]]; then
  printf '대상 파일 없음: %s\n' "${TARGET_FILE}" >&2
  exit 1
fi

if ! grep -Eq '^[[:space:]]*imageTag[[:space:]]*:' "${TARGET_FILE}"; then
  printf 'imageTag 항목 없음: %s\n' "${TARGET_FILE}" >&2
  exit 1
fi

NEW_TAG="${NEW_TAG}" perl -0pi -e '
  s/^(\s*imageTag\s*:\s*)(["\x27]?)[^"\x27\r\n#]+(\2)(\s*(?:#.*)?)$/$1.$2.$ENV{NEW_TAG}.$3.$4/mge
' "${TARGET_FILE}"
