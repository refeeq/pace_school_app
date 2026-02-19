#!/bin/bash

# =============================================================================
# Fix PDFium.framework dSYM for App Store Archive
# =============================================================================
# Attempts to generate a dSYM for PDFium.framework and add it to the archive's
# dSYMs folder. Apple may warn about missing PDFium dSYMs during validation.
#
# Run this AFTER creating an archive (flutter build ipa or Xcode Product > Archive).
#
# Usage:
#   ./fix_pdfium_dsym.sh [ARCHIVE_PATH]
#
# Default ARCHIVE_PATH: ../../build/ios/archive/Runner.xcarchive
# (relative to this script, i.e. project_root/build/ios/archive/Runner.xcarchive)
#
# Note: dsymutil only works if the PDFium binary contains debug symbols.
# Precompiled frameworks often do not; if so, this script will log that and exit.
# =============================================================================

set -e
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
DEFAULT_ARCHIVE="${PROJECT_ROOT}/build/ios/archive/Runner.xcarchive"
ARCHIVE_PATH="${1:-${DEFAULT_ARCHIVE}}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# -----------------------------------------------------------------------------
# Validate archive path
# -----------------------------------------------------------------------------
if [[ ! -d "${ARCHIVE_PATH}" ]]; then
    log_error "Archive not found: ${ARCHIVE_PATH}"
    log_info "Usage: $0 [ARCHIVE_PATH]"
    log_info "Run after: flutter build ipa"
    exit 1
fi

DSYMS_DIR="${ARCHIVE_PATH}/dSYMs"
APP_PATH="${ARCHIVE_PATH}/Products/Applications/Runner.app"
FRAMEWORK_PATH="${APP_PATH}/Frameworks/PDFium.framework"

# Try alternate casing (pdfium vs PDFium)
if [[ ! -d "${FRAMEWORK_PATH}" ]]; then
    FRAMEWORK_PATH="${APP_PATH}/Frameworks/pdfium.framework"
fi

if [[ ! -d "${FRAMEWORK_PATH}" ]]; then
    log_warn "PDFium.framework not found in archive"
    log_info "Searched: ${APP_PATH}/Frameworks/"
    log_info "The archive may not include PDFium, or the framework may have a different name."
    exit 0
fi

BINARY_PATH="${FRAMEWORK_PATH}/PDFium"
if [[ ! -f "${BINARY_PATH}" ]]; then
    BINARY_PATH="${FRAMEWORK_PATH}/pdfium"
fi

if [[ ! -f "${BINARY_PATH}" ]]; then
    log_error "PDFium binary not found inside framework"
    exit 1
fi

log_info "Found PDFium binary: ${BINARY_PATH}"

# -----------------------------------------------------------------------------
# Generate dSYM with dsymutil
# -----------------------------------------------------------------------------
TEMP_DSYM="/tmp/PDFium.framework.dSYM.$$"
rm -rf "${TEMP_DSYM}"

log_info "Running dsymutil on PDFium binary..."
if ! dsymutil "${BINARY_PATH}" -o "${TEMP_DSYM}" 2>&1; then
    log_warn "dsymutil failed (precompiled binaries often have no debug symbols)"
    log_info "The PDFium.framework dSYM warning may persist. This is a known limitation."
    rm -rf "${TEMP_DSYM}" 2>/dev/null || true
    exit 0
fi

if [[ ! -d "${TEMP_DSYM}" ]]; then
    log_warn "dsymutil did not produce a dSYM bundle"
    exit 0
fi

# -----------------------------------------------------------------------------
# Copy dSYM to archive
# -----------------------------------------------------------------------------
mkdir -p "${DSYMS_DIR}"
DSYM_DEST="${DSYMS_DIR}/PDFium.framework.dSYM"

if [[ -d "${DSYM_DEST}" ]]; then
    rm -rf "${DSYM_DEST}"
fi

cp -R "${TEMP_DSYM}" "${DSYM_DEST}"
rm -rf "${TEMP_DSYM}"

log_success "PDFium.framework.dSYM added to archive: ${DSYM_DEST}"
log_info "Re-validate or re-upload the archive to App Store Connect."

exit 0
