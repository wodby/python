# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := python
BASE_IMAGE_VERSION_SUFFIX := -alpine

BASE_IMAGE_DIGEST_3.11.18-alpine := sha256:8b92101d156b060d6999d3382bbe98f6851fbbf7c4bddbe3833818f3565d2b4c
BASE_IMAGE_DIGEST_3.12.16-alpine := sha256:213242b537a1c166a0c53e903461fc18d5518e7196c93dbecda452660a848918
BASE_IMAGE_DIGEST_3.13.18-alpine := sha256:4d511039677430640754cd1417737349067dfcdaba4dcf7e576334516f9f4c30
BASE_IMAGE_DIGEST_3.14.10-alpine := sha256:b15fd707501f872b2d46a8edacb18aca52db393460d17a60a20e7231dbdb3263
BASE_IMAGE_DIGEST_3.15.2-alpine := sha256:d499023466546cd88a358f80b46fba4016f32597bc4482bb1c47b483a07d457d

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
