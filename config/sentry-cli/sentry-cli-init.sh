#!/usr/bin/env bash

export SENTRY_ORG=stefanwalther
export SENTRY_PROJECT=circleci-angular-sentry
export SENTRY_LOG_LEVEL=debug

echo "Current version: $SENTRY_PROJECT_VERSION"

sentry-cli releases new "$SENTRY_PROJECT_VERSION"
