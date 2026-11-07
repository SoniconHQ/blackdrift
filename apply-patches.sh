#!/usr/bin/env bash
# Apply the Blackdrift patches to a Firefox checkout at the commit named in UPSTREAM.md.
# Usage: apply-patches.sh <firefox-src> [--dry-run]
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="${1:-}"; dry=()
[ -d "$src" ] || { echo "usage: $0 <firefox-src> [--dry-run]" >&2; exit 2; }
src="$(cd "$src" && pwd)"
[ "${2:-}" = "--dry-run" ] && dry=(--dry-run)

# shellcheck source=/dev/null
. "$here/UPSTREAM.md" 2>/dev/null || true
if [ -n "${FIREFOX_REV:-}" ] && git -C "$src" rev-parse HEAD >/dev/null 2>&1; then
  head="$(git -C "$src" rev-parse HEAD)"
  [ "$head" = "$FIREFOX_REV" ] || { echo "firefox-src is at $head, patches target $FIREFOX_REV" >&2; exit 1; }
fi

apply_group() {
  local group="$1" target="$2" f
  [ -d "$src/$target" ] || { echo "missing $target in $src" >&2; exit 1; }
  while IFS= read -r -d '' f; do
    echo "apply ${f#"$here"/}"
    (cd "$src/$target" && patch -p1 --batch --forward --no-backup-if-mismatch "${dry[@]}" < "$f")
  done < <(find "$here/patches/$group" -maxdepth 1 -type f -name '*.patch' -print0 2>/dev/null | sort -z)
}
apply_group tree .
apply_group components mobile/android/android-components
apply_group focus-android mobile/android/focus-android
echo "done"
