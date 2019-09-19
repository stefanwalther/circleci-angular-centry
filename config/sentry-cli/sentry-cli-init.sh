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
  echo "GITHUB_PROJECT: $GITHUB_PROJECT";
  echo "COMMIT_VER: $COMMIT_VER";
  echo "======================================================================";
  echo "";
else
  echo "Debug is $DEBUG";
fi

# Create a new release
sentry-cli releases new "$COMMIT_VER"
sentry-cli releases set-commits --auto "$COMMIT_VER"
#--strip-prefix ~/work/
sentry-cli releases files "$COMMIT_VER" upload-sourcemaps "/" -x .js -x .map --validate --verbose --rewrite --strip-common-prefix --strip-prefix ~/work/
sentry-cli releases finalize "$COMMIT_VER"

exit $1
