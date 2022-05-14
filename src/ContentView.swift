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
                Text("Keys that take control of the mouse, like quick pings in League, comma-separated.").fixedSize(horizontal: false, vertical: true)
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
            Text("Activate").font(.title2).padding(.bottom, 3)
            VStack(alignment: .leading) {
                Text("Activate only when one of these programs are in focus or always.").fixedSize(horizontal: false, vertical: true)
                ForEach(self.appState.games.sorted(by: >), id: \.key) { key, value in
                    Toggle(value, isOn: Binding(
                        get: {self.appState.activegames[key] ?? false},
                        set: {value in self.appState.activegames[key] = value}
                    )).disabled(self.appState.active)
                }
                Toggle("Always", isOn: $appState.active)
            }
        }.padding(30).padding(.top, -5).frame(width: 340)
    }
}
