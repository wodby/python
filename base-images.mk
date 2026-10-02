# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := python
BASE_IMAGE_VERSION_SUFFIX := -alpine

BASE_IMAGE_DIGEST_3.10.22-alpine := sha256:371434cf0ffbeba2736248d5d82226ebbbf4588921557ae6bb98a69b9a064d5b
BASE_IMAGE_DIGEST_3.11.17-alpine := sha256:6e8e92ffdad18e897bc1e20247f56e1364eb05132d0e306cc41839c9d21378f5
BASE_IMAGE_DIGEST_3.12.15-alpine := sha256:7a63cb93468d7ce5f24b1332a8f7a27f444b3221b0a3d6b5573036b78d937c78
BASE_IMAGE_DIGEST_3.13.16-alpine := sha256:1ac543fc677b1e24cfb220f2e9f2c73d6d9f1d5e718c2bbe5801cae34732f899
BASE_IMAGE_DIGEST_3.14.8-alpine := sha256:8acac70227ce3b34da9453120c375cc5b66cd0b062d4dc6bc74286f81a3819e1

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
