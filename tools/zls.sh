#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")"
cd "$(npx --yes @bazel/bazelisk info workspace)"
exec npx --yes @bazel/bazelisk run -- @zml//:completion "${@}"
