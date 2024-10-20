import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // FM Tab
            FMHomepage()
                .tabItem {
                    Label("FM", systemImage: "radio")
                }
                .tag(1)
            
            // Digital Tab
            DigitalHomepage()
                .tabItem {
                    Label("Digital", systemImage: "dot.radiowaves.left.and.right")
                }
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide both the FM and Digital show environment objects for preview
        ContentView()
            .environmentObject(CurrentFMShow())
            .environmentObject(CurrentDigitalShow())
    }
}

