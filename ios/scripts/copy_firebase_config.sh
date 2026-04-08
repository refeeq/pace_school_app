#!/bin/bash

# =============================================================================
# Firebase Configuration Copy Script for Multi-Flavor iOS Builds
# =============================================================================
# Uses Xcode build configuration name to determine flavor and copy the correct
# GoogleService-Info.plist into the app bundle at build time.
#
# Required structure:
#   ios/config/<flavor>/GoogleService-Info.plist
#
# Required build configuration naming:
#   <Anything>-<flavor>
#   Examples:
#     Debug-pace
#     Release-gaes
#     Profile-demo
# =============================================================================

set -e
set -u

# -----------------------------------------------------------------------------
# Colors & logging helpers
# -----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# -----------------------------------------------------------------------------
# Basic context
# -----------------------------------------------------------------------------
log_info "Build Configuration : ${CONFIGURATION}"
log_info "Project Directory   : ${PROJECT_DIR}"
log_info "Product Name        : ${PRODUCT_NAME}"

# -----------------------------------------------------------------------------
# Step 1: Extract flavor from CONFIGURATION
# -----------------------------------------------------------------------------
if [[ "${CONFIGURATION}" == *"-"* ]]; then
    FLAVOR="${CONFIGURATION##*-}"
    log_info "Extracted flavor: ${FLAVOR}"
else
    log_error "Cannot extract flavor from CONFIGURATION: ${CONFIGURATION}"
    log_error "Expected format: <anything>-<flavor> (e.g. Debug-pace)"
    exit 1
fi

# -----------------------------------------------------------------------------
# Step 2: Validate flavor via filesystem (single source of truth)
# -----------------------------------------------------------------------------
CONFIG_ROOT="${PROJECT_DIR}/config"
FLAVOR_DIR="${CONFIG_ROOT}/${FLAVOR}"

if [[ ! -d "${FLAVOR_DIR}" ]]; then
    log_error "No Firebase config directory for flavor: ${FLAVOR}"
    log_error "Expected directory: ${FLAVOR_DIR}"
    log_error "Available flavors:"
    ls -1 "${CONFIG_ROOT}" || true
    exit 1
fi

log_success "Flavor directory found: ${FLAVOR_DIR}"

# -----------------------------------------------------------------------------
# Step 3: Validate GoogleService-Info.plist
# -----------------------------------------------------------------------------
PLIST_FILENAME="GoogleService-Info.plist"
SOURCE_FILE="${FLAVOR_DIR}/${PLIST_FILENAME}"

if [[ ! -f "${SOURCE_FILE}" ]]; then
    log_error "Missing ${PLIST_FILENAME} for flavor: ${FLAVOR}"
    log_error "Expected path: ${SOURCE_FILE}"
    exit 1
fi

if [[ ! -s "${SOURCE_FILE}" ]]; then
    log_error "${PLIST_FILENAME} exists but is empty for flavor: ${FLAVOR}"
    exit 1
fi

log_success "Firebase plist validated: ${SOURCE_FILE}"

# -----------------------------------------------------------------------------
# Step 4: Copy into app bundle (overwrite-safe)
# -----------------------------------------------------------------------------
DESTINATION_DIR="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app"
DESTINATION_FILE="${DESTINATION_DIR}/${PLIST_FILENAME}"

if [[ ! -d "${DESTINATION_DIR}" ]]; then
    log_error "App bundle directory not found: ${DESTINATION_DIR}"
    exit 1
fi

# Remove any previously bundled plist (prevents cache issues)
if [[ -f "${DESTINATION_FILE}" ]]; then
    log_info "Removing existing GoogleService-Info.plist from app bundle"
    rm -f "${DESTINATION_FILE}"
fi

log_info "Copying Firebase config for flavor: ${FLAVOR}"
cp "${SOURCE_FILE}" "${DESTINATION_FILE}"

# -----------------------------------------------------------------------------
# Step 5: Final verification
# -----------------------------------------------------------------------------
if [[ ! -f "${DESTINATION_FILE}" ]] || [[ ! -s "${DESTINATION_FILE}" ]]; then
    log_error "Copy verification failed"
    exit 1
fi

log_success "Firebase configuration applied successfully"
log_success "Build can proceed with flavor: ${FLAVOR}"

exit 0
