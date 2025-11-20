#!/bin/bash
# Build script for Docker image with proper metadata
# Version: 1.0.0

set -e

IMAGE_NAME="${IMAGE_NAME:-tonykayclj/clojure-node-claude}"
TAG="${TAG:-latest}"
VERSION="${VERSION:-1.0.0}"

# Get git commit hash
VCS_REF=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Get build date in ISO 8601 format
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "Building Docker image..."
echo "  Image: ${IMAGE_NAME}:${TAG}"
echo "  Version: ${VERSION}"
echo "  Git commit: ${VCS_REF}"
echo "  Build date: ${BUILD_DATE}"
echo

docker build \
  --build-arg BUILD_DATE="${BUILD_DATE}" \
  --build-arg VCS_REF="${VCS_REF}" \
  --build-arg VERSION="${VERSION}" \
  -t "${IMAGE_NAME}:${TAG}" \
  .

echo
echo "Build complete!"
echo "To inspect metadata:"
echo "  docker inspect ${IMAGE_NAME}:${TAG} -f '{{json .Config.Labels}}' | jq"
echo
echo "To push to Docker Hub:"
echo "  docker push ${IMAGE_NAME}:${TAG}"
