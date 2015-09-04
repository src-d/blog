# Configuration
HUGO_VERSION ?= 0.14
HUGO_THEME ?= https://github.com/spf13/hyde

# System
OS = amd64
ifeq ($(OS),Windows_NT)
    ARCH = windows
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
			ARCH = linux
    endif
    ifeq ($(UNAME_S),Darwin)
			ARCH = darwin
    endif
endif

# Environment
BASE_PATH := $(shell pwd)
BUILD_PATH := $(BASE_PATH)/.build
THEMES_PATH := $(BASE_PATH)/themes
THEME_NAME := $(shell basename $(HUGO_THEME))
THEME_PATH := $(THEMES_PATH)/$(THEME_NAME)
HUGO_PATH := $(BASE_PATH)/.hugo
HUGO_URL = github.com/spf13/hugo
HUGO_NAME := hugo_$(HUGO_VERSION)_$(ARCH)_$(OS)

# Tools
CURL = curl -L
HUGO = $(HUGO_PATH)/$(HUGO_NAME)/$(HUGO_NAME)
MKDIR = mkdir -p
GIT_CLONE = git clone

# Rules
all: build

dependencies:
	@if [[ ! -f $(HUGO) ]]; then \
		$(MKDIR) $(HUGO_PATH); \
		cd $(HUGO_PATH); \
		ext="zip"; \
		if [ "$(ARCH)" == "linux" ]; then ext="tar.gz"; fi; \
		file="hugo.$${ext}"; \
		$(CURL) https://$(HUGO_URL)/releases/download/v$(HUGO_VERSION)/$(HUGO_NAME).$${ext} -o $${file}; \
		if [ "$(ARCH)" == "linux" ]; then tar -xvzf $${file}; else unzip $${file}; fi; \
	fi;

	@if [[ ! -d $(THEME_PATH) ]]; then \
		$(MKDIR) $(THEMES_PATH); \
		cd $(THEMES_PATH); \
		git clone $(HUGO_THEME) $(THEME_NAME); \
	fi;

build: dependencies
	$(HUGO)

server: build
	$(HUGO) server -t $(THEME_NAME) -D -w

publish:
	git add -A
	git commit -m "updating site"
	git subtree push --prefix=public git@github.com:$(CIRCLE_PROJECT_USERNAME)/$(CIRCLE_PROJECT_REPONAME).git gh-pages

clean:
	rm -rf $(THEME_PATH)
