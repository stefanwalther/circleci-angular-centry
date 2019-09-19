#!/usr/bin/env bash

set -e

# Respect RELEASE_VERSION if specified
[ -n "$RELEASE_VERSION" ] || export RELEASE_VERSION="${SENTRY_PROJECT}@$(git describe --always --long)";

if [ "$DEBUG" = true ]; then
  echo "======================================================================";
  echo "Running ./sentry-sli-init.sh";
  echo "~~";
  echo "SENTRY_AUTH_TOKEN: $SENTRY_AUTH_TOKEN";
  echo "SENTRY_PROJECT_VERSION: $SENTRY_PROJECT_VERSION";
  echo "SENTRY_ORG: $SENTRY_ORG";
  echo "SENTRY_PROJECT: $SENTRY_PROJECT";
  echo "SENTRY_LOG_LEVEL: $SENTRY_LOG_LEVEL";
  echo "GITHUB_PROJECT: $GITHUB_PROJECT";
  echo "RELEASE_VERSION: $RELEASE_VERSION";
  echo "======================================================================";
  echo "";
else
  echo "Debug is $DEBUG";
fi

sentry-cli --auth-token=${SENTRY_AUTH_TOKEN} projects --org=${SENTRY_ORG} list

# Create a new release
sentry-cli --auth-token=${SENTRY_AUTH_TOKEN} releases new "$RELEASE_VERSION"
sentry-cli --auth-token=${SENTRY_AUTH_TOKEN} releases --org=${SENTRY_ORG} --project=${SENTRY_PROJECT} set-commits --auto "$RELEASE_VERSION"
#--strip-prefix ~/work/
sentry-cli --auth-token=${SENTRY_AUTH_TOKEN} releases files "$RELEASE_VERSION" upload-sourcemaps "/work" -x .js -x .map --validate --verbose --rewrite --strip-common-prefix
sentry-cli --auth-token=${SENTRY_AUTH_TOKEN} releases finalize "$RELEASE_VERSION"

exit $1
