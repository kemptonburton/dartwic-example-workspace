"""Seed removable dataframe pagination fixtures around the example test-1 run.

Stop the example engine before editing its runtime registry. The script keeps
every non-fixture frame and creates a one-time backup beside the registry.
"""

import argparse
import json
import os
import shutil
from pathlib import Path


PREFIX = "fixture-pagination-"
GROUPS = ("left", "center", "right")
COUNT_PER_GROUP = 100


def fixture_frames(anchor):
    start = int(anchor["from_ns"])
    end = int(anchor["to_ns"])
    if end <= start:
        raise ValueError("test-1 must have a completed time range")
    duration = end - start
    step = duration // COUNT_PER_GROUP
    if step < 2:
        raise ValueError("test-1 range is too short for 300 distinct test frames")
    width = max(1, step // 2)
    for group in GROUPS:
        base = start - duration if group == "left" else start if group == "center" else end + 1
        for index in range(COUNT_PER_GROUP):
            from_ns = base + index * step
            to_ns = min(from_ns + width, start - 1 if group == "left" else end) if group != "right" else from_ns + width
            suffix = f"{index + 1:03d}"
            yield {
                "id": f"{PREFIX}{group}-{suffix}",
                "name": f"PAGINATION TEST {group.upper()} {suffix}",
                "channels": [],
                "events": "all",
                "logs": "all",
                "nodes": [],
                "streams": [],
                "state": "stopped",
                "from_ns": from_ns,
                "to_ns": to_ns,
                "checkpoint_at_ns": to_ns,
                "end_reason": "stopped",
            }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("registry", type=Path, help="Stopped example engine runtime/default/dataframes.json")
    parser.add_argument("--remove", action="store_true", help="Remove only pagination fixtures")
    args = parser.parse_args()
    registry = args.registry.resolve(strict=True)
    document = json.loads(registry.read_text(encoding="utf-8-sig"))
    if document.get("schema_version") != 3 or not isinstance(document.get("frames"), list):
        raise ValueError("Expected a schema-version-3 dataframe registry")
    existing = [frame for frame in document["frames"] if not str(frame.get("id", "")).startswith(PREFIX)]
    if args.remove:
        additions = []
    else:
        matches = [frame for frame in existing if frame.get("name") == "test-1"]
        if len(matches) != 1:
            raise ValueError(f"Expected one test-1 dataframe, found {len(matches)}")
        additions = list(fixture_frames(matches[0]))
    backup = registry.with_name("dataframes.before-pagination.json")
    if not backup.exists():
        shutil.copy2(registry, backup)
    document["frames"] = existing + additions
    document["revision"] = int(document.get("revision", 0)) + 1
    temporary = registry.with_name(registry.name + ".pagination-tmp")
    temporary.write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")
    os.replace(temporary, registry)
    print(f"{registry}: {len(existing)} original frames, {len(additions)} pagination fixtures; backup: {backup}")


if __name__ == "__main__":
    main()
