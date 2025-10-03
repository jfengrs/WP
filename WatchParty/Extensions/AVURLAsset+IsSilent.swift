
import AVFoundation

extension AVURLAsset {

    /// Analyzes audio content to determine if video is truly silent.
    /// - Parameters:
    ///   - threshold: The amplitude threshold below which audio is considered silent (default: 0.01)
    ///   - sampleCount: Number of samples to analyze (default: 10, spread across duration)
    /// - Returns: True, if video has no audio or all audio is below threshold
    func isSilent(threshold: Float = 0.01, sampleCount: Int = 10) async -> Bool {
        do {
            let audioTracks = try await loadTracks(withMediaType: .audio)
            guard !audioTracks.isEmpty else {
                return true
            }
            let reader = try AVAssetReader(asset: self)
            guard let audioTrack = audioTracks.first else {
                return true
            }
            let outputSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsNonInterleaved: false
            ]
            let trackOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)
            reader.add(trackOutput)
            guard reader.startReading() else {
                print("Failed to start reading audio")
                return true
            }
            var samplesChecked = 0
            var hasSound = false
            while let sampleBuffer = trackOutput.copyNextSampleBuffer() {
                guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
                    continue
                }
                let length = CMBlockBufferGetDataLength(blockBuffer)
                var data = Data(count: length)
                _ = data.withUnsafeMutableBytes { ptr in
                    CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: ptr.baseAddress!)
                }
                // Convert to Int16 samples
                let samples = data.withUnsafeBytes { ptr in
                    Array(ptr.bindMemory(to: Int16.self))
                }
                // Check if any sample exceeds threshold
                for sample in samples {
                    let normalizedSample = abs(Float(sample) / Float(Int16.max))
                    if normalizedSample > threshold {
                        hasSound = true
                        break
                    }
                }
                if hasSound {
                    break
                }
                samplesChecked += 1
                if samplesChecked >= sampleCount {
                    break
                }
            }
            reader.cancelReading()
            return !hasSound
        } catch {
            print("Error analyzing audio: \(error)")
            return true
        }
    }
}
