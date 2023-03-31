import SwiftUI

@main
struct mouselockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appState = AppState.shared

    var body: some Scene {
        Settings {
            ContentView(appState: appState)
        }
    }
}

class AppState: ObservableObject {
    static let shared = AppState();
    
    @Published var games: Dictionary<String, String> = [
        "com.riotgames.LeagueofLegends.GameClient": "1/League of Legends"
    ];
    
    @Published var width: String = UserDefaults.standard.string(forKey: "width") ?? "1920" {
        didSet {UserDefaults.standard.set(self.width, forKey: "width")}
    };
    @Published var height: String = UserDefaults.standard.string(forKey: "height") ?? "1080" {
        didSet {UserDefaults.standard.set(self.height, forKey: "height")}
    };
    @Published var active: Bool = UserDefaults.standard.bool(forKey: "active") {
        didSet {UserDefaults.standard.set(self.active, forKey: "active")}
    };
    @Published var activegames: Dictionary<String, Bool> = UserDefaults.standard.dictionary(forKey: "activegames") as? [String: Bool] ?? [:] {
        didSet {UserDefaults.standard.set(self.activegames, forKey: "activegames")}
    };
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem : StatusItem!
    var lastTime: TimeInterval = 0;
    var lastDeltaX: CGFloat = 0;
    var lastDeltaY: CGFloat = 0;

    func applicationWillFinishLaunching(_ notification: Notification) {
        assert(NSApp.setActivationPolicy(.accessory));
        statusItem = StatusItem.shared
    }

    func applicationDidFinishLaunching(_ notification: Notification) {

        // remove stale games from activegames
        for (key, _) in AppState.shared.activegames {
            if (AppState.shared.games[key] == nil) {
                AppState.shared.activegames.removeValue(forKey: key);
            }
        }

        NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged], handler: {(event: NSEvent) in
            if (self.lastTime != 0) { // ignore old events
                if (event.timestamp <= self.lastTime) {
                    self.lastDeltaX = 0;
                    self.lastDeltaY = 0;
                    return;
                }
            }
            
            // pause if not activated
            if (AppState.shared.active == false && (AppState.shared.activegames[(NSWorkspace().frontmostApplication?.bundleIdentifier ?? "")] ?? false) == false) {
                return;
            }
            
            // mouse lock
            let deltaX = event.deltaX - self.lastDeltaX;
            let deltaY = event.deltaY - self.lastDeltaY;
            let x = event.locationInWindow.flipped.x;
            let y = event.locationInWindow.flipped.y;

            let window = (NSScreen.main?.frame.size)!
            
            let width = CGFloat(Int(AppState.shared.width) ?? Int(window.width));
            let height = CGFloat(Int(AppState.shared.height) ?? Int(window.height));
            
            // add 1 to be sure we're completely inside window
            let widthCut = ((window.width - width) / 2) + 1;
            let heightCut = ((window.height - height) / 2) + 1;
            
            // confine points to width and height
            let xPoint = clamp(x + deltaX, minValue: widthCut, maxValue: window.width - widthCut);
            let yPoint = clamp(y + deltaY, minValue: heightCut, maxValue: window.height - heightCut);
            
            // save old deltas
            self.lastDeltaX = xPoint - x;
            self.lastDeltaY = yPoint - y;
            
            CGWarpMouseCursorPosition(CGPoint(x: xPoint, y: yPoint));
            self.lastTime = ProcessInfo.processInfo.systemUptime;
        });
    }
}


public func clamp<T>(_ value: T, minValue: T, maxValue: T) -> T where T : Comparable {
    return min(max(value, minValue), maxValue)
}

extension NSPoint {
    var flipped: NSPoint {
        let frame = (NSScreen.main?.frame)!
        let y = frame.size.height - self.y
        return NSPoint(x: self.x, y: y)
    }
}

class StatusItem {
    static let shared = StatusItem()

    private lazy var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private var activeStatus = "Enabled"

    private lazy var menu: NSMenu = {
        let menu = NSMenu()

        let bringMainMenu = NSMenuItem(title: String("Settings"), action: #selector(openSettingsMenu), keyEquivalent: "")
        let activationShortcut = NSMenuItem(title: activeStatus, action: #selector(toggleActive), keyEquivalent: "")
        let quitItem = NSMenuItem(title: String(format: NSLocalizedString("Quit %@", comment: ""), "Mouselock"), action: #selector(quit), keyEquivalent: "q")

        menu.items = [
            bringMainMenu,
            //activationShortcut,
            quitItem
        ]

        menu.items.forEach { $0.target = self }

        return menu
    }()

    init() {
        if let button = statusItem.button {
            button.image = NSImage(named: "AppIcon")
            button.image?.size = NSSize(width: 32, height: 32)
            button.target = self
        }

        statusItem.menu = menu
    }

    @objc private func openSettingsMenu() {
        if #available(macOS 13, *) {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }

    @objc private func toggleActive() {
        AppState.shared.active.toggle()
        if(AppState.shared.active) {
            activeStatus = "Enabled"
        } else {
            activeStatus = "Disabled"
        }
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

}
