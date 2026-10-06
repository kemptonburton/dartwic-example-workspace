# Example Workspace 2.0.2

- Pinned Example Plugin 2.0.1, whose download contains matching Debug and Release Engine binaries.
- Included both plugin variants in the workspace download; development Debug Engines no longer fail preparation because `engine-debug` is missing.
- Engine and Interface minimum versions remain 2.0.0. The full seven-task example needs a license permitting those tasks; unregistered FREE mode permits three.

## Example Workspace 2.0.1

- Start and stop scripts now manage only the separate flight-computer demo process. Engine configuration, plugin installation, and Engine lifecycle belong to the Interface.
- No script creates an `engine/` folder or writes Engine credentials or workspace configuration.
- Flight process records and logs live outside the repository in local application data. Shutdown verifies executable identity and process start time to avoid stopping a reused PID.
- Updated repository and website guides, including the optional second-Engine exercise.
- Added flight-only script tests for custom/native startup, duplicate prevention, shutdown, and PID reuse.

Requires Engine and Interface 2.0.0 or newer and Example Plugin 2.0.0. Core packages remain a separate release.

## Example Workspace 2.0.0

- Pinned both plugin dependencies to Example Plugin 2.0.0 and requires Engine and Interface 2.0.0 or newer.
- Tracked the authored idle channel snapshot, so adding a clean clone no longer depends on the launcher to create it.
- Moved the rocket Model3D asset to shared `global_data/assets/models/` storage.
- Migrated recording defaults to schema-1 `global_data/settings.json` and added the plugin run-label example.
- Documented the actual `example-workspace/` selection path and the development Interface's repository-root detection.
- Corrected installation-root detection for engines installed in `bin/`; an explicit `-EngineInstallation` remains available.
- Packaged the workspace, matching Windows x64 plugin, and flight simulator without local credentials, recordings, caches, or live channel state.

Layered settings and shared assets require Engine and Interface 2.0.0 or newer.
Core 2.0.0 packages will be published separately. The
mock rocket is a software demonstration, not a hardware acceptance test.
