#!/usr/bin/env bash
# Upload Chicago Charter Bus Rental packages one by one.
# Snapcraft is intentionally LAST. No GitHub Actions.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
HOMEPAGE="https://chicagosupercoachbus.com/"

step() { echo; echo "========== $* =========="; }

need() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing tool: $1"; return 1; }
}

pause() {
  read -r -p "Press Enter to continue (or Ctrl-C to stop)…" _
}

# --- 1. Docker Hub ---
step "1/10 Docker Hub"
need docker
: "${DOCKER_USER:?Set DOCKER_USER=your-dockerhub-username}"
docker build -t "${DOCKER_USER}/chicago-charter-bus-rental:1.0.0" -t "${DOCKER_USER}/chicago-charter-bus-rental:latest" "$ROOT/docker"
docker login
docker push "${DOCKER_USER}/chicago-charter-bus-rental:1.0.0"
docker push "${DOCKER_USER}/chicago-charter-bus-rental:latest"
echo "Done. Homepage label: $HOMEPAGE"
pause

# --- 2. Packagist ---
step "2/10 Packagist"
echo "Packagist needs a public VCS URL. Create a Git repo for packagist/ then:"
echo "  1) Push packagist/ contents to a public Git host"
echo "  2) Submit at https://packagist.org/packages/submit"
echo "  Package: nbkdevs/chicago-charter-bus-rental"
pause

# --- 3. PyPI ---
step "3/10 PyPI"
need python3
cd "$ROOT/pypi"
python3 -m venv .venv
.venv/bin/pip install -U build twine
.venv/bin/python -m build
.venv/bin/twine upload dist/*
pause

# --- 4. Crates.io ---
step "4/10 Crates.io"
need cargo
cd "$ROOT/crates"
cargo publish
pause

# --- 5. NuGet ---
step "5/10 NuGet"
need dotnet
cd "$ROOT/nuget"
dotnet pack -c Release -o ./nupkg
: "${NUGET_API_KEY:?Set NUGET_API_KEY}"
dotnet nuget push "./nupkg/*.nupkg" --api-key "$NUGET_API_KEY" --source https://api.nuget.org/v3/index.json
pause

# --- 6. npm ---
step "6/10 npm"
need npm
cd "$ROOT/npm"
npm login
npm publish --access public
pause

# --- 7. RubyGems ---
step "7/10 RubyGems"
need gem
cd "$ROOT/rubygems"
gem build chicago_charter_bus_rental.gemspec
gem push chicago_charter_bus_rental-1.0.0.gem
pause

# --- 8. pub.dev ---
step "8/10 pub.dev"
need dart
cd "$ROOT/pub_dev"
dart pub publish
pause

# --- 9. Smithery AI ---
step "9/10 Smithery AI"
echo "Upload folder: $ROOT/smithery-ai/chicago-group-travel"
echo "https://smithery.ai — create/publish skill from SKILL.md"
pause

# --- 10. Snapcraft (LAST) ---
step "10/10 Snapcraft (LAST — local only, no CI)"
need snapcraft
cd "$ROOT/snapcraft/snap"
chmod +x info.sh
snapcraft pack
snapcraft login
snapcraft upload --release=stable chicago-charter-bus-rental_*.snap

echo
echo "All steps finished."
