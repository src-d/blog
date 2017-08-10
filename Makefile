# Configuration
PROJECT ?= blog

HUGO_VERSION := 0.25.1
UNAME_S := $(shell uname -s)
OS := Linux
HUGO_TAR_FILE_NAME = hugo_$(HUGO_VERSION)_$(OS)-64bit.tar.gz
 +HUGO_URL = https://github.com/spf13/hugo/releases/download/v$(HUGO_VERSION)/$(HUGO_TAR_FILE_NAME)
HUGO_THEME ?= https://github.com/digitalcraftsman/hugo-steam-theme
DOCKER_ORG ?= quay.io/srcd

BASE_URL ?= "//localhost:1313/"

DOCKER_REGISTRY ?= quay.io
DOCKER_USERNAME ?=
DOCKER_PASSWORD ?=

SOURCE_BRANCH := master

# System
ifneq ($(UNAME_S),Linux)
ifeq ($(UNAME_S),Darwin)
OS := macOS
else
$(error "error Unexpected OS; Only Linux or Darwin supported.")
endif
endif

# Environment
SHELL := /bin/bash
BASE_PATH := $(shell pwd)
PUBLIC_PATH := $(BASE_PATH)/public
THEMES_PATH := $(BASE_PATH)/themes
STATIC_PATH := $(BASE_PATH)/static
THEME_NAME := $(shell basename $(HUGO_THEME))
THEME_PATH := $(THEMES_PATH)/$(THEME_NAME)
HUGO_PATH := $(BASE_PATH)/.hugo
HUGO_URL = https://github.com/spf13/hugo/releases/download/v$(HUGO_VERSION)/$(HUGO_TAR_FILE_NAME)
HUGO_NAME := hugo_$(HUGO_VERSION)_$(ARCH)_$(OS)
HUGO_URL_NAME := hugo_$(HUGO_VERSION)_$(URL_ARCH)-$(URL_OS)

# CI
TAG := master
ifneq ($(origin TRAVIS_COMMIT), undefined)
ifneq ($(TRAVIS_COMMIT),)
	TAG := $(shell echo $(TRAVIS_COMMIT) | cut -c -7)
endif
endif

# Tools
CURL = curl -L
HUGO = $(HUGO_PATH)/hugo
MKDIR = mkdir -p
GIT = git
DOCKER = sudo docker
UNCOMPRESS := tar -zxf

# Rules
all: build

init:
	@if [ "$(HUGO_THEME)" == "" ]; then \
		echo "ERROR! Please set the env variable 'HUGO_THEME' (http://mcuadros.github.io/autohugo/documentation/working-with-autohugo/)"; \
		exit 1; \
	fi;

dependencies: init
	@if [[ ! -f $(HUGO) ]]; then \
		$(MKDIR) $(HUGO_PATH); \
		cd $(HUGO_PATH); \
		echo "Downloading $(HUGO_URL)"; \
		$(CURL) $(HUGO_URL) -o $(HUGO_TAR_FILE_NAME); \
		$(UNCOMPRESS) $(HUGO_TAR_FILE_NAME); \
	fi;

foo:
	echo $(TAG)

build: dependencies
	$(HUGO) -t $(THEME_NAME) --baseURL $(BASE_URL)

server: build
	$(HUGO) server -t $(THEME_NAME) -D -w --baseURL $(BASE_URL)

docker-push: build
	$(DOCKER) login -u "$(DOCKER_USERNAME)" -p "$(DOCKER_PASSWORD)" $(DOCKER_REGISTRY)
	$(DOCKER) build -q -t $(DOCKER_ORG)/${PROJECT} -f $(BASE_PATH)/Dockerfile .
	$(DOCKER) tag $(DOCKER_ORG)/${PROJECT} $(DOCKER_ORG)/${PROJECT}:$(TAG)
	$(DOCKER) push $(DOCKER_ORG)/${PROJECT}:$(TAG)

docker-push-ci:
	if [[ "$(TRAVIS_PULL_REQUEST)" = "false" && "$(TRAVIS_BRANCH)" = "$(SOURCE_BRANCH)" ]]; then \
		make docker-push; \
	fi

clean:
	rm -rf $(HUGO_PATH)
	rm -rf $(THEME_PATH)
