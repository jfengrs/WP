// The Swift Programming Language
// https://docs.swift.org/swift-book

import FirebaseAI
import FirebaseCore

public final class Google {
    
    private let model: GenerativeModel
    
    public init() {
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        model = ai.generativeModel(modelName: "gemini-2.5-flash")
    }
    
    public static func configure() {
        guard let path = Bundle.module.path(forResource: "GoogleService-Info", ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: path) else {
            return
        }
        FirebaseApp.configure(options: options)
    }
    
    public func ask(topic: String) async -> String? {
        let prompt = "Write a fact in history about the \(topic)."
        do {
            let response = try await model.generateContent(prompt)
            return response.text
        } catch {
            return error.localizedDescription
        }
    }
}
