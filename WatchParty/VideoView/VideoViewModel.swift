import CoreGraphics
import Foundation
import Google
import Observation

@Observable
@MainActor
final class VideoViewModel {

    var selectedVideoData: Data?
    var request: String = ""
    var result: Response?
    var isLoading: Bool = false
    var errorMessage: String?
    var timeSpent = 0
    var videoLength = 0
    var resolution = CGSize.zero
    var isSilent = false
    
    private let google = Google()
    
    func processVideo() async {
        guard let selectedVideoData else {
            return
        }
        isLoading = true
        result = nil
        timeSpent = 0
        let timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                timeSpent += 1
            }
        }
        do {
            result = try await google.analyzeVideo(data: selectedVideoData, request: request)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
        timerTask.cancel()
    }
    
    func reset() {
        selectedVideoData = nil
        request = ""
        result = nil
        isLoading = false
        errorMessage = nil
        timeSpent = 0
        resolution = .zero
    }
}
