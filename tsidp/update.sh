#!/usr/bin/env bash
# Update tsidp: track master of tailscale/tsidp, keeping the
# unstable-<date> version format, and refresh the src hash plus the Go
# vendorHash for the new rev.
set -euo pipefail
lib=${UPDATE_COMMON:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/update-common.sh}
source "$lib"

PKG=tsidp
cd "$(update_repo_root)"
require_cmds curl jq nix

file=tsidp/default.nix
old_rev=$(sed -n 's/ *rev = "\(.*\)";/\1/p' "$file")
old_version=$(nix_eval tsidp.version)

read -r sha date <<<"$(gh_latest_commit tailscale/tsidp)"
[[ -n $sha && -n $date ]] || die "could not determine the newest master commit"

# Even when the rev is current this refreshes the hashes and rebuilds, so a
# previously interrupted update converges.
new_version=unstable-$date
info "targeting ${sha:0:7} ($new_version), currently $old_rev ($old_version)"
sed_replace "$file" "$old_rev" "$sha"
sed_replace "$file" "$old_version" "$new_version"

# --version=skip refreshes the src hash and the vendorHash without touching
# the version we just wrote.
nix_update -F --version=skip tsidp
build tsidp

if [[ $sha != "$old_rev" ]]; then
  info "suggested commit: tsidp: update to ${sha:0:7}"
fi
info "note: the local patches may need adjusting for the new rev"
