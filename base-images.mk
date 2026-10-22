# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := python
BASE_IMAGE_VERSION_SUFFIX := -alpine

BASE_IMAGE_DIGEST_3.11.17-alpine := sha256:03c8e956bf1eee7763faf3a9fbb24b3ff9c0496cc2dbc5bcb0d6ac1f6268a287
BASE_IMAGE_DIGEST_3.12.15-alpine := sha256:92abd2ba1bdfb48b1e2ac224b582dd1558d0d4bb11c903b126b5bf9c448fd656
BASE_IMAGE_DIGEST_3.13.17-alpine := sha256:8f72324dfc4b4c94f1599faf1c037c8e74755d5dbbea63f1f51a89fa52f3ad07
BASE_IMAGE_DIGEST_3.14.9-alpine := sha256:d55673c233e28839c1c0c69766428cb6d50174a2ecfdcf915b6f58a0b0991562
BASE_IMAGE_DIGEST_3.15.1-alpine := sha256:e85751f6fe48ddb0619557d606ad93685134347a821b85fd9cd9dfa61addb970

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
