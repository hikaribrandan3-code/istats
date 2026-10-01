# iStats for macOS

iStats is a small native SwiftUI system-monitoring app for macOS, with a dashboard window and a menu-bar shortcut for reopening it. It is a local personal utility, not an Activity Monitor replacement.

## What it includes

- Live CPU, memory, network, and disk measurements
- Rolling 60-sample charts and top CPU/memory process lists
- Configurable refresh interval, launch-at-login setting, and English/Spanish UI
- Local Mach/BSD system APIs; the native app has no network backend or telemetry
- macOS 14 or later; Swift, SwiftUI, AppKit, Swift Charts, and Swift Package Manager

## Build

Open this folder in Terminal and run:

```sh
make app
```

The app bundle is written to `dist/iStats.app`. Run `make dmg` for a disk image. A full Xcode installation is the standard build setup; the local Command Line Tools workaround is opt-in with `USE_TOOLCHAIN_FIX=1` only if already installed. The generated app is ad-hoc signed and not notarized, so macOS may show a first-open prompt. The package includes a brief installation note without asking users to disable macOS protections.

CPU uses per-core tick deltas. Memory is a bounded estimate from VM page counts, not Apple's memory-pressure metric. Network rates come from one displayed interface over actual elapsed time. Disk uses available capacity, and charts hold 60 samples rather than 60 seconds. No fan, temperature, battery sensor, or persistent historical logging is included. The 1.0.1 app is staged for smoke testing before a public download. See [development notes](../DEVELOPMENT_NOTES.md).
