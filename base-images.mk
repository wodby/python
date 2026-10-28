# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := python
BASE_IMAGE_VERSION_SUFFIX := -alpine

BASE_IMAGE_DIGEST_3.11.18-alpine := sha256:1183ff3996670843850a0a6c1f10fd984c73ca4f771bc0cb74ea843ff54bafe3
BASE_IMAGE_DIGEST_3.12.16-alpine := sha256:44bf3bcc455e0c9ccd912b78f39019b2f7e9d2f4fb47c6d6973c7638a99aff14
BASE_IMAGE_DIGEST_3.13.18-alpine := sha256:bbc0290146ebe0a8b9a8ed07d3f2c7bdeb4d917fc93300a4e47490c8b5a11b48
BASE_IMAGE_DIGEST_3.14.10-alpine := sha256:cfe4b5079e5852da965ae14f74a6e2b137ece05b918d27c575fb70de3c85db2b
BASE_IMAGE_DIGEST_3.15.1-alpine := sha256:54448f67d7c31c39e5cdd3ea2d6382395ce142806c284425f8e897d78a0465b3

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
