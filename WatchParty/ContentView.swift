import Google
import SwiftUI

struct ContentView: View {
    
    @State private var topic: String = ""
    @State private var result: String? = ""
    
    private let google = Google()
    
    var body: some View {
        VStack {
            TextField("Input topic", text: $topic)
            Button("Submit") {
                Task {
                    result = await google.ask(topic: topic)
                }
            }
            if let result, !result.isEmpty {
                Text("Gemini says: \(result)")
            }
        }
        .padding()
    }
}
