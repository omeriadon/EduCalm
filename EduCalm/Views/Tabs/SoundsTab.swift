//  SoundsTab.swift
//  EduCalm
//
//  Created by Dylan Karunanayake on 25/8/2025.
//  yay it works
//

import SwiftUI
import ColorfulX
@preconcurrency import AVFoundation
import Combine
import Foundation

// AmbientSound is a reference type so changes publish correctly to the UI across platforms
final class AmbientSound: ObservableObject, Identifiable {
    let id = UUID()
    let name: String
    let fileName: String
    @Published var volume: Float
    let playerNode: AVAudioPlayerNode
    var audioFile: AVAudioFile?
    var pcmBuffer: AVAudioPCMBuffer?
    @Published var isPlaying: Bool = false

    init(name: String, fileName: String, volume: Float = 0.5, playerNode: AVAudioPlayerNode, audioFile: AVAudioFile?, pcmBuffer: AVAudioPCMBuffer?) {
        self.name = name
        self.fileName = fileName
        self.volume = volume
        self.playerNode = playerNode
        self.audioFile = audioFile
        self.pcmBuffer = pcmBuffer
    }
}

// Manager interacts with AVAudioEngine; UI updates are dispatched to main thread where needed.
class AmbientSoundManager: ObservableObject {
    let engine = AVAudioEngine()
    @Published var sounds: [AmbientSound] = []
    @Published var masterVolume: Float = 1.0 {
        didSet {
            engine.mainMixerNode.outputVolume = masterVolume
        }
    }

    private var fadeTimers: [UUID: Timer] = [:]

    init() {
        #if os(iOS) || os(tvOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️ Could not set up audio session: \(error)")
        }
        #endif

        loadSounds([
            ("Rain", "rain.mp3"),
            ("Birds", "birds.mp3"),
            ("Fan", "fan.mp3"),
            ("PowerRangers", "ggpr.mp3"),
            ("Minecraft", "subwoofer.mp3"),
            ("Thunder", "thunder.mp3")
        ])

        engine.prepare()
        do {
            try engine.start()
            engine.mainMixerNode.outputVolume = masterVolume
        } catch {
            print("⚠️ Audio engine failed to start: \(error)")
        }
    }

    private func loadSounds(_ files: [(String, String)]) {
        for (name, fileName) in files {
            if let url = Bundle.main.url(forResource: fileName, withExtension: nil) {
                do {
                    let audioFile = try AVAudioFile(forReading: url)

                    // create a PCM buffer to loop
                    let processingFormat = audioFile.processingFormat
                    let frameCount = AVAudioFrameCount(audioFile.length)
                    let buffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: frameCount)
                    try audioFile.read(into: buffer!)
                    buffer?.frameLength = frameCount

                    let node = AVAudioPlayerNode()
                    engine.attach(node)
                    engine.connect(node, to: engine.mainMixerNode, format: processingFormat)

                    let sound = AmbientSound(name: name, fileName: fileName, volume: 0.7, playerNode: node, audioFile: audioFile, pcmBuffer: buffer)
                    sounds.append(sound)
                } catch {
                    print("⚠️ Failed to load \(fileName): \(error)")
                }
            } else {
                print("⚠️ File \(fileName) not found in bundle")
            }
        }
    }

    func play(_ sound: AmbientSound) {
        guard let buffer = sound.pcmBuffer else { return }
        let node = sound.playerNode

        stopFade(for: sound)

        if !node.isPlaying {
            node.volume = sound.volume
            node.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            node.play()

            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.25)) {
                    sound.isPlaying = true
                }
            }
        }
    }

    func stop(_ sound: AmbientSound, fadeDuration: TimeInterval = 1.5) {
        guard sound.playerNode.isPlaying else {
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.25)) {
                    sound.isPlaying = false
                }
            }
            return
        }
        startFadeOut(for: sound, duration: fadeDuration)
    }

    private func startFadeOut(for sound: AmbientSound, duration: TimeInterval) {
        stopFade(for: sound)

        let node = sound.playerNode
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
                sound.playerNode.volume = sound.volume
            }
        }
    }

    func updateVolume(_ sound: AmbientSound, volume: Float) {
        DispatchQueue.main.async {
            sound.volume = volume
            if sound.playerNode.isPlaying {
                sound.playerNode.volume = volume
            }
        }
    }

    func stopAll(fadeDuration: TimeInterval = 1.5) {
        for s in sounds where s.playerNode.isPlaying {
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
                // compute how many columns fit and build a fixed grid width so we can center it horizontally
                let availableWidth = max(0, proxy.size.width - horizontalPadding * 2)
                let columnsThatFit = max(1, Int((availableWidth + spacing) / (tileWidth + spacing)))
                let totalGridWidth = CGFloat(columnsThatFit) * tileWidth + CGFloat(columnsThatFit - 1) * spacing

                // Vertical centering: VStack with spacers and minHeight set to proxy.height
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
                            .frame(width: min(totalGridWidth, proxy.size.width - 16)) // keep some breathing room on very small widths

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, horizontalPadding)

                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: proxy.size.height)
                }
                .zIndex(0)

                // Master volume overlay centered horizontally at the bottom,
                // and lifted up a bit to avoid overlapping the center-bottom grid tile.
                VStack {
                    Spacer()
                    HStack {
                        Spacer(minLength: 0)

                        MasterVolumeView(masterVolume: $manager.masterVolume)
                            // lift above bottom by safe area + extra padding so it doesn't overlap center tile
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
            // Optional card background (transparent so it doesn't clash with ColorfulView)
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

                // Reserved slider area: fixed height so the icon never shifts.
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
