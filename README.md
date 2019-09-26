# circleci-angular-sentry

> Test a build for Angular with uploads of sourcemaps to sentry.io

---

## Purpose

... install instructions here ...

## Implementation Instructions

<details>
<summary>Install necessary dependencies</summary>

```js
npm install cross-env --save-dev
npm install replace --save-dev
```

</details>

<details>
<summary>Changes in `./.circleci/config.yml`</summary>

**Add sentry-release task in `./.circleci/config.yml`**

```yaml
  - run:
      name: sentry.io release
      command: make sentry-release
```

</details>

<details>
<summary>Changes in `makefile`</summary>

**Ensure the following header:**

```bash
ifeq ($(CIRCLE_SHA1),)
RELEASE_VERSION := $(shell git describe --always --long)
else
RELEASE_VERSION := $(CIRCLE_SHA1)
endif

DOCKER_ORG=stefanwalther
DOCKER_REPO=circleci-angular-sentry
```

**Change build task:**

````bash
build:								## Build the docker image (prod)
	NODE_VER=$(NODE_VER)
	@echo 'RELEASE_VERSION: $(RELEASE_VERSION)'
	@echo 'OS: $(OS_NAME)'
	@echo '---'

	docker build --build-arg release_version=$(RELEASE_VERSION) -t $(DOCKER_ORG)/$(DOCKER_REPO) -f Dockerfile.prod .
.PHONY: build
````

**Add `sentry-release` task:**

```bash
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
```

</details>

<details>
<summary>Changes in `dockerfile.prod`</summary>

Use the `build:prod` instead of the `build` task

```bash
RUN npm run build:prod
```

</details>

<details>
<summary>Changes on CircleCI</summary>

Add the environment variable `CIRCLECI_ANGULAR_SENTRY_API_TOKEN` to CircleCI.
</details>

<details>
<summary>Create the `docker-compose.sentry.yml` file</summary>

```yaml
version: '2'

services:

  app:
    image: stefanwalther/circleci-angular-sentry
    container_name: app
    ports:
      - "8080:80"
    volumes:
      - app-volume:/usr/share/nginx/html

  sentry-cli:
    image: getsentry/sentry-cli
    container_name: sentry-cli
    tty: true
    depends_on:
      - app
    environment:
      - DEBUG=true
      - SENTRY_AUTH_TOKEN=${SENTRY_AUTH_TOKEN}
      - SENTRY_PROJECT_VERSION=${SENTRY_PROJECT_VERSION}
      - SENTRY_ORG=${SENTRY_ORG}
      - SENTRY_PROJECT=${SENTRY_PROJECT}
      - SENTRY_LOG_LEVEL=${SENTRY_LOG_LEVEL}
      - RELEASE_VERSION=${RELEASE_VERSION}
      - GITHUB_PROJECT=${GITHUB_PROJECT}
      - PROJECT_DIR=/work
    volumes:
      - app-volume/:/work
      - ./config/sentry-cli/:/work/sentry-cli/
    command: >
      sh -c "sh ./sentry-cli/sentry-cli-init.sh"

volumes:
  app-volume:

```

</details>

<details>
<summary>Add the `./config/sentry-cli/sentry-cli-init.sh` file</summary>

See [here](./config/sentry-cli/sentry-cli-init.sh)

</details>

<details>
<summary>Changes in `angular.json`</summary>

**Check that in angular.json the following section looks as follows**

```json

"configurations": {
    "production": {
      "fileReplacements": [
        {
          "replace": "src/environments/environment.ts",
          "with": "src/environments/environment.prod.ts"
        }
      ],
      "optimization": true,
      "outputHashing": "all",
      // See here: https://medium.com/angular-athens/make-angulars-source-code-available-to-sentry-with-gitlab-ci-b3020bd60ae6
      "sourceMap": {
        "hidden": true,
        "scripts": true,
        "styles": true
      },
      "extractCss": true,
      "namedChunks": false,
      "aot": true,
      "extractLicenses": false,
    }
  }

```

</details>

<details>
<summary>environment settings</summary>

**environment.ts settings**

_environment.ts:_
```typescript
export const environment = {
  production: true,
  version: '%RELEASE_VERSION%'
};
```

_environment.prod.ts:_
```typescript
export const environment = {
  production: true,
  version: '%RELEASE_VERSION%'
};
```

</details>

<details>
<summary>Changes in `package.json`</summary>

**Adapt scripts in [package.json](./package.json)**

```js
    "build:prod": "cross-env RELEASE_VERSION=${RELEASE_VERSION:=unknown} ng build --prod --output-path=dist --source-map",
    "prebuild:prod": "cross-env RELEASE_VERSION=${RELEASE_VERSION:=unknown} echo \"Replacing %RELEASE_VERSION% with '$RELEASE_VERSION'\" && replace '%RELEASE_VERSION%' $RELEASE_VERSION src/environments/environment.prod.ts",
    "postbuild:prod": "cross-env RELEASE_VERSION=${RELEASE_VERSION:=unknown} echo \"Resetting RELEASE_VERSION\" && replace $RELEASE_VERSION '%RELEASE_VERSION%' src/environments/environment.prod.ts",

```

</details>

<details>
<summary>Changes in [sentry-error-handler.ts](./src/_lib/sentry-error-handler.ts)</summary>

```typescript
import {environment} from 'src/environments/environment';
```

```typescript
Sentry.init({
    dsn: this.settingsService.settings.sentryDsn,
    environment: this.settingsService.settings.environment,
    release: `${environment.version}`
    });
```

</details>

## About

### Author
**Stefan Walther**

* [twitter](http://twitter.com/waltherstefan)  
* [github.com/stefanwalther](http://github.com/stefanwalther) 
* [LinkedIn](https://www.linkedin.com/in/stefanwalther/)  
* [stefanwalther.io](http://stefanwalther.io) - Private blog

### Contributing
Pull requests and stars are always welcome. For bugs and feature requests, [please create an issue](https://github.com/stefanwalther/circleci-angular-sentry/issues). The process for contributing is outlined below:

1. Create a fork of the project
2. Work on whatever bug or feature you wish
3. Create a pull request (PR)

I cannot guarantee that I will merge all PRs but I will evaluate them all.

### License
MIT

***

_This file was generated by [verb-generate-readme](https://github.com/verbose/verb-generate-readme), v0.6.0, on September 26, 2019._

