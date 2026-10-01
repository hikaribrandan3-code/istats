# iStats development notes — 30 September 2026

## Project origin and initial development

iStats was built as a small local Mac system monitor, with AI-assisted coding. The existing source already contained a SwiftUI dashboard, charts, metric polling, process lists, localization, and a packaging target. This pass refined metrics and documentation rather than adding a new product.

## Hands-on usage

The creator tested iStats and found it functional and responsive. It was not compelling enough for their personal workflow, which is why it remains intentionally small. No wider usage claim is made.

## Source audit: 30 September 2026

The network panel added counters from multiple interfaces while displaying one interface name, then divided by the configured timer interval instead of the elapsed sample time. Memory “pressure” was a used fraction, not the macOS pressure signal; cache classes could overlap. Disk “free” used `volumeAvailableCapacityForImportantUsage`, which can include purgeable space. The chart label claimed 60 seconds even though the ring holds 60 samples. A packaged README claimed “100% safe” and advised removing quarantine attributes.

## Improvements made

- Sampled one named IPv4 interface and calculated transfer rate using real elapsed time, resetting on interface changes.
- Removed the unused pseudo-pressure value, bounded memory segments to physical RAM, and labeled them as estimates.
- Used available disk capacity and labeled the remainder “used / reserved.” Corrected binary speed/size units and chart sample labels.
- Made standard Xcode builds the default, bumped the bundle to 1.0.1, and replaced overstated installation advice.
- Updated public docs and site copy to state the measurement limits and release status.

## Verification performed

The release app compiled and was ad-hoc signed locally. Source and website were checked for obvious stale claims and secrets. There is no automated metric comparison suite or fresh manual runtime smoke test in this release pass; the creator will test the packaged app before the draft download is published.

## Known limitations and current status

This is a compact, local monitor. Metrics are best-effort samples, not exact parity with Activity Monitor or Finder. Some process details may be unavailable due to macOS permissions. Network monitoring focuses on one interface and omits simultaneous VPN/other traffic. APFS volume presentation may differ from Finder. The staged binary is Apple Silicon and unnotarized; Intel compatibility is unverified.
