# Blackdrift: source patches

This repository is the **source for the modified Mozilla files** in
[Blackdrift](https://sonicon.org), a privacy-focused Android browser built from
Firefox Focus. It is published to meet the source-availability terms of the
Mozilla Public License 2.0 (MPL-2.0) for each released binary.

Blackdrift is not affiliated with or endorsed by Mozilla. "Firefox" and
"Focus" are trademarks of the Mozilla Foundation.

## Base build

| | |
| --- | --- |
| Upstream | [`mozilla-firefox/firefox`](https://github.com/mozilla-firefox/firefox) |
| Firefox version | **159.0.1** |
| Upstream tag | `FIREFOX_159_0_1_RELEASE` |
| Upstream commit | `6181e6b5f28a8fbae1d5c3ef6f6626b5a2180213` |
| Android package | `org.sonicon.browser` |

Every patch here applies to exactly that commit. Nothing from Mozilla is
copied into this repository.

## Layout

```text
patches/tree/          applied at the repository root of the Firefox tree
patches/components/    applied at mobile/android/android-components/
patches/focus-android/ applied at mobile/android/focus-android/
patches/README.md      what each patch does
apply-patches.sh       applies them all, in order, to a Firefox checkout
UPSTREAM.md            the pinned upstream, machine-readable
```

Patches in a directory apply in filename order, with `patch -p1` run from that
directory's target. The three directories apply in the order above.

## Reproduce the source

```bash
git clone https://github.com/mozilla-firefox/firefox firefox-src
git -C firefox-src checkout 6181e6b5f28a8fbae1d5c3ef6f6626b5a2180213
./apply-patches.sh firefox-src
```

`apply-patches.sh <firefox-src> --dry-run` checks that every patch applies
without changing anything. After it runs, `firefox-src` is the Blackdrift
source for this version, ready to build with Mozilla's own Android build
instructions (`./mach build`, then `./mach gradle focus-android:assembleFocusRelease`).
Blackdrift's release version numbers are set through the `-PblackdriftVersionName`
and `-PblackdriftVersionCode` Gradle properties (patch `0300`).

## Releases

Each Blackdrift release has a tag in this repository (for example
`v1.2.3+45`) pointing at the exact patches that were built. The base build
above is the one on the default branch; a tag carries its own `UPSTREAM.md`.

## License

The patches modify Mozilla source files and are licensed under the
[Mozilla Public License 2.0](LICENSE), like the files they modify. Files the
patches add are also released under MPL-2.0. Mozilla's own source keeps its
upstream licenses and notices.
