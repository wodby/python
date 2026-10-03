# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := python
BASE_IMAGE_VERSION_SUFFIX := -alpine

BASE_IMAGE_DIGEST_3.10.22-alpine := sha256:c3a48015ed1daf66afcafa7a02b7a24af8a51b8037964c03de578032556ec5b3
BASE_IMAGE_DIGEST_3.11.17-alpine := sha256:faa35f7f7a56c17c2796719f9903b42cb17d59e671a6a74bf85549432e38770e
BASE_IMAGE_DIGEST_3.12.15-alpine := sha256:8a001d79e5a57ae4de7faa57af12f3d589058ea06ac42ec850c1cb0ac325bd21
BASE_IMAGE_DIGEST_3.13.16-alpine := sha256:1ac543fc677b1e24cfb220f2e9f2c73d6d9f1d5e718c2bbe5801cae34732f899
BASE_IMAGE_DIGEST_3.14.8-alpine := sha256:8acac70227ce3b34da9453120c375cc5b66cd0b062d4dc6bc74286f81a3819e1

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
