import SwiftUI

@main
struct mouselockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
        }
    }
}

class AppState: ObservableObject {
    static let shared = AppState();
    
    @Published var width: String = UserDefaults.standard.string(forKey: "width") ?? "1920" {
        didSet { UserDefaults.standard.set(self.width, forKey: "width") }
    };
    @Published var height: String = UserDefaults.standard.string(forKey: "height") ?? "1080" {
        didSet { UserDefaults.standard.set(self.height, forKey: "height") }
    };
}


class AppDelegate: NSObject, NSApplicationDelegate {
    var oldDeltaX: CGFloat = 0;
    var oldDeltaY: CGFloat = 0;

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged], handler: {(event: NSEvent) in
            let deltaX = event.deltaX - self.oldDeltaX;
            let deltaY = event.deltaY - self.oldDeltaY;
            let x = event.locationInWindow.flipped.x;
            let y = event.locationInWindow.flipped.y;

            let window = (NSScreen.main?.frame.size)!;

            let width = CGFloat(Int(AppState.shared.width) ?? Int(window.width));
            let height = CGFloat(Int(AppState.shared.height) ?? Int(window.height));
            
            // add 1 to be sure we're completely inside window
            let widthCut = ((window.width - width) / 2) + 1;
            let heightCut = ((window.height - height) / 2) + 1;
            
            // confine points to width and height
            let xPoint = clamp(x + deltaX, minValue: widthCut, maxValue: window.width - widthCut);
            let yPoint = clamp(y + deltaY, minValue: heightCut, maxValue: window.height - heightCut);

            // save old deltas
            self.oldDeltaX = xPoint - x;
            self.oldDeltaY = yPoint - y;
            
            CGWarpMouseCursorPosition(CGPoint(x: xPoint, y: yPoint));
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
