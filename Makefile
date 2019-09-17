NODE_VER := $(shell cat .nvmrc)

DOCKER_ORG=stefanwalther
DOCKER_REPO=circleci-angular-sentry

GOOS=$(shell go env GOOS)
GOARCH=$(shell go env GOARCH)
GOMPLATE_VERSION=v1.9.1
GOMPLATE_URL=https://github.com/hairyhenderson/gomplate/releases/download
GOMPLATE_CURRENT_VERSION=v$(shell if [ -e ~/bin/gomplate ]; then ~/bin/gomplate -v | sed -e "s/^gomplate version //"; fi;)

SENTRY_CLI_URL=

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
	docker build --build-arg NODE_VER=$(NODE_VER) -t $(DOCKER_ORG)/$(DOCKER_REPO) -f Dockerfile.prod .
.PHONY: build

run:								## Run the container
	docker run -d $(DOCKER_ORG)/$(DOCKER_REPO)
.PHONY: run

exec:								## Start the container in exec mode
	docker exec -it $(DOCKER_ORG)/$(DOCKER_REPO) /bin/sh
.PHONY: exec

sentry-release:
	export DEBUG=1; \
	export SENTRY_AUTH_TOKEN=$(CIRCLECI_ANGULAR_SENTRY_API_TOKEN); \
	export SENTRY_ORG=stefanwalther; \
	export SENTRY_PROJECT=circleci-angular-sentry; \
	export SENTRY_PROJECT_VERSION=$(shell node -e "console.log(require('./package.json').version)"); \
	export SENTRY_LOG_LEVEL=info; \
	docker-compose --f=./docker-compose.sentry.yaml up;
.PHONY: sentry-release

circleci:
	$(MAKE) build
.PHONY: circleci
