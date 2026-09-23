-include env_make

PYTHON_VER ?= 3.14.7
PYTHON_VER_MINOR := $(shell v='$(PYTHON_VER)'; echo "$${v%.*}")

REPO = wodby/python
NAME = python-$(PYTHON_VER_MINOR)

PLATFORM ?= linux/arm64

ifeq ($(WODBY_USER_ID),)
    WODBY_USER_ID := 1000
endif

ifeq ($(WODBY_GROUP_ID),)
    WODBY_GROUP_ID := 1000
endif

ifeq ($(TAG),)
    ifneq ($(PYTHON_DEBUG),)
        TAG ?= $(PYTHON_VER_MINOR)-debug
    else ifneq ($(PYTHON_DEV),)
		ifeq ($(WODBY_USER_ID),501)
			TAG := $(PYTHON_VER_MINOR)-dev-macos
			NAME := $(NAME)-dev-macos
		else
			TAG := $(PYTHON_VER_MINOR)-dev
			NAME := $(NAME)-dev
		endif    
    else
        TAG ?= $(PYTHON_VER_MINOR)
    endif
endif

IMAGETOOLS_TAG ?= $(TAG)

ifneq ($(ARCH),)
	override TAG := $(TAG)-$(ARCH)
endif

.PHONY: build build-debug buildx-build buildx-push test push shell run start stop logs clean release

# Resolve the same pinned base image for every local and CI build target.
include base-images.mk
BASE_IMAGE_TAG = $(PYTHON_VER)-alpine

default: build

build:
	docker build --build-arg BASE_IMAGE="$(BASE_IMAGE)" -t $(REPO):$(TAG) \
		--build-arg PYTHON_VER=$(PYTHON_VER) \
		--build-arg PYTHON_DEV=$(PYTHON_DEV) \
		--build-arg WODBY_USER_ID=$(WODBY_USER_ID) \
		--build-arg WODBY_GROUP_ID=$(WODBY_GROUP_ID) \
		./

build-debug:
	docker build --build-arg BASE_IMAGE="$(BASE_IMAGE)" -t $(REPO):$(TAG) \
		--build-arg PYTHON_VER=$(PYTHON_VER) \
		--build-arg PYTHON_DEV=$(PYTHON_DEV) \
		--build-arg WODBY_USER_ID=$(WODBY_USER_ID) \
		--build-arg WODBY_GROUP_ID=$(WODBY_GROUP_ID) \
		--build-arg PECL_HTTP_PROXY=$(PECL_HTTP_PROXY) \
		--no-cache --progress=plain ./ 2>&1 | tee build.log

buildx-build:
	docker buildx build --build-arg BASE_IMAGE="$(BASE_IMAGE)" --platform $(PLATFORM) -t $(REPO):$(TAG) \
		--build-arg PYTHON_VER=$(PYTHON_VER) \
		--build-arg PYTHON_DEV=$(PYTHON_DEV) \
		--build-arg WODBY_USER_ID=$(WODBY_USER_ID) \
		--build-arg WODBY_GROUP_ID=$(WODBY_GROUP_ID) \
		./

buildx-push:
	docker buildx build --build-arg BASE_IMAGE="$(BASE_IMAGE)" --platform $(PLATFORM) --push -t $(REPO):$(TAG) \
		--build-arg PYTHON_VER=$(PYTHON_VER) \
		--build-arg PYTHON_DEV=$(PYTHON_DEV) \
		--build-arg WODBY_USER_ID=$(WODBY_USER_ID) \
		--build-arg WODBY_GROUP_ID=$(WODBY_GROUP_ID) \
		./

buildx-imagetools-create:
	docker buildx imagetools create -t $(REPO):$(IMAGETOOLS_TAG) \
				  $(REPO):$(TAG)-amd64 \
				  $(REPO):$(TAG)-arm64
.PHONY: buildx-imagetools-create 

test:
	cd ./tests && IMAGE=$(REPO):$(TAG) bash ./workspace-contract.sh
ifneq ($(PYTHON_DEV),)
	cd ./tests && IMAGE=$(REPO):$(TAG) ./run.sh
else
	@echo "We run tests only for DEV images."
endif

push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

release: build push

# Keep CI scans aligned with the version, variant and architecture built by make.
.PHONY: image-ref
image-ref:
	@printf '%s\n' '$(REPO):$(TAG)'
