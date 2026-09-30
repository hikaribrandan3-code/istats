// Renders the iStats app icon — blue rounded square with a white activity
// waveform and a small gauge arc, matching the iSuite icon family.
// Run via: swift Packaging/make-icon.swift <output-dir>
import AppKit

let sizes: [(name: String, points: Int, scale: Int)] = [
    ("icon_16x16", 16, 1), ("icon_16x16@2x", 16, 2),
    ("icon_32x32", 32, 1), ("icon_32x32@2x", 32, 2),
    ("icon_128x128", 128, 1), ("icon_128x128@2x", 128, 2),
    ("icon_256x256", 256, 1), ("icon_256x256@2x", 256, 2),
    ("icon_512x512", 512, 1), ("icon_512x512@2x", 512, 2),
]

let outputDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "iconset"
try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

func drawIcon(pixels: Int) -> NSImage {
    let size = CGFloat(pixels)
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let inset = size * 0.09
    let squircle = NSBezierPath(
        roundedRect: NSRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2),
        xRadius: size * 0.2,
        yRadius: size * 0.2
    )

    // Green gradient background (iSuite green family)
    let gradient = NSGradient(
        starting: NSColor(calibratedRed: 0.15, green: 0.80, blue: 0.45, alpha: 1),
        ending: NSColor(calibratedRed: 0.05, green: 0.55, blue: 0.25, alpha: 1)
    )
    gradient?.draw(in: squircle, angle: -90)

    // Activity waveform across the middle
    let wave = NSBezierPath()
    wave.lineWidth = max(size * 0.045, 1)
    wave.lineCapStyle = .round
    wave.lineJoinStyle = .round
    let midY = size * 0.5
    let amp = size * 0.16
    let points: [(CGFloat, CGFloat)] = [
        (0.18, 0), (0.30, 0), (0.36, -0.55), (0.44, 0.9),
        (0.52, -0.9), (0.60, 0.55), (0.66, 0), (0.82, 0),
    ]
    wave.move(to: NSPoint(x: size * points[0].0, y: midY + amp * points[0].1))
    for p in points.dropFirst() {
        wave.line(to: NSPoint(x: size * p.0, y: midY + amp * p.1))
    }
    NSColor.white.setStroke()
    wave.stroke()

    // Small gauge arc under the waveform
    let arc = NSBezierPath()
    arc.lineWidth = max(size * 0.035, 1)
    arc.lineCapStyle = .round
    arc.appendArc(
        withCenter: NSPoint(x: size * 0.5, y: size * 0.30),
        radius: size * 0.09,
        startAngle: 180,
        endAngle: 20,
        clockwise: true
    )
    NSColor.white.withAlphaComponent(0.85).setStroke()
    arc.stroke()

    image.unlockFocus()
    return image
}

for spec in sizes {
    let pixels = spec.points * spec.scale
    let image = drawIcon(pixels: pixels)
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else { continue }
    let url = URL(fileURLWithPath: outputDir).appendingPathComponent("\(spec.name).png")
    try? png.write(to: url)
}
print("✓ iconset written to \(outputDir)")
