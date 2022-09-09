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
            Text("Activate").font(.title2).padding(.bottom, 3)
            VStack(alignment: .leading) {
                Text("Activate only when one of these apps are in focus or always.").fixedSize(horizontal: false, vertical: true)
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
