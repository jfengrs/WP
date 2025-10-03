import SwiftUI

struct ExpandedTextView: View {
    
    private let analysis: String
    private let result: String
    private let timeSpent: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Analysis: \n\(analysis)")
                    .font(.title3)
                    .padding()
                
                Text("Result: \n\(result)")
                    .font(.title3)
                    .padding()
                
                Text("Time Spent: \(timeSpent)")
                    .font(.title3)
                    .padding()
            }
        }
    }
    
    init(analysis: String, result: String, timeSpent: String) {
        self.analysis = analysis
        self.result = result
        self.timeSpent = timeSpent
    }
}
