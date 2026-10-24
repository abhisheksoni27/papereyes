import Cocoa
import Carbon

// MARK: - Procedural Paper Texture Generator
func generatePaperNoiseImage(width: Int = 512, height: Int = 512) -> NSImage {
    let colorSpace = CGColorSpaceCreateDeviceGray()
    var rawData = [UInt8](repeating: 0, count: width * height)
    
    // High-frequency subtle paper grain (tactile tooth)
    for i in 0..<(width * height) {
        rawData[i] = UInt8.random(in: 175...255)
    }
    
    let bitmapContext = CGContext(
        data: &rawData,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.none.rawValue
    )!
    
    let cgImage = bitmapContext.makeImage()!
    return NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
}

// MARK: - Native macOS Vector Menu Bar Icon (Folded Paper Document)
func createMenuBarPaperIcon() -> NSImage {
    let size = NSSize(width: 18, height: 18)
    let image = NSImage(size: size, flipped: false) { rect in
        let ctx = NSGraphicsContext.current!.cgContext
        ctx.setStrokeColor(NSColor.black.cgColor)
        ctx.setLineWidth(1.4)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        
        // Document outline coordinates with top-right fold
        let docPath = CGMutablePath()
        docPath.move(to: CGPoint(x: 4, y: 2))
        docPath.addLine(to: CGPoint(x: 14, y: 2))
        docPath.addLine(to: CGPoint(x: 14, y: 11))
        docPath.addLine(to: CGPoint(x: 9.5, y: 16))
        docPath.addLine(to: CGPoint(x: 4, y: 16))
        docPath.closeSubpath()
        
        ctx.addPath(docPath)
        ctx.strokePath()
        
        // Dog-ear corner fold
        let foldPath = CGMutablePath()
        foldPath.move(to: CGPoint(x: 9.5, y: 16))
        foldPath.addLine(to: CGPoint(x: 9.5, y: 11))
        foldPath.addLine(to: CGPoint(x: 14, y: 11))
        
        ctx.addPath(foldPath)
        ctx.strokePath()
        
        // Subtle interior text lines
        ctx.setLineWidth(1.1)
        ctx.move(to: CGPoint(x: 6.5, y: 8))
        ctx.addLine(to: CGPoint(x: 11.5, y: 8))
        ctx.move(to: CGPoint(x: 6.5, y: 5))
        ctx.addLine(to: CGPoint(x: 11.5, y: 5))
        ctx.strokePath()
        
        return true
    }
    
    // Automatically inverts based on macOS Light / Dark menu bar
    image.isTemplate = true
    return image
}

// MARK: - Paper Overlay View
class PaperOverlayView: NSView {
    var opacity: CGFloat = 0.25 {
        didSet { needsDisplay = true }
    }
    
    private let texturePattern: NSColor
    
    override init(frame frameRect: NSRect) {
        let texture = generatePaperNoiseImage(width: 512, height: 512)
        self.texturePattern = NSColor(patternImage: texture)
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.saveGState()
        context.setBlendMode(.multiply)
        context.setAlpha(opacity)
        texturePattern.setFill()
        dirtyRect.fill()
        context.restoreGState()
    }
}

// MARK: - Transparent Pass-Through Overlay Window
class PaperOverlayWindow: NSWindow {
    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        
        // Float at screensaver level to hover over all normal windows & dock
        self.level = NSWindow.Level(Int(CGWindowLevelForKey(.screenSaverWindow)))
        
        // Allow all clicks and gestures to pass through without latency
        self.ignoresMouseEvents = true
        
        // Keep window pinned through Spaces, Mission Control swipes, and full-screen apps
        self.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]
        
        self.hasShadow = false
        
        let overlayView = PaperOverlayView(frame: screen.frame)
        overlayView.autoresizingMask = [.width, .height]
        self.contentView = overlayView
    }
    
    func setOpacity(_ value: CGFloat) {
        if let view = self.contentView as? PaperOverlayView {
            view.opacity = value
        }
    }
}

// MARK: - Global Hotkey Manager (Cmd + Shift + P)
class GlobalHotKey {
    private var hotKeyRef: EventHotKeyRef?
    var onTrigger: (() -> Void)?
    
    init() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        let handler: EventHandlerUPP = { _, event, userData -> OSStatus in
            guard let userData = userData else { return noErr }
            let selfPtr = Unmanaged<GlobalHotKey>.fromOpaque(userData).takeUnretainedValue()
            selfPtr.onTrigger?()
            return noErr
        }
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            handler,
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            nil
        )
        
        // Register Cmd + Shift + P (Keycode 35 is 'P')
        var hotKeyID = EventHotKeyID(signature: OSType(0x50415052), id: 1) // 'PAPR'
        let modifiers = UInt32(cmdKey | shiftKey)
        RegisterEventHotKey(35, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }
    
    deinit {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
        }
    }
}

// MARK: - App Delegate & Menu Controller
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var overlayWindows: [PaperOverlayWindow] = []
    var isEnabled = true
    var currentOpacity: CGFloat = 0.25 // Default: Strong
    var hotKey: GlobalHotKey!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = createMenuBarPaperIcon()
        }
        
        setupWindows()
        buildMenu()
        
        // Global shortcut listener (works from any app without accessibility permissions)
        hotKey = GlobalHotKey()
        hotKey.onTrigger = { [weak self] in
            DispatchQueue.main.async {
                self?.toggleEffect()
            }
        }
    }
    
    func setupWindows() {
        overlayWindows.forEach { $0.close() }
        overlayWindows.removeAll()
        
        for screen in NSScreen.screens {
            let win = PaperOverlayWindow(screen: screen)
            win.setOpacity(currentOpacity)
            win.orderFrontRegardless()
            overlayWindows.append(win)
        }
    }
    
    func buildMenu() {
        let menu = NSMenu()
        
        let toggleTitle = isEnabled ? "Paper Effect: ON  (⌘⇧P)" : "Paper Effect: OFF  (⌘⇧P)"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(toggleEffect), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let opacities: [(String, CGFloat)] = [
            ("Light (10%)", 0.10),
            ("Medium (16%)", 0.16),
            ("Strong (25%)", 0.25),
            ("Heavy Parchment (35%)", 0.35)
        ]
        
        for (label, val) in opacities {
            let item = NSMenuItem(title: label, action: #selector(setPresetOpacity(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = val
            item.state = (val == currentOpacity) ? .on : .off
            menu.addItem(item)
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc func toggleEffect() {
        isEnabled.toggle()
        for win in overlayWindows {
            win.setIsVisible(isEnabled)
        }
        buildMenu()
    }
    
    @objc func setPresetOpacity(_ sender: NSMenuItem) {
        guard let val = sender.representedObject as? CGFloat else { return }
        currentOpacity = val
        for win in overlayWindows {
            win.setOpacity(val)
        }
        buildMenu()
    }
}

// MARK: - Entry Point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory) // Pure menu-bar app (no Dock clutter)
app.run()
