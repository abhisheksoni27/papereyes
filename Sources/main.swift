import Cocoa
import Carbon

// MARK: - Texture Styles
enum TextureStyle: String, CaseIterable {
    case matte = "Matte Paper"
    case whisperWeave = "Whisper Weave"
    case parchment = "Aged Parchment"
    case kraft = "Raw Kraft"
    case eink = "E-Ink Reader"
    
    var shortcutNumber: String {
        switch self {
        case .matte: return "1"
        case .whisperWeave: return "2"
        case .parchment: return "3"
        case .kraft: return "4"
        case .eink: return "5"
        }
    }
}

// MARK: - Procedural Multi-Texture Generator
func generateTexture(style: TextureStyle, width: Int = 512, height: Int = 512) -> (image: NSImage, tintColor: NSColor?) {
    let colorSpace = CGColorSpaceCreateDeviceGray()
    var rawData = [UInt8](repeating: 0, count: width * height)
    var tintColor: NSColor? = nil
    
    switch style {
    case .matte:
        // Clean, fine-grained tactile tooth
        for i in 0..<(width * height) {
            rawData[i] = UInt8.random(in: 185...255)
        }
        
    case .whisperWeave:
        // Subtle woven fiber cross-hatch structure
        for y in 0..<height {
            for x in 0..<width {
                let weave = ((x % 4 == 0) || (y % 4 == 0)) ? 180 : 235
                let noise = Int.random(in: -20...20)
                let pixel = min(max(weave + noise, 0), 255)
                rawData[y * width + x] = UInt8(pixel)
            }
        }
        
    case .parchment:
        // Warm organic variance with fiber pockets
        tintColor = NSColor(red: 0.96, green: 0.91, blue: 0.82, alpha: 0.12) // Warm parchment wash
        for y in 0..<height {
            for x in 0..<width {
                let base = 210 + Int(sin(Double(x) * 0.05) * 15 + cos(Double(y) * 0.05) * 15)
                let noise = Int.random(in: -25...25)
                let pixel = min(max(base + noise, 0), 255)
                rawData[y * width + x] = UInt8(pixel)
            }
        }
        
    case .kraft:
        // Raw organic paper with darker fiber specks
        tintColor = NSColor(red: 0.88, green: 0.80, blue: 0.68, alpha: 0.14) // Kraft tint
        for i in 0..<(width * height) {
            let isFiber = Int.random(in: 0...100) < 3
            let grain = isFiber ? UInt8.random(in: 110...160) : UInt8.random(in: 180...255)
            rawData[i] = grain
        }
        
    case .eink:
        // High-contrast, sharp micro-pigment e-ink diffuser
        for i in 0..<(width * height) {
            let isBlackBead = Int.random(in: 0...100) < 8
            rawData[i] = isBlackBead ? UInt8.random(in: 130...170) : UInt8.random(in: 215...255)
        }
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
    let img = NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
    return (img, tintColor)
}

// MARK: - Native Retina Menu Bar Vector Icon
func createMenuBarPaperIcon() -> NSImage {
    let size = NSSize(width: 18, height: 18)
    let image = NSImage(size: size, flipped: false) { rect in
        guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
        ctx.setStrokeColor(NSColor.black.cgColor)
        ctx.setLineWidth(1.4)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        
        let docPath = CGMutablePath()
        docPath.move(to: CGPoint(x: 4, y: 2))
        docPath.addLine(to: CGPoint(x: 14, y: 2))
        docPath.addLine(to: CGPoint(x: 14, y: 11))
        docPath.addLine(to: CGPoint(x: 9.5, y: 16))
        docPath.addLine(to: CGPoint(x: 4, y: 16))
        docPath.closeSubpath()
        ctx.addPath(docPath)
        ctx.strokePath()
        
        let foldPath = CGMutablePath()
        foldPath.move(to: CGPoint(x: 9.5, y: 16))
        foldPath.addLine(to: CGPoint(x: 9.5, y: 11))
        foldPath.addLine(to: CGPoint(x: 14, y: 11))
        ctx.addPath(foldPath)
        ctx.strokePath()
        
        ctx.setLineWidth(1.1)
        ctx.move(to: CGPoint(x: 6.5, y: 8))
        ctx.addLine(to: CGPoint(x: 11.5, y: 8))
        ctx.move(to: CGPoint(x: 6.5, y: 5))
        ctx.addLine(to: CGPoint(x: 11.5, y: 5))
        ctx.strokePath()
        
        return true
    }
    image.isTemplate = true
    return image
}

// MARK: - Paper Overlay View with Desk Lamp Vignette
class PaperOverlayView: NSView {
    var opacity: CGFloat = 0.25 {
        didSet { needsDisplay = true }
    }
    
    var deskLampEnabled: Bool = false {
        didSet { needsDisplay = true }
    }
    
    private var texturePattern: NSColor
    private var currentTintColor: NSColor?
    
    init(frame frameRect: NSRect, style: TextureStyle) {
        let gen = generateTexture(style: style)
        self.texturePattern = NSColor(patternImage: gen.image)
        self.currentTintColor = gen.tintColor
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func updateStyle(_ style: TextureStyle) {
        let gen = generateTexture(style: style)
        self.texturePattern = NSColor(patternImage: gen.image)
        self.currentTintColor = gen.tintColor
        needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        context.saveGState()
        
        // 1. Draw Paper Grain Texture
        context.setBlendMode(.multiply)
        context.setAlpha(opacity)
        texturePattern.setFill()
        dirtyRect.fill()
        
        // 2. Draw Warm Material Tint (if style has one)
        if let tint = currentTintColor {
            context.setBlendMode(.colorBurn)
            tint.setFill()
            dirtyRect.fill()
        }
        
        // 3. Desk Lamp Mode: Soft warm radial vignette from top-right
        if deskLampEnabled {
            context.setBlendMode(.softLight)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let warmLampColors = [
                NSColor(red: 1.0, green: 0.88, blue: 0.65, alpha: 0.35).cgColor,
                NSColor(red: 1.0, green: 0.82, blue: 0.55, alpha: 0.08).cgColor,
                NSColor(red: 0.1, green: 0.05, blue: 0.0, alpha: 0.15).cgColor
            ] as CFArray
            let locations: [CGFloat] = [0.0, 0.45, 1.0]
            
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: warmLampColors, locations: locations) {
                let lampCenter = CGPoint(x: bounds.width * 0.85, y: bounds.height * 0.90)
                let startRadius: CGFloat = 20
                let endRadius: CGFloat = max(bounds.width, bounds.height) * 1.05
                context.drawRadialGradient(
                    gradient,
                    startCenter: lampCenter,
                    startRadius: startRadius,
                    endCenter: lampCenter,
                    endRadius: endRadius,
                    options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
                )
            }
        }
        
        context.restoreGState()
    }
}

// MARK: - Transparent Pass-Through Overlay Window
class PaperOverlayWindow: NSWindow {
    init(screen: NSScreen, style: TextureStyle) {
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = NSWindow.Level(Int(CGWindowLevelForKey(.screenSaverWindow)))
        self.ignoresMouseEvents = true
        self.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]
        self.hasShadow = false
        
        let overlayView = PaperOverlayView(frame: screen.frame, style: style)
        overlayView.autoresizingMask = [.width, .height]
        self.contentView = overlayView
    }
    
    func setOpacity(_ value: CGFloat) {
        if let view = self.contentView as? PaperOverlayView {
            view.opacity = value
        }
    }
    
    func setStyle(_ style: TextureStyle) {
        if let view = self.contentView as? PaperOverlayView {
            view.updateStyle(style)
        }
    }
    
    func setDeskLamp(_ enabled: Bool) {
        if let view = self.contentView as? PaperOverlayView {
            view.deskLampEnabled = enabled
        }
    }
}

// MARK: - Global Hotkey Manager (⌘⇧P)
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
        
        var hotKeyID = EventHotKeyID(signature: OSType(0x50415052), id: 1)
        let modifiers = UInt32(cmdKey | shiftKey)
        RegisterEventHotKey(35, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }
    
    deinit {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
        }
    }
}

// MARK: - App Delegate & Orchestrator
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var overlayWindows: [PaperOverlayWindow] = []
    
    var isEnabled = true
    var currentOpacity: CGFloat = 0.25 // Default: Strong
    var currentStyle: TextureStyle = .matte
    var deskLampEnabled: Bool = false
    var autoExclusionEnabled: Bool = true
    
    // Excluded application bundle IDs (graphics/color-critical & media apps)
    let excludedBundleIDs: Set<String> = [
        "com.adobe.Photoshop",
        "com.adobe.Illustrator",
        "com.adobe.LightroomClassicCC",
        "com.adobe.PremierePro",
        "com.figma.Desktop",
        "com.apple.FinalCut",
        "com.apple.QuickTimePlayerX",
        "org.videolan.vlc",
        "com.apple.Photos"
    ]
    
    var hotKey: GlobalHotKey!
    private var isTemporarilyMutedByExclusion = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = createMenuBarPaperIcon()
        }
        
        setupWindows()
        buildMenu()
        setupAppExclusionWatcher()
        
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
            let win = PaperOverlayWindow(screen: screen, style: currentStyle)
            win.setOpacity(currentOpacity)
            win.setDeskLamp(deskLampEnabled)
            win.orderFrontRegardless()
            overlayWindows.append(win)
        }
    }
    
    func buildMenu() {
        let menu = NSMenu()
        
        // 1. Toggle item
        let toggleTitle = isEnabled ? "PaperEyes: Active  (⌘⇧P)" : "PaperEyes: Paused  (⌘⇧P)"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(toggleEffect), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 2. Texture Styles Submenu
        let textureMenu = NSMenu()
        for style in TextureStyle.allCases {
            let item = NSMenuItem(title: style.rawValue, action: #selector(selectTextureStyle(_:)), keyEquivalent: style.shortcutNumber)
            item.target = self
            item.representedObject = style
            item.state = (style == currentStyle) ? .on : .off
            textureMenu.addItem(item)
        }
        let textureSubmenuItem = NSMenuItem(title: "Texture Finish", action: nil, keyEquivalent: "")
        menu.setSubmenu(textureMenu, for: textureSubmenuItem)
        menu.addItem(textureSubmenuItem)
        
        // 3. Desk Lamp Mode Toggle
        let lampItem = NSMenuItem(title: "Desk Lamp Ambience", action: #selector(toggleDeskLamp), keyEquivalent: "l")
        lampItem.target = self
        lampItem.state = deskLampEnabled ? .on : .off
        menu.addItem(lampItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 4. Opacity Presets
        let opacityMenu = NSMenu()
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
            opacityMenu.addItem(item)
        }
        let opacitySubmenuItem = NSMenuItem(title: "Intensity", action: nil, keyEquivalent: "")
        menu.setSubmenu(opacityMenu, for: opacitySubmenuItem)
        menu.addItem(opacitySubmenuItem)
        
        // 5. Auto-Exclusion for Design & Photo Apps
        let exclusionItem = NSMenuItem(
            title: "Pause for Design/Video Apps",
            action: #selector(toggleAutoExclusion),
            keyEquivalent: ""
        )
        exclusionItem.target = self
        exclusionItem.state = autoExclusionEnabled ? .on : .off
        menu.addItem(exclusionItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit PaperEyes", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    // MARK: - App Exclusion Notification Listener
    func setupAppExclusionWatcher() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(frontmostAppDidChange(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
    }
    
    @objc func frontmostAppDidChange(_ notification: Notification) {
        guard autoExclusionEnabled, isEnabled else { return }
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleID = app.bundleIdentifier else { return }
        
        let shouldMute = excludedBundleIDs.contains(bundleID)
        
        if shouldMute && !isTemporarilyMutedByExclusion {
            isTemporarilyMutedByExclusion = true
            for win in overlayWindows { win.setIsVisible(false) }
        } else if !shouldMute && isTemporarilyMutedByExclusion {
            isTemporarilyMutedByExclusion = false
            for win in overlayWindows { win.setIsVisible(true) }
        }
    }
    
    // MARK: - Actions
    @objc func toggleEffect() {
        isEnabled.toggle()
        isTemporarilyMutedByExclusion = false
        for win in overlayWindows {
            win.setIsVisible(isEnabled)
        }
        buildMenu()
    }
    
    @objc func selectTextureStyle(_ sender: NSMenuItem) {
        guard let style = sender.representedObject as? TextureStyle else { return }
        currentStyle = style
        for win in overlayWindows {
            win.setStyle(style)
        }
        buildMenu()
    }
    
    @objc func toggleDeskLamp() {
        deskLampEnabled.toggle()
        for win in overlayWindows {
            win.setDeskLamp(deskLampEnabled)
        }
        buildMenu()
    }
    
    @objc func toggleAutoExclusion() {
        autoExclusionEnabled.toggle()
        if !autoExclusionEnabled && isTemporarilyMutedByExclusion {
            isTemporarilyMutedByExclusion = false
            for win in overlayWindows { win.setIsVisible(isEnabled) }
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
app.setActivationPolicy(.accessory)
app.run()
