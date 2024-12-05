import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Listen Tab?
            HomePageView()
                .tabItem {
                    Label("Listen", systemImage: "music.note")
                }
                .tag(0)
            
            // Schedule Tab
            Schedule()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
                .tag(1)
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




