# Nix Packages

This repo contains my own nix packages.
I don't think I'll upstream them to nixpkgs or NUR as they are either a complete hack or not I'm not sure about licensing issues.
I have this repo for personal use only.

## Packaging

Check Nixpkgs before adding a package and follow its manual for the relevant
build system. Nixpkgs already provides `opencode`, `t3code`, `tsidp`, and
`tailscale.derper`; the local packages retain their own versions and customizations.

Prefer standard build helpers and phases, preserve phase hooks, and annotate
embedded scripts with their language. Use `stdenvNoCC` when no compiler is needed,
keep build tools out of runtime dependencies, and install only runtime files.
Native Node.js addons still need a compiler, even when the application is JavaScript.

Before committing, run `nixfmt`, `statix check .`, `deadnix --fail .`, and
`nix flake check --no-build`. Build changed packages and their `passthru.tests`
where provided. Compare `nix path-info --closure-size` before and after dependency
changes rather than assuming the closure is smaller.

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
