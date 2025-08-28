//  SoundsTab.swift
//  EduCalm
//
//  Created by Dylan Karunanayake on 25/8/2025.
//  yay it works
/// the code is very bad i need to make it better but i dont know how 2 use apple's audio engine
//


import SwiftUI
import ColorfulX
@preconcurrency import AVFoundation
import Combine
import Foundation

// AmbientSound remains an ObservableObject so the UI still updates reactively.
final class AmbientSound: ObservableObject, Identifiable {
    let id = UUID()
    let name: String
    let fileURL: URL
    @Published var volume: Float
    // playerNode, audioFile are created lazily when needed:
    var playerNode: AVAudioPlayerNode?
    var audioFile: AVAudioFile?
    // UI state:
    @Published var isPlaying: Bool = false

    // internal flag to track whether we are currently scheduling/looping
    fileprivate var shouldLoop: Bool = false

    init(name: String, fileURL: URL, volume: Float = 0.7) {
        self.name = name
        self.fileURL = fileURL
        self.volume = volume
    }
}

class AmbientSoundManager: ObservableObject {
    let engine = AVAudioEngine()
    @Published var sounds: [AmbientSound] = []
    @Published var masterVolume: Float = 1.0 {
        didSet {
            engine.mainMixerNode.outputVolume = masterVolume
        }
    }

    // Fade timers remain keyed by sound.id
    private var fadeTimers: [UUID: Timer] = [:]

    // Serial queue for all file I/O and preparation work to avoid blocking the main thread
    private let loadQueue = DispatchQueue(label: "com.educalm.soundLoadQueue", qos: .userInitiated)

    init() {
        #if os(iOS) || os(tvOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️ Could not set up audio session: \(error)")
        }
        #endif

        // Discover files in the bundle (fast metadata ops only)
        let fileList: [(String, String)] = [
            ("Rain", "rain.mp3"),
            ("Birds", "birds.mp3"),
            ("Fan", "fan.mp3"),
            ("PowerRangers", "ggpr.mp3"),
            ("Minecraft", "subwoofer.mp3"),
            ("Thunder", "thunder.mp3")
        ]

        loadAvailableSounds(from: fileList)

        // Prepare and start the engine; this is relatively quick compared to file I/O
        engine.prepare()
        do {
            try engine.start()
            engine.mainMixerNode.outputVolume = masterVolume
        } catch {
            print("⚠️ Audio engine failed to start: \(error)")
        }
    }

    // Only create lightweight AmbientSound instances here. No file reads, no buffer allocations.
    private func loadAvailableSounds(from list: [(String, String)]) {
        for (name, fileName) in list {
            if let url = Bundle.main.url(forResource: fileName, withExtension: nil) {
                let sound = AmbientSound(name: name, fileURL: url, volume: 0.7)
                sounds.append(sound)
            } else {
                print("⚠️ File \(fileName) not found in bundle")
            }
        }
    }

    // Prepare player node and audio file on demand on the background queue, then call completion on main queue.
    private func prepareIfNeeded(_ sound: AmbientSound, completion: @escaping (Bool) -> Void) {
        // If already prepared and node exists, return immediately
        if sound.playerNode != nil && sound.audioFile != nil {
            DispatchQueue.main.async { completion(true) }
            return
        }

        loadQueue.async { [weak self, weak sound] in
            guard let self = self, let sound = sound else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            do {
                let file = try AVAudioFile(forReading: sound.fileURL)
                // Create player node on main thread while keeping file reading off main thread
                DispatchQueue.main.async {
                    // Double-check we didn't already prepare while switching threads
                    if sound.playerNode == nil {
                        let node = AVAudioPlayerNode()
                        sound.playerNode = node
                        self.engine.attach(node)
                        // Connect with the file's processing format so pitch/speed are preserved
                        self.engine.connect(node, to: self.engine.mainMixerNode, format: file.processingFormat)
                    }

                    sound.audioFile = file
                    completion(true)
                }
            } catch {
                print("⚠️ Failed to open audio file at \(sound.fileURL): \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    // Looped playback using scheduleFile + repeating scheduling in completion handler.
    // This avoids allocating a full PCM buffer in memory at init.
    func play(_ sound: AmbientSound) {
        // Stop any fade that might be running for this sound
        stopFade(for: sound)

        // Prepare (lazy-load) then schedule and play
        prepareIfNeeded(sound) { [weak self, weak sound] ok in
            guard let self = self, let sound = sound, ok else { return }

            guard let node = sound.playerNode, let file = sound.audioFile else { return }

            // If node is already playing don't re-schedule duplicate playback
            if node.isPlaying {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        sound.isPlaying = true
                    }
                }
                return
            }

            // Set the node volume from sound.volume before starting
            node.volume = sound.volume
            sound.shouldLoop = true

            // Schedule the file once, then in completion schedule again if shouldLoop is still true.
            func scheduleLoop() {
                node.scheduleFile(file, at: nil) { [weak self, weak sound] in
                    guard let sound = sound else { return }
                    // If user requested stop we won't re-schedule
                    if sound.shouldLoop {
                        scheduleLoop()
                    }
                }
            }

            scheduleLoop()
            node.play()

            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.25)) {
                    sound.isPlaying = true
                }
            }
        }
    }

    func stop(_ sound: AmbientSound, fadeDuration: TimeInterval = 1.5) {
        guard let node = sound.playerNode else {
            // Not prepared/playing; just update UI state
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.25)) {
                    sound.isPlaying = false
                }
            }
            return
        }

        guard node.isPlaying else {
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.25)) {
                    sound.isPlaying = false
                }
            }
            return
        }

        // Mark that we no longer want to loop so scheduling completion won't re-schedule
        sound.shouldLoop = false

        startFadeOut(for: sound, duration: fadeDuration)
    }

    private func startFadeOut(for sound: AmbientSound, duration: TimeInterval) {
        stopFade(for: sound)

        guard let node = sound.playerNode else {
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.25)) {
                    sound.isPlaying = false
                }
            }
            return
        }

        let startVolume = node.volume
        let steps = max(1, Int(duration * 60.0))
        var currentStep = 0

        let timer = Timer(timeInterval: duration / Double(steps), repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            currentStep += 1
            let progress = Float(currentStep) / Float(steps)
            node.volume = max(0.0, startVolume * (1.0 - progress))

            if currentStep >= steps {
                t.invalidate()
                node.stop()
                node.volume = sound.volume

                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        sound.isPlaying = false
                    }
                    self.fadeTimers[sound.id] = nil
                }
            }
        }

        RunLoop.main.add(timer, forMode: .common)
        DispatchQueue.main.async {
            self.fadeTimers[sound.id] = timer
        }
    }

    private func stopFade(for sound: AmbientSound) {
        DispatchQueue.main.async {
            if let timer = self.fadeTimers[sound.id] {
                timer.invalidate()
                self.fadeTimers[sound.id] = nil
                sound.playerNode?.volume = sound.volume
            }
        }
    }

    func updateVolume(_ sound: AmbientSound, volume: Float) {
        DispatchQueue.main.async {
            sound.volume = volume
            if let node = sound.playerNode, node.isPlaying {
                node.volume = volume
            }
        }
    }

    func stopAll(fadeDuration: TimeInterval = 1.5) {
        for s in sounds where s.playerNode?.isPlaying == true {
            stop(s, fadeDuration: fadeDuration)
        }
    }
}

struct SoundsTab: View {
    @StateObject private var manager = AmbientSoundManager()
    @State var colorfulPreset = ColorfulPreset.appleIntelligence
    @State private var activeSound: UUID? = nil

    // tile sizing used for layout math
    private let tileWidth: CGFloat = 160
    private let tileHeight: CGFloat = 140
    private let horizontalPadding: CGFloat = 24
    private let spacing: CGFloat = 20

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Background
                ColorfulView(color: $colorfulPreset)
                    .ignoresSafeArea()
                    .opacity(0.4)
                    .zIndex(0)

                // Centered grid:
                let availableWidth = max(0, proxy.size.width - horizontalPadding * 2)
                let columnsThatFit = max(1, Int((availableWidth + spacing) / (tileWidth + spacing)))
                let totalGridWidth = CGFloat(columnsThatFit) * tileWidth + CGFloat(columnsThatFit - 1) * spacing

                ScrollView {
                    VStack {
                        Spacer(minLength: 0)

                        HStack {
                            Spacer(minLength: 0)

                            LazyVGrid(columns: Array(repeating: GridItem(.fixed(tileWidth), spacing: spacing, alignment: .center), count: columnsThatFit),
                                      alignment: .center,
                                      spacing: spacing) {
                                ForEach(manager.sounds) { sound in
                                    SoundItemViewFixed(sound: sound, manager: manager, activeSound: $activeSound, tileHeight: tileHeight, sliderHeight: 34)
                                        .frame(width: tileWidth, height: tileHeight)
                                }
                            }
                            .frame(width: min(totalGridWidth, proxy.size.width - 16))

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, horizontalPadding)

                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: proxy.size.height)
                }
                .zIndex(0)

                VStack {
                    Spacer()
                    HStack {
                        Spacer(minLength: 0)

                        MasterVolumeView(masterVolume: $manager.masterVolume)
                            .padding(.bottom, max(proxy.safeAreaInsets.bottom, 8) + 56)
                            .zIndex(2)

                        Spacer(minLength: 0)
                    }
                }
            }
            .navigationTitle("Relaxing Sounds")
        }
    }
}

struct MasterVolumeView: View {
    @Binding var masterVolume: Float

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "speaker.wave.2.fill")
                .foregroundColor(.primary)
            Slider(value: Binding(get: {
                Double(masterVolume)
            }, set: { newVal in
                masterVolume = Float(newVal)
            }), in: 0...1)
            .frame(width: 160)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(materialBackground())
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
        .frame(maxWidth: 280)
    }

    @ViewBuilder
    private func materialBackground() -> some View {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 9.0, *) {
            Rectangle().fill(.ultraThinMaterial)
        } else {
            Rectangle().fill(Color.black.opacity(0.22))
        }
    }
}

struct SoundItemViewFixed: View {
    @ObservedObject var sound: AmbientSound
    @ObservedObject var manager: AmbientSoundManager
    @Binding var activeSound: UUID?

    let tileHeight: CGFloat
    let sliderHeight: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.clear)
                .frame(height: tileHeight)

            VStack(spacing: 8) {
                Spacer(minLength: 8)

                Button(action: togglePlay) {
                    ZStack {
                        Circle()
                            .fill(sound.isPlaying ? Color.blue.opacity(0.85) : Color.gray.opacity(0.3))
                            .frame(width: 80, height: 80)

                        Image(systemName: iconForSound(sound.name))
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Spacer(minLength: 8)

                ZStack {
                    Color.clear
                    Slider(value: Binding(get: {
                        Double(sound.volume)
                    }, set: { newVal in
                        manager.updateVolume(sound, volume: Float(newVal))
                    }), in: 0...1)
                    .frame(height: sliderHeight)
                    .padding(.horizontal, 8)
                    .opacity(sound.isPlaying ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.25), value: sound.isPlaying)
                    .disabled(!sound.isPlaying)
                }
                .frame(height: sliderHeight)
            }
            .frame(height: tileHeight)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    activeSound = (activeSound == sound.id) ? nil : sound.id
                }
            }
        }
    }

    private func togglePlay() {
        if sound.isPlaying {
            manager.stop(sound)
        } else {
            manager.play(sound)
            withAnimation(.easeInOut(duration: 0.2)) {
                activeSound = sound.id
            }
        }
    }

    private func iconForSound(_ name: String) -> String {
        switch name.lowercased() {
        case "rain": return "cloud.rain.fill"
        case "birds": return "bird.fill"
        case "thunder": return "cloud.bolt.rain.fill"
        case "powerrangers": return "figure.cooldown"
        case "minecraft": return "gamecontroller.fill"
        case "fan": return "fanblades.fill"
        default: return "waveform"
        }
    }
}

struct SoundsTab_Previews: PreviewProvider {
    static var previews: some View {
        SoundsTab()
    }
}
