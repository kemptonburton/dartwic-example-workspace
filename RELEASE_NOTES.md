# Example Workspace 2.0.0-beta.2

- Pinned both plugin dependencies to Example Plugin 2.0.0-beta.2.
- Tracked the authored idle channel snapshot, so adding a clean clone no longer depends on the launcher to create it.
- Moved the rocket Model3D asset to shared `global_data/assets/models/` storage.
- Migrated recording defaults to schema-1 `global_data/settings.json` and added the plugin run-label example.
- Documented the actual `example-workspace/` selection path and the development Interface's repository-root detection.
- Corrected installation-root detection for engines installed in `bin/`; an explicit `-EngineInstallation` remains available.
- Packaged the workspace, matching Windows x64 plugin, and flight simulator without local credentials, recordings, caches, or live channel state.

Layered settings and shared assets require the updated storage-enabled development
Engine/Interface. The original public beta.3 downloads predate those APIs. The
mock rocket is a software demonstration, not a hardware acceptance test.
