import AppKit
import Foundation

let output = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "ProjectDock-1024.png"
let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)

image.lockFocus()
defer { image.unlockFocus() }

guard let context = NSGraphicsContext.current else {
    fatalError("Could not create drawing context")
}
context.imageInterpolation = .high

let backgroundRect = NSRect(x: 74, y: 74, width: 876, height: 876)
let background = NSBezierPath(roundedRect: backgroundRect, xRadius: 220, yRadius: 220)
let gradient = NSGradient(colors: [
    NSColor(calibratedRed: 0.40, green: 0.32, blue: 0.85, alpha: 1),
    NSColor(calibratedRed: 0.16, green: 0.13, blue: 0.22, alpha: 1),
    NSColor(calibratedRed: 0.07, green: 0.07, blue: 0.09, alpha: 1)
])!
gradient.draw(in: background, angle: -90)

NSColor.white.withAlphaComponent(0.18).setStroke()
background.lineWidth = 7
background.stroke()

let terminalRect = NSRect(x: 254, y: 344, width: 516, height: 444)
let terminal = NSBezierPath(roundedRect: terminalRect, xRadius: 118, yRadius: 118)
NSColor(calibratedRed: 0.11, green: 0.10, blue: 0.14, alpha: 0.96).setFill()
terminal.fill()
NSColor.white.withAlphaComponent(0.18).setStroke()
terminal.lineWidth = 5
terminal.stroke()

func strokeLine(_ points: [NSPoint], width: CGFloat, color: NSColor) {
    let path = NSBezierPath()
    path.lineWidth = width
    path.lineCapStyle = .round
    path.lineJoinStyle = .round
    path.move(to: points[0])
    for point in points.dropFirst() { path.line(to: point) }
    color.setStroke()
    path.stroke()
}

let white = NSColor(calibratedWhite: 0.96, alpha: 1)
let soft = NSColor(calibratedRed: 0.87, green: 0.84, blue: 0.95, alpha: 1)
strokeLine([NSPoint(x: 438, y: 669), NSPoint(x: 350, y: 566), NSPoint(x: 438, y: 463)], width: 34, color: white)
strokeLine([NSPoint(x: 544, y: 682), NSPoint(x: 469, y: 449)], width: 30, color: soft)
strokeLine([NSPoint(x: 583, y: 669), NSPoint(x: 671, y: 566), NSPoint(x: 583, y: 463)], width: 34, color: white)

let dockRect = NSRect(x: 286, y: 248, width: 452, height: 98)
let dock = NSBezierPath(roundedRect: dockRect, xRadius: 47, yRadius: 47)
NSColor(calibratedRed: 0.20, green: 0.18, blue: 0.26, alpha: 0.98).setFill()
dock.fill()
NSColor.white.withAlphaComponent(0.18).setStroke()
dock.lineWidth = 4
dock.stroke()

for (index, x) in [350.0, 462.0, 574.0].enumerated() {
    let tile = NSBezierPath(roundedRect: NSRect(x: x, y: 270, width: 74, height: 50), xRadius: 18, yRadius: 18)
    let color = index == 1
        ? NSColor(calibratedRed: 0.66, green: 0.52, blue: 1.0, alpha: 1)
        : NSColor(calibratedWhite: 0.92, alpha: 0.95)
    color.setFill()
    tile.fill()
}

guard let tiff = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Could not encode icon")
}

try png.write(to: URL(fileURLWithPath: output))
print("Wrote \(output)")
