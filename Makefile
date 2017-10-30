# Default shell
SHELL := /bin/bash

# Configuration
HUGO_VERSION := 0.30.2
PORT ?= 8484
BASE_URL ?= "//localhost:$(PORT)/"

# Environment
OS := Linux
UNAME_S := $(shell uname -s)
SHARED_PATH ?= $(shell pwd)

HUGO_THEME_NAME := hugo-steam-theme
HUGO_TAR_FILE_NAME = hugo_$(HUGO_VERSION)_$(OS)-64bit.tar.gz
HUGO_URL = https://github.com/spf13/hugo/releases/download/v$(HUGO_VERSION)/$(HUGO_TAR_FILE_NAME)
HUGO_PATH := $(SHARED_PATH)/.hugo
HUGO_TAR_PATH := $(HUGO_PATH)/$(HUGO_TAR_FILE_NAME)

# System
ifneq ($(UNAME_S),Linux)
ifeq ($(UNAME_S),Darwin)
OS := macOS
else
$(error "error Unexpected OS; Only Linux or Darwin supported.")
endif
endif

# Tools
CURL := curl -L
HUGO := $(HUGO_PATH)/hugo
MKDIR := mkdir -p
JS_PACKAGE_MANAGER := yarn
UNCOMPRESS := tar -zxf

# Rules
all: build

# Ensures the Hugo binary existance
$(HUGO): $(HUGO_TAR_PATH)
	$(UNCOMPRESS) $(HUGO_TAR_PATH) --directory=$(HUGO_PATH);

# Downloads the hugo binary
$(HUGO_TAR_PATH):
	echo "Downloading $(HUGO_URL)"
	$(MKDIR) $(HUGO_PATH)
	$(CURL) $(HUGO_URL) -o $(HUGO_TAR_PATH)

# Ensures hugo dependencies
hugo-dependencies: $(HUGO_TAR_PATH) $(HUGO)

# Prepares yarn
js-dependencies:
	$(JS_PACKAGE_MANAGER) install --force
	$(JS_PACKAGE_MANAGER) build

# Prepares project dependencies
project-dependencies: hugo-dependencies js-dependencies

# Builds hugo
hugo-build:
	$(HUGO) -t $(HUGO_THEME_NAME) --baseURL $(BASE_URL)

## Builds project
build: project-dependencies hugo-build

# Runs hugo server
hugo-server:
	$(HUGO) server --port=$(PORT) -t $(HUGO_THEME_NAME) --buildDrafts --watch --baseURL $(BASE_URL)
