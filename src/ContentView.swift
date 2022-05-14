import SwiftUI

struct ContentView: View {
    @StateObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading) {
            Text("Resolution").font(.title2).padding(.bottom, 3)
            HStack() {
                VStack(alignment: .leading) {
                    Text("Width").padding(.bottom, -4)
                    TextField("Width", text: $appState.width)
                }
                VStack(alignment: .leading) {
                    Text("Height").padding(.bottom, -4)
                    TextField("Height", text: $appState.height)
                }
            }.padding(.bottom)
            Text("Control keys").font(.title2).padding(.bottom, 3)
            VStack(alignment: .leading) {
                Text("Keys that take control of the mouse, like quick pings in League, comma-separated.").padding(.bottom, -4).fixedSize(horizontal: false, vertical: true)
                TextField("z,x,c", text: $appState.controlkeys)
                Text("Needs accessibility permissions. Click here to check.").font(.caption).padding(.top, -5)
                .onTapGesture {
                    // run to reset permissions
                    // tccutil reset Accessibility mxrlkn.mouselock
                    AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary);
                }
                .onHover { inside in
                    if inside {
                        NSCursor.pointingHand.push();
                    } else {
                        NSCursor.pop();
                    }
                }
            }.padding(.bottom)
            Toggle("Pause", isOn: $appState.pause).toggleStyle(.switch)
            Toggle("League Only", isOn: $appState.leagueonly).toggleStyle(.switch)
        }.padding(30).padding(.top, -5).frame(width: 340)
    }
}
