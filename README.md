# iStats

iStats is a small, free native macOS dashboard for a quick look at CPU, memory, network, disk, and top processes. I built it as a focused local utility and have used it successfully. It is intentionally simple; it did not become a tool I needed often, so I present it as a compact engineering exercise rather than a full Activity Monitor replacement.

## Features and verified stack

Swift 6.1 / Swift Package Manager, SwiftUI and Swift Charts for the dashboard, AppKit for macOS integration, and Mach/BSD system APIs for polling. The app has English and Spanish labels, a configurable refresh interval, a menu-bar shortcut, rolling 60-sample charts, and top process lists. It has no cloud backend, account, telemetry, or API key. Source and build instructions are in [`macos-source/`](macos-source/README.md).

## Reading the numbers

- CPU is the average busy percentage across cores between samples. A process may show more than 100% when it uses multiple cores.
- Memory segments are **estimates** from VM page counts. “Other / cache” is the remaining physical memory after estimated used and free pages; this is not macOS's memory-pressure metric or an exact Activity Monitor category.
- Network rates use the actual elapsed time and byte counters for one displayed IPv4 interface, preferring `en0`. VPN and other simultaneous interfaces are not added together.
- Disk shows volume capacity and space **available** to the current user. “Used / reserved” includes space not available to that user; APFS snapshots and shared volumes can make it differ from Finder's presentation.
- Charts retain 60 samples, so their time span depends on the selected refresh interval.

## Build, privacy, and status

Requires macOS 14 or later and Xcode 16 with a Swift 6.1 compatible toolchain. Run `make app` or `make dmg` inside `macos-source/`. The bundle is ad-hoc signed and not notarized. It only reads local system metrics, though macOS may restrict some process details. A 1.0.1 Apple Silicon build is staged for the creator's smoke test before public release. See [development notes](DEVELOPMENT_NOTES.md).

AI coding tools assisted the original implementation and this cleanup. I chose the product scope, tested the app in use, reviewed metric definitions, and made the changes recorded here. Licensed under MIT.
