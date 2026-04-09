#!/usr/bin/env bash
set -euo pipefail

AZAHAR_DIR=${1:-azahar-src}

SHORT_SHA=$(git -C "$AZAHAR_DIR" rev-parse --short HEAD)
FULL_SHA=$(git -C "$AZAHAR_DIR" rev-parse HEAD)
BUILD_DATE=$(date -u '+%Y-%m-%d')

TAG_NAME="nightly-${BUILD_DATE}"
if gh release view "$TAG_NAME" &>/dev/null 2>&1; then
    TAG_NAME="nightly-${BUILD_DATE}-$(date -u '+%H%M')"
    echo "Tag already used today, switching to ${TAG_NAME}"
fi

{
    echo "short_sha=${SHORT_SHA}"
    echo "full_sha=${FULL_SHA}"
    echo "build_date=${BUILD_DATE}"
    echo "tag_name=${TAG_NAME}"
} >> "$GITHUB_OUTPUT"

PREV_SHA=""
LATEST_TAG=$(gh release list --limit 20 \
    --json tagName \
    -q '[.[] | select(.tagName | startswith("nightly-"))][0].tagName' \
    2>/dev/null || true)

if [ -n "$LATEST_TAG" ]; then
    PREV_SHA=$(gh release download "$LATEST_TAG" \
        --pattern "azahar-sha.txt" -D /tmp/prev-sha --clobber 2>/dev/null \
        && cat /tmp/prev-sha/azahar-sha.txt 2>/dev/null || true)
    PREV_SHA="${PREV_SHA//[[:space:]]/}"
fi

echo "prev_sha=${PREV_SHA}" >> "$GITHUB_OUTPUT"

if [ "$GITHUB_EVENT_NAME" = "workflow_dispatch" ]; then
    echo "should_build=true" >> "$GITHUB_OUTPUT"
    echo "Manual dispatch — building."
    exit 0
fi

if [ -n "$PREV_SHA" ] && [ "$PREV_SHA" = "$FULL_SHA" ]; then
    echo "should_build=false" >> "$GITHUB_OUTPUT"
    echo "No new commits since ${LATEST_TAG} (${SHORT_SHA}), skipping."
else
    echo "should_build=true" >> "$GITHUB_OUTPUT"
    echo "Building (prev: ${PREV_SHA:+${PREV_SHA:0:7}}, head: ${SHORT_SHA})."
fi
