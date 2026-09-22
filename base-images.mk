# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := python
BASE_IMAGE_VERSION_SUFFIX := -alpine

BASE_IMAGE_DIGEST_3.10.21-alpine := sha256:8d62622e4ad0e5adfd01efecd25a0a5ea571a22aaaeff481796ce10828d46504
BASE_IMAGE_DIGEST_3.11.16-alpine := sha256:cd04730b8511def3fbf14204d66a0c1536f290b8e896ed5a94cd64cb15ac1356
BASE_IMAGE_DIGEST_3.12.14-alpine := sha256:4c47124a8391cb7a9f571164147d154777cf012a4ece5f86097130d7a4478111
BASE_IMAGE_DIGEST_3.13.15-alpine := sha256:79e7a9b9ff1cbceff819f856fb374477792a5967759d94df266de7b7b4120e6f
BASE_IMAGE_DIGEST_3.14.7-alpine := sha256:9e9fde4d32eedce0b661d9ab91e826b62dddf28e928c230ec55f1866cac66b01

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
