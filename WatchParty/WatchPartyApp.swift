import Google
import SwiftUI

@main
struct WatchPartyApp: App {
    
    @State var expandedAnalysis: String = ""
    @State var expandedResult: String = ""
    @State var expandedTimeSpent: String = ""
    
    var body: some Scene {
        WindowGroup {
            VideoView(expandedAnalysis: $expandedAnalysis, expandedResult: $expandedResult, expandedTimeSpent: $expandedTimeSpent)
                .preferredColorScheme(.dark)
                #if os(macOS)
                    .frame(height: (NSScreen.main?.visibleFrame.height ?? 600) - 52)
                #endif
        }
        
        #if os(macOS)
            Window("Expanded Text Window", id: "expandedTextWindow") {
                ExpandedTextView(analysis: expandedAnalysis, result: expandedResult, timeSpent: expandedTimeSpent)
            }
        #endif
    }
    
    init () {
        Google.configure()
    }
}
