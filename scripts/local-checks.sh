#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ -n "${LOCAL_CHECKS_PYTHON:-}" ]]; then
  export PATH="$(dirname "$LOCAL_CHECKS_PYTHON"):$PATH"
fi
rspec spec/security
