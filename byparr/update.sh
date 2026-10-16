#!/usr/bin/env bash
# Update byparr: latest ThePhaseless/Byparr release, repinning the fetchTree
# rev + narHash in source.nix and the version in default.nix.
set -euo pipefail
lib=${UPDATE_COMMON:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/update-common.sh}
source "$lib"

PKG=byparr
cd "$(update_repo_root)"
require_cmds curl jq nix

repo=ThePhaseless/Byparr
old=$(nix_eval byparr.version)

tag=$(gh_latest_release "$repo")
[[ -n $tag ]] || die "no latest release found for $repo"
new=${tag#v}

# Even when current, rebuild so a previously interrupted update converges.
info "targeting $new, currently $old"
sha=$(gh_api "/repos/$repo/commits/$tag" | jq -r '.sha')
[[ -n $sha && $sha != "null" ]] || die "could not resolve $tag to a commit"
nar=$(nix flake prefetch "github:$repo/$sha" --json | jq -r '.hash')
[[ -n $nar && $nar != "null" ]] || die "could not prefetch $repo@$sha"

source_file=byparr/source.nix
old_rev=$(sed -n 's/ *rev = "\(.*\)";/\1/p' "$source_file")
old_nar=$(sed -n 's/ *narHash = "\(.*\)";/\1/p' "$source_file")
[[ -n $old_rev && -n $old_nar ]] || die "could not read the pinned rev/narHash from $source_file"

sed_replace "$source_file" "$old_rev" "$sha"
sed_replace "$source_file" "$old_nar" "$nar"
sed_replace byparr/default.nix "version = \"$old\"" "version = \"$new\""

build byparr
finish "$old" "$new"
