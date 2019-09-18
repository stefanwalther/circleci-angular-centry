#!/usr/bin/env bash

if [ "$DEBUG" = true ]; then
  echo "======================================================================";
  echo "Running ./sentry-sli-init.sh";
  echo "~~";
  echo "SENTRY_AUTH_TOKEN: $SENTRY_AUTH_TOKEN";
  echo "SENTRY_PROJECT_VERSION: $SENTRY_PROJECT_VERSION";
  echo "SENTRY_ORG: $SENTRY_ORG";
  echo "SENTRY_PROJECT: $SENTRY_PROJECT";
  echo "SENTRY_LOG_LEVEL: $SENTRY_LOG_LEVEL";
  echo "======================================================================";
  echo "";
else
  echo "Debug is $DEBUG";
fi

# Temp
ls -la;

# Create a new release
sentry-cli releases new "$SENTRY_PROJECT_VERSION"
sentry-cli releases files "$SENTRY_PROJECT_VERSION" upload-sourcemaps "/" -x .js -x .map --validate --verbose --rewrite --strip-common-prefix
sentry-cli releases finalize "$SENTRY_PROJECT_VERSION"

VERSION=`sentry-cli releases propose-version`
sentry-cli releases set-commits "$SENTRY_PROJECT_VERSION" --auto


exit $1
