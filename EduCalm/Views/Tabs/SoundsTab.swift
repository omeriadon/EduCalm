//
//  SoundsTab.swift
//  EduCalm
//
//  Cross-platform Sounds tab for iOS & macOS
//  Updated for consistent navigation and background behavior
//

import SwiftUI
import AVFoundation
import Combine
import ColorfulX

// MARK: - Model

struct Sound: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let filename: String
    let systemImage: String
    var isPlaying: Bool = false
    var volume: Float = 1.0
}

// MARK: - Audio Manager

final class SoundsAudioManager: ObservableObject {
    @Published private(set) var sounds: [Sound] = [
        Sound(title: "Rain", filename: "rain", systemImage: "cloud.rain"),
        Sound(title: "Thunder", filename: "thunder", systemImage: "cloud.bolt.rain"),
        Sound(title: "Fire", filename: "fire", systemImage: "flame"),
        Sound(title: "Birds", filename: "birds", systemImage: "bird"),
        Sound(title: "Night", filename: "night", systemImage: "moon.stars"),
        Sound(title: "Fan", filename: "fan", systemImage: "fanblades"),
        Sound(title: "Subwoofer", filename: "subwoofer", systemImage: "gamecontroller"),
        Sound(title: "Water", filename: "water", systemImage: "water.waves")
    ]
    
    private var players: [UUID: AVAudioPlayer] = [:]
    @Published var masterVolume: Float = 1.0 {
        didSet { updateAllVolumes() }
    }
    
    private let extensions = ["mp3", "wav", "m4a"]
    private let audioQueue = DispatchQueue(label: "com.educalm.sounds.audio", qos: .userInitiated)
    
    init() { setupAudioSessionIfNeeded() }
    
    private func setupAudioSessionIfNeeded() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setPreferredIOBufferDuration(0.005)
            try session.setActive(true)
        } catch { print("AudioSession error:", error) }
        #endif
    }
    
    private func urlForSound(_ filename: String) -> URL? {
        for ext in extensions {
            if let url = Bundle.main.url(forResource: filename, withExtension: ext) { return url }
        }
        return nil
    }
    
    private func ensurePlayerExists(for index: Int, completion: @escaping (AVAudioPlayer?) -> Void) {
        let sound = sounds[index]
        let id = sound.id
        if let player = players[id] { completion(player); return }
        
        audioQueue.async { [weak self] in
            guard let self = self else { completion(nil); return }
            guard let url = self.urlForSound(sound.filename) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.numberOfLoops = -1
                player.volume = sound.volume * self.masterVolume
                player.prepareToPlay()
                DispatchQueue.main.async {
                    self.players[id] = player
                    completion(player)
                }
            } catch { DispatchQueue.main.async { completion(nil) } }
        }
    }
    
    func toggle(_ sound: Sound) {
        guard let index = sounds.firstIndex(of: sound) else { return }
        let id = sounds[index].id
        let wantPlaying = !sounds[index].isPlaying
        
        withAnimation(.easeInOut(duration: 0.3)) { sounds[index].isPlaying = wantPlaying }
        
        if wantPlaying {
            ensurePlayerExists(for: index) { [weak self] player in
                guard let self = self, let p = player else { return }
                p.volume = self.sounds[index].volume * self.masterVolume
                p.currentTime = 0
                p.play()
            }
        } else { players[id]?.pause() }
    }
    
    func setVolume(for sound: Sound, volume: Float) {
        guard let index = sounds.firstIndex(of: sound) else { return }
        let clamped = max(0, min(1, volume))
        sounds[index].volume = clamped
        if let player = players[sound.id] { player.volume = clamped * masterVolume }
    }
    
    private func updateAllVolumes() {
        for i in sounds.indices {
            let id = sounds[i].id
            if let p = players[id] { p.volume = sounds[i].volume * masterVolume }
        }
    }
    
    func stopAll() {
        for id in players.keys {
            players[id]?.pause()
            players[id]?.currentTime = 0
        }
        for i in sounds.indices { sounds[i].isPlaying = false }
    }
}

// MARK: - Views

struct SoundsTab: View {
    @EnvironmentObject private var audioManager: SoundsAudioManager
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    @State var colourfulPreset = ColorfulPreset.appleIntelligence
    
    private var columns: [GridItem] {
        #if os(iOS)
        let count = sizeClass == .regular ? 4 : 3
        #else
        let screenWidth = NSScreen.main?.frame.width ?? 900
        let count = screenWidth > 900 ? 4 : 3
        #endif
        return Array(repeating: GridItem(.flexible(), spacing: 48), count: count)
    }
    
    var body: some View {
        ZStack {
            ColorfulView(color: $colourfulPreset)
                .opacity(0.4)
                .ignoresSafeArea()
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 48) {
                        ForEach(audioManager.sounds) { sound in
                            SoundButton(sound: sound)
                                .environmentObject(audioManager)
                        }
                    }
                    .padding(.horizontal, 48)
                    .padding(.top, 150)
                    
                    // Master Volume Control
                    HStack(spacing: 14) {
                        Image(systemName: "speaker.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.95))
                        Slider(value: Binding(
                            get: { Double(audioManager.masterVolume) },
                            set: { newValue in audioManager.masterVolume = Float(newValue) }
                        ), in: 0...1)
                        .accentColor(Color(red: 0.8, green: 0.2, blue: 0.4))
                        .frame(maxWidth: 420)
                        Button { audioManager.stopAll() } label: {
                            Image(systemName: "stop.fill")
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                            .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 6)
                    )
                    .padding(.bottom, 48)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
    }
}

// MARK: - Button

private struct SoundButton: View {
    @EnvironmentObject var audioManager: SoundsAudioManager
    let sound: Sound
    
    private let highlightColor = Color(red: 0.8, green: 0.2, blue: 0.4)
    
    var body: some View {
        VStack(spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) { audioManager.toggle(sound) }
            } label: {
                ZStack {
                    Circle()
                        .fill(sound.isPlaying ? highlightColor : Color.white.opacity(0.15))
                        .frame(width: 100, height: 100)
                        .overlay(Circle().stroke(Color.white.opacity(0.06), lineWidth: 1))
                    Image(systemName: sound.systemImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.white)
                        .zIndex(1)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(sound.isPlaying ? 1.05 : 1.0)
            .shadow(color: Color.black.opacity(0.35),
                    radius: sound.isPlaying ? 10 : 4,
                    x: 0, y: 6)
            
            Slider(value: Binding(
                get: { Double(sound.volume) },
                set: { newValue in audioManager.setVolume(for: sound, volume: Float(newValue)) }
            ), in: 0...1)
            .frame(width: 100, height: 20)
            .accentColor(highlightColor)
            .opacity(sound.isPlaying ? 1.0 : 0.0)
        }
        .frame(height: 140)
    }
}
