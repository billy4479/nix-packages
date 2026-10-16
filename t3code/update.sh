#!/usr/bin/env bash
# Update t3code: latest pingdotgg/t3code release, plus the three fixed-output
# dependencies (both pnpm installs and the SPDX license cache), which
# nix-update rehashes via --custom-dep.
set -euo pipefail
lib=${UPDATE_COMMON:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/update-common.sh}
source "$lib"

PKG=t3code
cd "$(update_repo_root)"
require_cmds nix

old=$(nix_eval t3code.version)
nix_update -F --use-github-releases \
  --custom-dep nodeModules \
  --custom-dep prodNodeModules \
  --custom-dep spdxLicenses \
  t3code
build t3code
finish "$old" "$(nix_eval t3code.version)"

info "note: if the build fails on SPDX licenses, sync"
info "spdxLicenseListVersion/spdxLicenseListRevision in t3code/default.nix"
info "with upstream's third-party-licenses.config.json and re-run"
