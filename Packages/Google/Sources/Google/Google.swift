import FirebaseAI
import FirebaseCore

public final class Google {
    
    private let model: GenerativeModel
    
    public init() {
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        model = ai.generativeModel(modelName: "gemini-2.5-pro")
    }
    
    public static func configure() {
        guard let path = Bundle.module.path(forResource: "GoogleService-Info", ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: path) else {
            return
        }
        FirebaseApp.configure(options: options)
    }
    
    public func analyzeVideo(data: Data, request: String) async throws -> Response? {
        let video = InlineDataPart(data: data, mimeType: "video/mp4")
        let prompt = "Analyze this video, and " + request + ". Format the response as a single, valid JSON string, with key \'analysis\' and \'result\', and the value of both being strings, and the string does not contain text \'json\' or \'\n\'."
        let response = try await model.generateContent(video, prompt)
        if let jsonString = (response.candidates.first?.content.parts.first as? TextPart)?.text
            .replacingOccurrences(of: "```json\n", with: "")
            .replacingOccurrences(of: "\n```", with: ""),
           let jsonData = jsonString.data(using: .utf8) {
            let decoded = try JSONDecoder().decode(Response.self, from: jsonData)
            return decoded
        } else {
            return nil
        }
    }
}
