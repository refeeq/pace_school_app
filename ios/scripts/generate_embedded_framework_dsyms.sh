#!/bin/sh

# Generate dSYMs for embedded dynamic frameworks during archive.
# This is best-effort and never fails the build.
set +e

case "${CONFIGURATION}" in
  Release*) ;;
  *)
    exit 0
    ;;
esac

APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"
FRAMEWORKS_DIR="${APP_PATH}/Frameworks"
DSYM_OUTPUT_DIR="${DWARF_DSYM_FOLDER_PATH}"

if [ ! -d "${FRAMEWORKS_DIR}" ] || [ ! -d "${DSYM_OUTPUT_DIR}" ]; then
  exit 0
fi

echo "Generating dSYMs for embedded frameworks in ${FRAMEWORKS_DIR}"

for FRAMEWORK_PATH in "${FRAMEWORKS_DIR}"/*.framework; do
  [ -d "${FRAMEWORK_PATH}" ] || continue

  FRAMEWORK_NAME="$(basename "${FRAMEWORK_PATH}")"
  FRAMEWORK_BASE="${FRAMEWORK_NAME%.framework}"
  BINARY_PATH="${FRAMEWORK_PATH}/${FRAMEWORK_BASE}"

  if [ ! -f "${BINARY_PATH}" ]; then
    EXECUTABLE_NAME=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "${FRAMEWORK_PATH}/Info.plist" 2>/dev/null)
    if [ -n "${EXECUTABLE_NAME}" ] && [ -f "${FRAMEWORK_PATH}/${EXECUTABLE_NAME}" ]; then
      BINARY_PATH="${FRAMEWORK_PATH}/${EXECUTABLE_NAME}"
    fi
  fi

  if [ ! -f "${BINARY_PATH}" ]; then
    echo "Skipping ${FRAMEWORK_NAME}: binary not found"
    continue
  fi

  TMP_DSYM="/tmp/${FRAMEWORK_NAME}.dSYM.$$"
  DEST_DSYM="${DSYM_OUTPUT_DIR}/${FRAMEWORK_NAME}.dSYM"

  rm -rf "${TMP_DSYM}"
  dsymutil "${BINARY_PATH}" -o "${TMP_DSYM}" >/dev/null 2>&1

  if [ -d "${TMP_DSYM}" ]; then
    rm -rf "${DEST_DSYM}"
    cp -R "${TMP_DSYM}" "${DEST_DSYM}"
    rm -rf "${TMP_DSYM}"
    echo "Prepared dSYM for ${FRAMEWORK_NAME}"
  else
    echo "Could not prepare dSYM for ${FRAMEWORK_NAME}"
  fi
done

set -e
exit 0
