import Google
import SwiftUI

@main
struct WatchPartyApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init () {
        Google.configure()
    }
}
