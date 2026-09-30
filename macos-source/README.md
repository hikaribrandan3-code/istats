# iStats for macOS

iStats is a native SwiftUI system-monitoring app for macOS, with a dashboard window and a menu-bar shortcut for reopening it.

## What it includes

- Live CPU, memory, network, and disk measurements
- Rolling 60-sample charts and top CPU/memory process lists
- Configurable refresh interval, launch-at-login setting, and English/Spanish UI
- Local system APIs; metrics are not sent to a remote service
- macOS 14 or later; Swift, SwiftUI, AppKit, Swift Charts, and Swift Package Manager

## Build

Open this folder in Terminal and run:

```sh
swift build -c release
```

To package a `.app` bundle with the included Makefile, run `make app`. A full Xcode installation is the standard build setup. If SwiftPM fails with the affected Command Line Tools installation used during development, run `Packaging/setup-toolchain-fix.sh` and rerun the build.

The repository contains source and packaging instructions, not a compiled app download. It does not currently include fan, temperature, or battery sensors, or persistent historical logging.
