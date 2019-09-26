NODE_VER := $(shell cat .nvmrc)

OS_NAME := $(shell uname -s | tr A-Z a-z)

ifeq ($(CIRCLE_SHA1),)
RELEASE_VERSION := $(shell git describe --always --long)
else
RELEASE_VERSION := $(CIRCLE_SHA1)
endif

DOCKER_ORG=stefanwalther
DOCKER_REPO=circleci-angular-sentry

help:								## Show this help.
	@echo ''
	@echo 'Available commands:'
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ''
.PHONY: help

gen-readme:							## Generate README.md (using docker-verb)
	docker run --rm -v ${PWD}:/opt/verb stefanwalther/verb
.PHONY: gen-readme

build:								## Build the docker image (prod)
	NODE_VER=$(NODE_VER)
	@echo 'RELEASE_VERSION: $(RELEASE_VERSION)'
	@echo 'OS: $(OS_NAME)'
	@echo '---'

	docker build --build-arg release_version=$(RELEASE_VERSION) -t $(DOCKER_ORG)/$(DOCKER_REPO) -f Dockerfile.prod .
.PHONY: build

run:								## Run the container
	docker run -p 8080:80 -d $(DOCKER_ORG)/$(DOCKER_REPO)
.PHONY: run

clean:								## Delete all local containers belonging to this project
	docker ps -a -q  --filter ancestor=stefanwalther/circleci-angular-sentry
.PHONY:clean

exec:								## Start the container in exec mode
	docker exec -it $(DOCKER_ORG)/$(DOCKER_REPO) /bin/sh
.PHONY: exec

build-release: build sentry-release ## Build & Release
.PHONY: build-release

sentry-release:						## Do the sentry release
	export DEBUG=1; \
	export SENTRY_AUTH_TOKEN=$(CIRCLECI_ANGULAR_SENTRY_API_TOKEN); \
	export SENTRY_ORG=stefanwalther; \
	export SENTRY_PROJECT=circleci-angular-sentry; \
	export GITHUB_PROJECT=stefanwalther/circleci-angular-sentry; \
	export SENTRY_PROJECT_VERSION=$(shell node -e "console.log(require('./package.json').name)")@$(shell node -e "console.log(require('./package.json').version)"); \
	export SENTRY_LOG_LEVEL=debug; \
	export RELEASE_VERSION=$(RELEASE_VERSION); \
	docker-compose --f=./docker-compose.sentry.yaml run sentry-cli
	#&& docker-compose --f=./docker-compose.sentry.yaml down -t 0;
.PHONY: sentry-release

circleci:
	$(MAKE) build
.PHONY: circleci

os:
	@echo $(OS_NAME)
.PHONY: os
