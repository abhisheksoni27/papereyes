import Cocoa
import Carbon

// MARK: - Texture Styles (Full Paperman Lineup)
enum TextureStyle: String, CaseIterable {
    case matte = "Classic Matte"
    case whisperWeave = "Whisper Weave"
    case parchment = "Sunbaked Parchment"
    case kraft = "Raw Kraft"
    case monasticFelt = "Monastic Felt"
    case eink = "E-Ink Reader"
    
    var shortcutNumber: String {
        switch self {
        case .matte: return "1"
        case .whisperWeave: return "2"
        case .parchment: return "3"
        case .kraft: return "4"
        case .monasticFelt: return "5"
        case .eink: return "6"
        }
    }
}

// MARK: - Desk Lamp Presets
enum DeskLampPosition: String, CaseIterable {
    case topRight = "Top Right (Right-Handed)"
    case topLeft = "Top Left (Left-Handed)"
    case centered = "Overhead Glow"
    case readingStrip = "Reading Focus Strip"
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
        tintColor = NSColor(red: 0.96, green: 0.91, blue: 0.82, alpha: 0.12)
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
        tintColor = NSColor(red: 0.88, green: 0.80, blue: 0.68, alpha: 0.14)
        for i in 0..<(width * height) {
            let isFiber = Int.random(in: 0...100) < 3
            let grain = isFiber ? UInt8.random(in: 110...160) : UInt8.random(in: 180...255)
            rawData[i] = grain
        }
        
    case .monasticFelt:
        // Soft pressed-wool felt with smooth microfiber density
        tintColor = NSColor(red: 0.92, green: 0.90, blue: 0.86, alpha: 0.08)
        for y in 0..<height {
            for x in 0..<width {
                let wave = Int(sin(Double(x + y) * 0.12) * 8)
                let noise = Int.random(in: -12...12)
                let pixel = min(max(225 + wave + noise, 0), 255)
                rawData[y * width + x] = UInt8(pixel)
            }
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

// MARK: - Paper Overlay View with Desk Lamp & Idle Art Mode
class PaperOverlayView: NSView {
    var opacity: CGFloat = 0.25 { didSet { needsDisplay = true } }
    var deskLampEnabled: Bool = false { didSet { needsDisplay = true } }
    var deskLampPosition: DeskLampPosition = .topRight { didSet { needsDisplay = true } }
    var isArtModeActive: Bool = false { didSet { needsDisplay = true } }
    
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
        
        // --- 1. IDLE ART MODE (Gallery Mat & Frame Overlay) ---
        if isArtModeActive {
            // Dark museum backdrop
            NSColor(red: 0.07, green: 0.07, blue: 0.08, alpha: 0.96).setFill()
            dirtyRect.fill()
            
            // Framed Mat (Simulating framed gallery art pass)
            let matMargin: CGFloat = min(bounds.width, bounds.height) * 0.12
            let matRect = bounds.insetBy(dx: matMargin, dy: matMargin)
            
            // Outer frame shadow
            context.setShadow(offset: CGSize(width: 0, height: -10), blur: 30, color: NSColor.black.cgColor)
            NSColor(red: 0.15, green: 0.12, blue: 0.10, alpha: 1.0).setFill() // Hardwood frame
            matRect.insetBy(dx: -12, dy: -12).fill()
            
            context.setShadow(offset: .zero, blur: 0, color: nil)
            
            // Archival white mat board
            NSColor(red: 0.95, green: 0.94, blue: 0.91, alpha: 1.0).setFill()
            matRect.fill()
            
            // Art Canvas
            let artRect = matRect.insetBy(dx: 45, dy: 45)
            NSColor(red: 0.90, green: 0.88, blue: 0.84, alpha: 1.0).setFill()
            artRect.fill()
            
            // Subtle Gallery Plaque typography
            let pStyle = NSMutableParagraphStyle()
            pStyle.alignment = .center
            let plaqueAttrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 13, weight: .light),
                .foregroundColor: NSColor(white: 0.35, alpha: 1.0),
                .paragraphStyle: pStyle
            ]
            let plaqueString = "Paperman Art Gallery — Idle Mode (Move cursor to resume)"
            let plaqueRect = NSRect(x: matRect.minX, y: matRect.minY + 12, width: matRect.width, height: 20)
            plaqueString.draw(in: plaqueRect, withAttributes: plaqueAttrs)
            
            // Overlay paper grain onto the framed art
            context.setBlendMode(.multiply)
            context.setAlpha(0.35)
            texturePattern.setFill()
            artRect.fill()
            
            context.restoreGState()
            return
        }
        
        // --- 2. REGULAR MODE: Tactile Grain Overlay ---
        context.setBlendMode(.multiply)
        context.setAlpha(opacity)
        texturePattern.setFill()
        dirtyRect.fill()
        
        // --- 3. Warm Material Color Wash ---
        if let tint = currentTintColor {
            context.setBlendMode(.colorBurn)
            tint.setFill()
            dirtyRect.fill()
        }
        
        // --- 4. DESK LAMP AMBIENCE MODES ---
        if deskLampEnabled {
            context.setBlendMode(.softLight)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let warmLampColors = [
                NSColor(red: 1.0, green: 0.88, blue: 0.65, alpha: 0.38).cgColor,
                NSColor(red: 1.0, green: 0.82, blue: 0.55, alpha: 0.10).cgColor,
                NSColor(red: 0.08, green: 0.04, blue: 0.0, alpha: 0.18).cgColor
            ] as CFArray
            let locations: [CGFloat] = [0.0, 0.45, 1.0]
            
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: warmLampColors, locations: locations) {
                let lampCenter: CGPoint
                switch deskLampPosition {
                case .topRight:
                    lampCenter = CGPoint(x: bounds.width * 0.88, y: bounds.height * 0.92)
                case .topLeft:
                    lampCenter = CGPoint(x: bounds.width * 0.12, y: bounds.height * 0.92)
                case .centered:
                    lampCenter = CGPoint(x: bounds.width * 0.50, y: bounds.height * 0.98)
                case .readingStrip:
                    lampCenter = CGPoint(x: bounds.width * 0.50, y: bounds.height * 0.50)
                }
                
                let startRadius: CGFloat = (deskLampPosition == .readingStrip) ? 80 : 25
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
        (contentView as? PaperOverlayView)?.opacity = value
    }
    
    func setStyle(_ style: TextureStyle) {
        (contentView as? PaperOverlayView)?.updateStyle(style)
    }
    
    func setDeskLamp(_ enabled: Bool, position: DeskLampPosition) {
        guard let view = contentView as? PaperOverlayView else { return }
        view.deskLampEnabled = enabled
        view.deskLampPosition = position
    }
    
    func setArtMode(_ active: Bool) {
        guard let view = contentView as? PaperOverlayView else { return }
        view.isArtModeActive = active
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
    
    // Desk Lamp Settings
    var deskLampEnabled: Bool = false
    var deskLampPosition: DeskLampPosition = .topRight
    
    // Circadian Auto Shift
    var circadianShiftEnabled: Bool = true
    var circadianTimer: Timer?
    
    // Idle Art Mode
    var artModeEnabled: Bool = false
    var isCurrentlyInArtMode: Bool = false
    var idleCheckTimer: Timer?
    var lastUserActivityTime: Date = Date()
    var lastMousePosition: NSPoint = NSEvent.mouseLocation
    
    // App Exclusion
    var autoExclusionEnabled: Bool = true
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
    private var isTemporarilyMutedByExclusion = false
    
    var hotKey: GlobalHotKey!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = createMenuBarPaperIcon()
        }
        
        setupWindows()
        buildMenu()
        setupAppExclusionWatcher()
        setupCircadianEngine()
        setupIdleArtWatcher()
        
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
            win.setDeskLamp(deskLampEnabled, position: deskLampPosition)
            win.orderFrontRegardless()
            overlayWindows.append(win)
        }
    }
    
    func buildMenu() {
        let menu = NSMenu()
        
        // 1. Toggle status
        let toggleTitle = isEnabled ? "PaperEyes: Active  (⌘⇧P)" : "PaperEyes: Paused  (⌘⇧P)"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(toggleEffect), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 2. Texture Finishes Submenu
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
        
        // 3. Desk Lamp Ambience Submenu
        let lampMenu = NSMenu()
        let lampToggle = NSMenuItem(title: deskLampEnabled ? "Lamp: Enabled" : "Lamp: Disabled", action: #selector(toggleDeskLamp), keyEquivalent: "l")
        lampToggle.target = self
        lampToggle.state = deskLampEnabled ? .on : .off
        lampMenu.addItem(lampToggle)
        lampMenu.addItem(NSMenuItem.separator())
        for pos in DeskLampPosition.allCases {
            let posItem = NSMenuItem(title: pos.rawValue, action: #selector(selectLampPosition(_:)), keyEquivalent: "")
            posItem.target = self
            posItem.representedObject = pos
            posItem.state = (pos == deskLampPosition) ? .on : .off
            lampMenu.addItem(posItem)
        }
        let lampSubmenuItem = NSMenuItem(title: "Desk Lamp Mode", action: nil, keyEquivalent: "")
        menu.setSubmenu(lampMenu, for: lampSubmenuItem)
        menu.addItem(lampSubmenuItem)
        
        // 4. Idle Art Mode Toggle
        let artItem = NSMenuItem(title: "Idle Art Mode (Gallery Frame)", action: #selector(toggleArtMode), keyEquivalent: "")
        artItem.target = self
        artItem.state = artModeEnabled ? .on : .off
        menu.addItem(artItem)
        
        // 5. Circadian Day/Night Transition
        let circadianItem = NSMenuItem(title: "Circadian Shift (Day/Night)", action: #selector(toggleCircadian), keyEquivalent: "")
        circadianItem.target = self
        circadianItem.state = circadianShiftEnabled ? .on : .off
        menu.addItem(circadianItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 6. Intensity / Opacity Submenu
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
        
        // 7. Auto App Exclusion Toggle
        let exclusionItem = NSMenuItem(title: "Auto-Pause in Design/Video Apps", action: #selector(toggleAutoExclusion), keyEquivalent: "")
        exclusionItem.target = self
        exclusionItem.state = autoExclusionEnabled ? .on : .off
        menu.addItem(exclusionItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit PaperEyes", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    // MARK: - Circadian Day / Night Engine
    func setupCircadianEngine() {
        circadianTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.evaluateCircadianProfile()
        }
        evaluateCircadianProfile()
    }
    
    func evaluateCircadianProfile() {
        guard circadianShiftEnabled else { return }
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Evening / Night (8 PM to 6 AM): Switch to warm parchment & enable desk lamp
        if hour >= 20 || hour < 6 {
            if currentStyle == .matte {
                currentStyle = .parchment
                deskLampEnabled = true
                for win in overlayWindows {
                    win.setStyle(.parchment)
                    win.setDeskLamp(true, position: deskLampPosition)
                }
                buildMenu()
            }
        }
    }
    
    // MARK: - Idle Art Mode Watcher
    func setupIdleArtWatcher() {
        idleCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self, self.artModeEnabled else { return }
            let currentMouse = NSEvent.mouseLocation
            if currentMouse != self.lastMousePosition {
                self.lastUserActivityTime = Date()
                self.lastMousePosition = currentMouse
                if self.isCurrentlyInArtMode {
                    self.isCurrentlyInArtMode = false
                    for win in self.overlayWindows { win.setArtMode(false) }
                }
            } else {
                // If idle for more than 3 minutes, enter Art Mode
                if Date().timeIntervalSince(self.lastUserActivityTime) > 180 && !self.isCurrentlyInArtMode {
                    self.isCurrentlyInArtMode = true
                    for win in self.overlayWindows { win.setArtMode(true) }
                }
            }
        }
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
        for win in overlayWindows { win.setIsVisible(isEnabled) }
        buildMenu()
    }
    
    @objc func selectTextureStyle(_ sender: NSMenuItem) {
        guard let style = sender.representedObject as? TextureStyle else { return }
        currentStyle = style
        for win in overlayWindows { win.setStyle(style) }
        buildMenu()
    }
    
    @objc func toggleDeskLamp() {
        deskLampEnabled.toggle()
        for win in overlayWindows { win.setDeskLamp(deskLampEnabled, position: deskLampPosition) }
        buildMenu()
    }
    
    @objc func selectLampPosition(_ sender: NSMenuItem) {
        guard let pos = sender.representedObject as? DeskLampPosition else { return }
        deskLampPosition = pos
        deskLampEnabled = true
        for win in overlayWindows { win.setDeskLamp(true, position: pos) }
        buildMenu()
    }
    
    @objc func toggleArtMode() {
        artModeEnabled.toggle()
        if !artModeEnabled && isCurrentlyInArtMode {
            isCurrentlyInArtMode = false
            for win in overlayWindows { win.setArtMode(false) }
        }
        buildMenu()
    }
    
    @objc func toggleCircadian() {
        circadianShiftEnabled.toggle()
        if circadianShiftEnabled { evaluateCircadianProfile() }
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
        for win in overlayWindows { win.setOpacity(val) }
        buildMenu()
    }
}

// MARK: - Entry Point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
