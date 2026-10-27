#!/usr/bin/env python3
"""Choose an available iPhone simulator, independent of runner device names."""
import json
import subprocess

devices = json.loads(subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "--json"]))["devices"]
for runtime, items in reversed(list(devices.items())):
    if ".iOS-" in runtime:
        for device in items:
            if device["name"].startswith("iPhone") and device.get("isAvailable", False):
                print("platform=iOS Simulator,id=" + device["udid"])
                raise SystemExit(0)
raise SystemExit("No available iPhone simulator. Install an iOS runtime in Xcode Settings > Components.")
