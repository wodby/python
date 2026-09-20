# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := python
BASE_IMAGE_VERSION_SUFFIX := -alpine

BASE_IMAGE_DIGEST_3.10.21-alpine := sha256:07a3e27a565ce2397efe9a371c9cd8d675827cb1151fe12ffc7498b447712c56
BASE_IMAGE_DIGEST_3.11.16-alpine := sha256:0495f5559318affa673172ec7e35cd0a5213e4aaf4c76d0a66554c0af97b157e
BASE_IMAGE_DIGEST_3.12.14-alpine := sha256:c4634f578a412db396771b61b064c6e546c9d6414c7fb5b1b05d5871f1885f7b
BASE_IMAGE_DIGEST_3.13.15-alpine := sha256:1a63a53928ce53d2b0baf08092a703f4840ac5dfbd61fd48802dbf48e08c801e
BASE_IMAGE_DIGEST_3.14.7-alpine := sha256:016508ba505da24f7139765bc4bb669df4e88eb2f12eeadd571bf2f88d7533df

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
