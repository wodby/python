# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := python
BASE_IMAGE_VERSION_SUFFIX := -alpine

BASE_IMAGE_DIGEST_3.11.18-alpine := sha256:c89ba5e1fd17382f04e0fcdeb7829f866d3cf4911dec0603e50bb4a3782aeae7
BASE_IMAGE_DIGEST_3.12.16-alpine := sha256:c566b41a6dede5cb51412ba90fd7b05b6e3005846db44b46b77e850083f8da6d
BASE_IMAGE_DIGEST_3.13.18-alpine := sha256:0029b1929b9d7e1d90e5a3033d39a136cd1d153f244a392beb2e21e54339c857
BASE_IMAGE_DIGEST_3.14.10-alpine := sha256:cfe4b5079e5852da965ae14f74a6e2b137ece05b918d27c575fb70de3c85db2b
BASE_IMAGE_DIGEST_3.15.1-alpine := sha256:54448f67d7c31c39e5cdd3ea2d6382395ce142806c284425f8e897d78a0465b3

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
