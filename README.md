# Nix Packages

This repo contains my own nix packages.
I don't think I'll upstream them to nixpkgs or NUR as they are either a complete hack or not I'm not sure about licensing issues.
I have this repo for personal use only.

## Updating packages

Every package with an upstream has an `update.sh` next to it (wired up as
`passthru.updateScript`). From the repository root:

    ./update.sh                  # update everything
    ./update.sh derper tsidp     # update a subset
    ./derper/update.sh           # update a single package

The scripts bump the version and refresh every hash themselves — including
lock files like `deps.json` and the node_modules hashes — and then build the
package as verification. Nothing is committed automatically.

Requirements: nix with flakes, `curl` and `jq`; `nix-update` is fetched from
the nixpkgs registry when not installed. Set `GITHUB_TOKEN` to raise the
GitHub API rate limit.

`searxng-cli` has no update script on purpose, and `prefetch-all-images` has
no upstream to track.
