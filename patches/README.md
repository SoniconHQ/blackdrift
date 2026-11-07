# Blackdrift Patches

Patches that customize the upstream Firefox/Focus source tree. They are applied
by `scripts/patch.sh` after `scripts/fetch.sh` extracts the upstream snapshot.

## Layout

| Directory | Applied at (relative to upstream tree)    | Use for                  |
| --------- | ----------------------------------------- | ------------------------ |
| `focus-android/` | `mobile/android/focus-android/`    | Focus UI / branding      |
| `components/`    | `mobile/android/android-components/` | Mozilla a-c overrides  |
| `tree/`          | repo root                          | Gecko or anywhere else   |

Patches within a directory are applied in **lexicographic order**. A four-digit
prefix controls sequencing. In `focus-android/` the prefixes are grouped by
hundreds, so each group has room to grow:

| Range | Group |
| ----- | ----- |
| `0001`–`0099` | Identity (application ID, app name) |
| `0100`–`0199` | Telemetry off |
| `0200`–`0299` | Branding |
| `0300`–`0399` | Play (version, bundle) |

`components/` and `tree/` number their own series from `0001`. `workspace.sh
export` without `--number` takes the bucket's highest number + 1, which in
`focus-android/` is the Play group; pass `--number` for a patch in any other
group.

## Current patches (Phase 9 branding, in progress by explicit user request)

| Patch | Effect |
| ----- | ------ |
| `components/0001-search-serialize-engine-loads.patch` | Stability: `SearchMiddleware` runs one engine load at a time, so 0207's first-run Startpage save cannot race a parallel load's custom-engine listing (the 1-in-5 first-launch `XmlPullParserException: END_DOCUMENT` crash on 159) |
| `focus-android/0001-set-blackdrift-application-id.patch` | Focus flavor application ID `org.sonicon.browser` (`focusDebug` → `org.sonicon.browser.debug`); launcher shortcuts retargeted |
| `focus-android/0002-rename-app-to-blackdrift.patch` | Launcher label / `app_name` → `Blackdrift` |
| `focus-android/0100-disable-glean-usage-ping.patch` | Telemetry off: Glean upload hard-disabled, both usage pings disabled, daily usage ping default `false`, "Data Choices" settings category removed, Privacy & Security summary → non-translatable "Tracking, cookies", androidTest `SettingsPrivacyMenuRobot` no longer checks the removed "Send usage data" switch |
| `focus-android/0101-disable-nimbus-fetch.patch` | Telemetry off: no app-side Nimbus experiment fetch; the app's Nimbus uses only compiled-in defaults and the bundled `initial_experiments`. Gecko's experiment collections are `tree/0001` |
| `focus-android/0102-disable-crash-reporting.patch` | Telemetry off: no crash upload services (Socorro/Sentry), crash reporter disabled, "send crash report" box hidden on the tab-crash screen, always-empty "Crashes" item removed from Settings → About. Gecko still writes minidumps locally (GeckoView needs them for the tab-crash screen); 0106 deletes them |
| `focus-android/0103-telemetry-no-uploader-no-usage-service.patch` | Telemetry off: Glean gets a no-op uploader (no ping can leave the device, whatever its flags), the usage-reporting service never starts, `isDailyUsagePingEnabled` is always `false`, `DailyUsageReportingSwitchPreference` is deleted, Nimbus gets no endpoint URL |
| `focus-android/0104-no-webcompat-reporter.patch` | Telemetry off: the "Report broken site" WebCompat reporter (posts page URL and diagnostics to Mozilla's webcompat.com on tap) is not installed and its menu item never shows |
| `focus-android/0106-no-local-crash-dumps.patch` | Telemetry off: new `CrashDumpCleaner` deletes Gecko's minidumps and `.extra` files (which hold the crashed page's URL) in `files/mozilla/Crash Reports/pending`, `Crash Reports/events` and `files/minidumps` at app start, after a tab crash and whenever the last tab goes (erase button, notification, erase shortcuts, swipe from recents, last tab closed). Patched 2026-11-06, not yet verified on a build |
| `focus-android/0107-no-safe-browsing.patch` | Safe Browsing off and no longer claimed: the "Block potentially dangerous and deceptive sites" switch is removed and Safe Browsing is forced off (a stored `true` from an older build is ignored). The build has no Google Safe Browsing API key, so the switch never protected anything. Mozilla's tracking-protection lists stay. Patched 2026-11-06, not yet verified on a build |
| `focus-android/0200-blackdrift-launcher-icon.patch` | Branding: Blackdrift Clean Slate adaptive and themed launcher icon, white background (new `src/focus/res`, plus a `focusDebug` copy) |
| `focus-android/0201-blackdrift-notification-icon.patch` | Branding: Blackdrift status-bar notification icon |
| `focus-android/0202-blackdrift-logo-wordmark-splash.patch` | Branding: Blackdrift lockup (wordmark2, 296dp), stacked lockup (onboarding logo), splash mark and the `blackdrift_*` brand colour tokens (theme-aware) |
| `focus-android/0203-blackdrift-onboarding-and-widget-art.patch` | Branding: vector replacements for the Focus onboarding and search-widget PNGs |
| `focus-android/0204-blackdrift-urls.patch` | Branding: privacy, terms, help and SUMO links → sonicon.org (`SupportUtils.kt`) |
| `focus-android/0205-blackdrift-strings.patch` | Branding: new non-translatable `blackdrift_*` strings (About attribution, onboarding, "Search in Blackdrift") and call sites moved off Firefox/Mozilla strings |
| `focus-android/0206-blackdrift-no-firefox-install-promo.patch` | Branding: no "Download Firefox" row in "Open in…" |
| `focus-android/0207-blackdrift-default-search-startpage.patch` | Startpage as the default search engine in every region (one-time `BlackdriftSearchMigration`) |
| `focus-android/0208-blackdrift-focus-colors.patch` | Branding: 53 light / 51 dark Focus colours (67 before 159.0.1, which deleted 18 unused names; 4 added for the first-run tip bubble and the biometric / Add-widget buttons) in `main/res/values{,-night}/colors.xml` set to Clean Slate values in place, including the onboarding/biometric `home_screen_modal_gradient_*` set flat to ground (generated list: `branding/android/focus-colors`) |
| `focus-android/0209-blackdrift-flat-home-background.patch` | Branding: `home_background` (home screen) flat to `blackdrift_ground` in `src/focus/res/drawable{,-night,-land,-land-night}`, replacing Focus's lavender/purple gradient |
| `focus-android/0210-blackdrift-compose-colors.patch` | Branding (hand-written): the Compose palette's Photon pink/violet in `ui/theme/FocusTheme.kt` (About "Learn more" link, radio buttons, dialog controls, dark onboarding button, light Material surface) set to Drift blue / Clean Slate surface. Not produced by `apply-focus-colors.mjs` |
| `focus-android/0300-version-from-release-workflow.patch` | Play: `-PblackdriftVersionName`/`-PblackdriftVersionCode` (from `BLACKDRIFT_VERSION_*`) become every release/beta/nightly output's versionName/versionCode, replacing upstream's time-based code and ABI/AAB offset; no-op without them |
| `focus-android/0301-aab-abi-filters.patch` | Play: `-PblackdriftAbiFilters` limits a bundle invocation's AAB to the ABIs with GeckoView (arm64-v8a), so Play never serves a split without `libxul.so`; no-op without it and for APK builds |
| `tree/0001-no-gecko-experiment-sync.patch` | Telemetry off: in `services/settings/remote-settings.sys.mjs`, Gecko's Remote Settings no longer pulls the startup bundle (`bundles/startup.json.mozlz4`), so each collection Blackdrift reads syncs on its own, and it refuses to sync Mozilla's experiment and messaging collections (`cfr`, `message-groups`, `newtab-wallpapers-v2`, `nimbus-desktop-experiments`, `nimbus-mobile-experiments`, `nimbus-preview`, `nimbus-secure-experiments`, `normandy-recipes-capabilities`). Ships in `omni.ja`, which the artifact build stages from the local tree. Patched 2026-11-06, not yet verified on a build |

Deleting these files restores the unmodified upstream Focus baseline. A changed
patch set requires `scripts/fetch.sh --force` before re-patching.

## Creating a patch

Use the workspace (root README → Writing patches): it is a sparse checkout of
the pinned revision with every patch here already applied, one commit each.

```bash
rtk bash scripts/workspace.sh init
# edit files under workspace/firefox/mobile/android/focus-android/...
rtk bash scripts/workspace.sh export --number 0105 focus-android my-change header.txt
rtk bash scripts/workspace.sh verify
```

The header file starts with `Blackdrift: <summary>.` and has a `Why:` paragraph;
`export` appends the `Cut against:` line and the diff, relative to the
bucket's target. The patch is applied with `patch -p1` from the target
directory, so paths in the patch are relative to that target (e.g.
`app/build.gradle`, not `mobile/android/focus-android/app/build.gradle`), and
binary files cannot be carried.

## Iteration loop

Edit in the workspace, not in the build tree. `patch.sh` only applies forward
and cannot undo a series.

```bash
rtk bash scripts/workspace.sh status    # where the workspace stands
# edit files under workspace/firefox/..., then export as above
rtk bash scripts/workspace.sh verify    # full series on a pristine copy
```

To change an existing patch under its own number, follow
`branding/README.md` → Updating the app (branch before it, export, cherry-pick
the later commits). To refresh the build tree after the series changes:

```bash
scripts/fetch.sh --force         # fresh upstream snapshot
scripts/patch.sh --dry-run       # sanity-check without writing
scripts/patch.sh                 # apply for real
```

## Notes

- Keep patches small and focused. One concern per file.
- Add a header comment to each `.patch` explaining *why* the change exists,
  not what it does (the diff already shows what).
- When upstream rebases break a patch, `patch` prints the failing hunk; fix
  it by regenerating against the new tree.
