# Configuration
PROJECT ?= blog

HUGO_VERSION ?= 0.17
HUGO_THEME ?= https://github.com/digitalcraftsman/hugo-steam-theme
DOCKER_ORG ?= quay.io/srcd

BASE_URL ?= "//localhost:1313/"

DOCKER_REGISTRY ?= quay.io
DOCKER_USERNAME ?=
DOCKER_PASSWORD ?=

# System
URL_OS = 64bit
OS = amd64
ifeq ($(OS),Windows_NT)
    ARCH = windows
    URL_ARCH = Windows
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
			ARCH = linux
			URL_ARCH = Linux
    endif
    ifeq ($(UNAME_S),Darwin)
			ARCH = darwin
			URL_ARCH = MacOS
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
HUGO_URL = github.com/spf13/hugo
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
HUGO = $(HUGO_PATH)/$(HUGO_NAME)/$(HUGO_NAME)
MKDIR = mkdir -p
GIT = git
DOCKER = sudo docker

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
		ext="zip"; \
		if [ "$(ARCH)" == "linux" ]; then ext="tar.gz"; fi; \
		file="hugo.$${ext}"; \
		$(CURL) https://$(HUGO_URL)/releases/download/v$(HUGO_VERSION)/$(HUGO_URL_NAME).$${ext} -o $${file}; \
		if [ "$(ARCH)" == "linux" ]; then tar -xvzf $${file}; else unzip $${file}; fi; \
	fi;
	@if [[ ! -d $(THEME_PATH) ]]; then \
		$(MKDIR) $(THEMES_PATH); \
		cd $(THEMES_PATH); \
		$(GIT) clone $(HUGO_THEME) $(THEME_NAME); \
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

clean:
	rm -rf $(HUGO_PATH)
	rm -rf $(THEME_PATH)
