import AVFoundation
import CoreGraphics

extension AVURLAsset {
    
    var resolution: CGSize? {
        get async {
            do {
                let tracks = try await loadTracks(withMediaType: .video)
                guard let videoTrack = tracks.first else {
                    return nil
                }
                let naturalSize = try await videoTrack.load(.naturalSize)
                let preferredTransform = try await videoTrack.load(.preferredTransform)
                let size = naturalSize.applying(preferredTransform)
                return CGSize(width: abs(size.width), height: abs(size.height))
            } catch {
                print("Error loading video resolution: \(error)")
                return nil
            }
        }
    }
}
