# Configuration
HUGO_VERSION ?= 0.17
HUGO_THEME ?= ""
GIT_COMMITTER_NAME ?= autohugo
GIT_COMMITTER_EMAIL ?= autohugo@autohugo.local
CNAME ?= ""

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

# Tools
CURL = curl -L
HUGO = $(HUGO_PATH)/$(HUGO_NAME)/$(HUGO_NAME)
MKDIR = mkdir -p
GIT = git

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

build: dependencies
	$(HUGO) -t $(THEME_NAME)

server: build
	$(HUGO) server -t $(THEME_NAME) -D -w

publish: init
	@if [ "$(CI)" == "" ]; then \
		echo "ERROR! Publish should be called only on CircleCI"; \
	  exit 1; \
	fi;
	@if [ "$(CNAME)" != "" ]; then \
		echo $(CNAME) >> $(PUBLIC_PATH)/CNAME; \
	fi;
	cp -rf $(THEME_PATH)/static/* $(PUBLIC_PATH)/
	cp -rf $(STATIC_PATH)/* $(PUBLIC_PATH)/
	rm .gitignore
	$(GIT) config user.email "$(GIT_COMMITTER_EMAIL)"
	$(GIT) config user.name "$(GIT_COMMITTER_NAME)"
	$(GIT) add -A
	$(GIT) commit -m "updating site [ci skip]"
	$(GIT) push origin :gh-pages || true
	$(GIT) subtree push --prefix=public git@github.com:$(CIRCLE_PROJECT_USERNAME)/$(CIRCLE_PROJECT_REPONAME).git gh-pages

clean:
	rm -rf $(HUGO_PATH)
	rm -rf $(THEME_PATH)
