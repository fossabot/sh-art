#!/usr/bin/env bash
## Builder
readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="basic unit and integration testing (part of the dc-tooling suite)"
readonly CLI_USAGE="[-s] [--type=unit|integration] --test=test_dirs_or_files source_files_or_directories"

dc::commander::init

dc::argv::flag::validate tests

type=unit
if [ "$DC_ARGE_TYPE" ]; then
  dc::argv::flag::validate type "^(integration|unit)$"
  type="$DC_ARGV_TYPE"
fi

if [ "$type" == "unit" ]; then
  # Unit test, source the source files
  for k in "$@"; do
    if [ -d "$k" ]; then
      for l in "$k/"*.sh; do
        # shellcheck source=/dev/null
        . "$l"
      done
    else
      # shellcheck source=/dev/null
      . "$k"
    fi
  done
else
  # Integration, treat the argument as the path where to find the binaries
  for k in "$@"; do
    PATH="$k:$PATH"
  done
fi

# Now, run these tests
while read -r k; do
  printf "%s\\n" "Running $type test suite: $k"
  # shellcheck source=/dev/null
  . "$k"
done < <(
  if [ -d "$DC_ARGV_TESTS" ]; then
    ls "$DC_ARGV_TESTS/"*.sh
  else
    echo "$DC_ARGV_TESTS"
  fi
)