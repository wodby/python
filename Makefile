-include env_make

PYTHON_VER ?= 3.7.9
PYTHON_VER_MINOR := $(shell v='$(PYTHON_VER)'; echo "$${v%.*}")

BASE_IMAGE_TAG=$(PYTHON_VER)-alpine

REPO = wodby/python
NAME = python-$(PYTHON_VER_MINOR)

WODBY_USER_ID ?= 1000
WODBY_GROUP_ID ?= 1000

ifeq ($(TAG),)
    ifneq ($(PYTHON_DEBUG),)
        TAG ?= $(PYTHON_VER_MINOR)-debug
    else ifneq ($(PYTHON_DEV),)
    	TAG ?= $(PYTHON_VER_MINOR)-dev
    else
        TAG ?= $(PYTHON_VER_MINOR)
    endif
endif

ifneq ($(PYTHON_DEV),)
    NAME := $(NAME)-dev
endif

ifneq ($(STABILITY_TAG),)
    ifneq ($(TAG),latest)
        override TAG := $(TAG)-$(STABILITY_TAG)
    endif
endif

.PHONY: build test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) \
		--build-arg BASE_IMAGE_TAG=$(BASE_IMAGE_TAG) \
		--build-arg PYTHON_VER=$(PYTHON_VER) \
		--build-arg PYTHON_DEV=$(PYTHON_DEV) \
		--build-arg WODBY_USER_ID=$(WODBY_USER_ID) \
		--build-arg WODBY_GROUP_ID=$(WODBY_GROUP_ID) \
		./

test:
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
