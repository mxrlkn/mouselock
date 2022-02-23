import SwiftUI

struct ContentView: View {
    @StateObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading) {
            Text("Width").padding(.bottom, -3)
            TextField("Width", text: $appState.width)
                .padding(.bottom, 15)
            Text("Height").padding(.bottom, -3)
            TextField("Height", text: $appState.height)
        }.padding(30).padding(.top, -10).frame(width: 300, height: 160)
    }
}
