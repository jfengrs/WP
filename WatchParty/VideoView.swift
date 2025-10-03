import AVKit
import Google
import SwiftUI

#if canImport(PhotosUI)
    import PhotosUI
#endif

struct VideoView: View {

    #if os(macOS)
        @Environment(\.openWindow) private var openWindow
    #endif
    @Binding private var expandedAnalysis: String
    @Binding private var expandedResult: String
    @Binding private var expandedTimeSpent: String
    #if canImport(PhotosUI)
        @State private var selectedItem: PhotosPickerItem?
    #endif
    @State private var player: AVPlayer?
    @State private var viewModel = VideoViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    videoView
                    VStack() {
                        inputView
                        resultView
                        Spacer()
                            .padding(.top, 16)
                        loadingView
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        reset()
                    }) {
                        Image(systemName: "plus.arrow.trianglehead.clockwise")
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    init(
        expandedAnalysis: Binding<String>,
        expandedResult: Binding<String>,
        expandedTimeSpent: Binding<String>
    ) {
        _expandedAnalysis = expandedAnalysis
        _expandedResult = expandedResult
        _expandedTimeSpent = expandedTimeSpent
    }
}

private extension VideoView {
    
    @ViewBuilder
    var videoView: some View {
        if selectedItem != nil,
           let player = player {
            VideoPlayer(player: player)
                #if os(iOS)
                    .frame(height: 256)
                #else
                    .frame(height: 512)
                #endif
                .onAppear {
                    player.play()
                }
                .onDisappear {
                    player.pause()
                }
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                #if os(iOS)
                    .frame(height: 256)
                #else
                    .frame(height: 512)
                #endif
                .overlay(
                    pickerView(text: "Select a video")
                        .frame(maxHeight: .infinity)
                )
        }
    }
    
    @ViewBuilder
    var inputView: some View {
        if selectedItem != nil {
            VStack() {
                TextField("What do you want to Gemini to do?", text: $viewModel.request,  axis: .vertical)
                    .lineLimit(3...5)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.isLoading)
                buttonView
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    var buttonView: some View {
        if viewModel.selectedVideoData != nil {
            HStack {
                Button {
                    Task {
                        await viewModel.processVideo()
                    }
                } label: {
                    Label("Submit", systemImage: "apple.intelligence")
                        .font(.body)
                }
                .buttonStyle(.borderless)
                .disabled(viewModel.isLoading)
                .frame(maxWidth: .infinity)
                .opacity(viewModel.isLoading ? 0.5 : 1.0)
                
                Text("or")
                    .font(.body)
                    .foregroundStyle(.gray)
                
                Button {
                    Task {
                        viewModel.request = "Generating pull for engagement from selected video."
                        await viewModel.processVideo()
                    }
                } label: {
                    Label("Generate pull", systemImage: "questionmark.bubble")
                        .font(.body)
                }
                .buttonStyle(.borderless)
                .disabled(viewModel.isLoading)
                .frame(maxWidth: .infinity)
                .opacity(viewModel.isLoading ? 0.5 : 1.0)
            }
            .frame(height: 44)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    var resultView: some View {
        if let result = viewModel.result {
            VStack {
                Divider()
                    .padding(.bottom, 16)
                VStack(alignment: .leading, spacing: 16) {
                    #if os(iOS)
                        VStack(alignment: .leading) {
                            Text("Video Length: \(viewModel.videoLength)s")
                                .font(.body)
                                .frame(maxWidth: .infinity)
                            
                            Text("Video Resolution: \(Int(viewModel.resolution.width))x\(Int(viewModel.resolution.height))")
                                .font(.body)
                                .frame(maxWidth: .infinity)
                            
                            Text(verbatim: "Is Silent: \(viewModel.isSilent)")
                                .font(.body)
                                .frame(maxWidth: .infinity)
                        }
                    #else
                        HStack {
                            Text("Video Length: \(viewModel.videoLength)s")
                                .font(.body)
                                .frame(maxWidth: .infinity)
                            
                            Text("Video Resolution: \(Int(viewModel.resolution.width))x\(Int(viewModel.resolution.height))")
                                .font(.body)
                                .frame(maxWidth: .infinity)
                            
                            Text(verbatim: "Is Silent: \(viewModel.isSilent)")
                                .font(.body)
                                .frame(maxWidth: .infinity)
                        }
                    #endif
                    
                    Text("Analysis: \n\(result.analysis)")
                        .font(.body)
                    
                    Text("Result: \n\(result.result)")
                        .font(.body)
                    
                    Text("Time Spent: \(viewModel.timeSpent)s")
                        .font(.body)
                }
                #if os(macOS)
                    if (result.analysis + result.result).count > 100 {
                        Button {
                            expandedAnalysis = result.analysis
                            expandedResult = result.result
                            expandedTimeSpent = "\(viewModel.timeSpent)s"
                            openWindow(id: "expandedTextWindow")
                        } label: {
                            Label("Expend", systemImage: "rectangle.expand.diagonal")
                                .font(.body)
                        }
                        .buttonStyle(.borderless)
                    }
                #endif
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    var loadingView: some View {
        if viewModel.isLoading {
            ProgressView()
                .controlSize(.small)
        } else {
            EmptyView()
        }
    }
}

private extension VideoView {
    
    func pickerView(text: String) -> some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .videos,
            photoLibrary: .shared()
        ) {
            Label(text, systemImage: "video.fill")
                .font(.body)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.borderless)
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let newItem = newItem,
                    let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        viewModel.selectedVideoData = data
                        setupPlayer(with: data)
                    }
                    if let tempFileURL = writeTempFile(data: data) {
                        let asset = AVURLAsset(url: tempFileURL)
                        if let resolution = await asset.resolution {
                            viewModel.resolution = resolution
                        }
                        viewModel.isSilent = await asset.isSilent()
                        do {
                            let duration = try await asset.load(.duration)
                            viewModel.videoLength = Int(CMTimeGetSeconds(duration))
                            
                        } catch {
                            print("Failed to get video duration: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    func setupPlayer(with data: Data) {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("video\(Date().timeIntervalSince1970)")
            .appendingPathExtension("mov")
        do {
            try data.write(to: tempURL)
            player = AVPlayer(url: tempURL)
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }
    
    func reset() {
        viewModel.reset()
        selectedItem = nil
        player = nil
    }
    
    func writeTempFile(data: Data) -> URL? {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Failed to write temp file:", error)
            return nil
        }
    }
}
