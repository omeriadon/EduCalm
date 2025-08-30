import SwiftUI
import AVFoundation
import Combine
import ColorfulX

struct Sound: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let filename: String
    let systemImage: String
    var isPlaying: Bool = false
    var volume: Float = 1.0
}

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
                    .padding(.top, 120)
                    
                    HStack(spacing: 14) {
                        Image(systemName: "speaker.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                        Slider(value: Binding(
                            get: { Double(audioManager.masterVolume) },
                            set: { newValue in audioManager.masterVolume = Float(newValue) }
                        ), in: 0...1)
                        .tint(Color.pink)
                        .frame(maxWidth: 420)
                        Button {
                            audioManager.stopAll()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "stop.fill")
                                    .foregroundStyle(.white)
                                Text("Stop")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .glassEffect(.clear)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    
                    .glassEffect(.clear)                    .padding(.top, 40)
                    .padding(.bottom, 48)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
    }
}

private struct SoundButton: View {
    @EnvironmentObject var audioManager: SoundsAudioManager
    let sound: Sound
    private let glowColor = Color(red: 0.9, green: 0.25, blue: 0.45)
    
    var body: some View {
        VStack(spacing: 10) {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    audioManager.toggle(sound)
                }
            } label: {
                ZStack {
                    Circle()
                        .glassEffect(.clear) // liquid glass
                        .frame(width: 110, height: 110)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.6), Color.white.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.4
                                )
                        )
                        .shadow(
                            color: sound.isPlaying ? glowColor.opacity(0.6) : .black.opacity(0.25),
                            radius: sound.isPlaying ? 20 : 10,
                            x: 0, y: 10
                        )
                    
                    Image(systemName: sound.systemImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 6, x: 0, y: 3)
                }
            }
            .buttonStyle(.plain)
            .scaleEffect(sound.isPlaying ? 1.1 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.65), value: sound.isPlaying)
            
            Slider(value: Binding(
                get: { Double(sound.volume) },
                set: { newValue in audioManager.setVolume(for: sound, volume: Float(newValue)) }
            ), in: 0...1)
            .tint(glowColor)
            .frame(width: 110)
            .opacity(sound.isPlaying ? 1 : 0)
            .padding(.top, 6)
        }
        .frame(height: 160)
    }
}
