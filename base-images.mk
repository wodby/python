# Base image inputs shared by local builds and CI. Updated by wodby/images.
# Each digest identifies the complete multi-platform image index.
BASE_IMAGE_REPOSITORY := python
BASE_IMAGE_VERSION_SUFFIX := -alpine

BASE_IMAGE_DIGEST_3.11.17-alpine := sha256:5fb4bc53dd0180955e31e5245b648bbb24a4ac4ab03a1de81513642325220bcd
BASE_IMAGE_DIGEST_3.12.16-alpine := sha256:c566b41a6dede5cb51412ba90fd7b05b6e3005846db44b46b77e850083f8da6d
BASE_IMAGE_DIGEST_3.13.18-alpine := sha256:0029b1929b9d7e1d90e5a3033d39a136cd1d153f244a392beb2e21e54339c857
BASE_IMAGE_DIGEST_3.14.10-alpine := sha256:4f2aead8cbc38d88f7e029ad416b27894731422c65407cb2e2f9573cb992176b
BASE_IMAGE_DIGEST_3.15.1-alpine := sha256:54448f67d7c31c39e5cdd3ea2d6382395ce142806c284425f8e897d78a0465b3

# Fail before building when a version or variant has no reviewed pin.
BASE_IMAGE = $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG)@$(or $(BASE_IMAGE_DIGEST_$(BASE_IMAGE_TAG)),$(error No base image digest for $(BASE_IMAGE_REPOSITORY):$(BASE_IMAGE_TAG); update base-images.mk))
