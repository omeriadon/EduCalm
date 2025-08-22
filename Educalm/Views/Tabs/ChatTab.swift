//
//  ChatTab.swift
//  EduCalm
//
//  Created by Dylan Karunanayake on 22/8/2025.
//

import SwiftUI
import FoundationModels
import Combine

struct ChatTab: View {
    
    @State private var text = ""
    @State private var conversation: [(Bool, String)] = []   // (isUser, message)
    @State private var session: Session? = nil
    @State private var copiedMessageText: String? = nil
    
    var body: some View {
        VStack {
            chatInterface()
            
            // Disclaimer
            Text("⚠️ EduCalm is a supportive mental health helper, not a replacement for professional care. If you’re struggling, please reach out to a qualified professional.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 6)
        }
        .onAppear {
            setupSession()
        }
    }
    
    // MARK: - Chat UI
    
    private func chatInterface() -> some View {
        VStack {
            List {
                ForEach(Array(conversation.enumerated()), id: \.offset) { _, message in
                    messageBubble(message: message)
                }
            }
            .listStyle(.plain)
            
            HStack {
                TextField("Type a message…", text: $text)
                    .textFieldStyle(.roundedBorder)
                
                Button("Send") {
                    sendMessage()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
    
    // MARK: - Message Bubble Subview
    
    @ViewBuilder
    private func messageBubble(message: (Bool, String)) -> some View {
        if message.0 {
            // User bubble
            HStack {
                Spacer(minLength: 50)
                Text(message.1)
                    .textSelection(.enabled)
                    .padding()
                    .foregroundStyle(.white)
                    .glassEffect(
                        .clear.tint(.gray).interactive(),
                        in: .rect(cornerRadius: 15)
                    )
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .padding(.horizontal)
        } else {
            // AI bubble
            HStack(alignment: .bottom) {
                if message.1.isEmpty {
                    Image(systemName: "ellipsis")
                        .symbolEffect(.variableColor.iterative.hideInactiveLayers.reversing, options: .repeat(.continuous))
                        .foregroundStyle(.white)
                        .padding()
                        .glassEffect(
                            .clear.tint(.blue).interactive(),
                            in: .rect(cornerRadius: 15)
                        )
                } else {
                    Text(.init(message.1))
                        .textSelection(.enabled)
                        .contentTransition(.numericText())
                        .animation(.easeInOut, value: message.1)
                        .padding()
                        .foregroundStyle(.white)
                        .glassEffect(
                            .clear.tint(.blue).interactive(),
                            in: .rect(cornerRadius: 15)
                        )
                    
                    Button {
#if os(iOS) || os(tvOS) || os(watchOS)
                        UIPasteboard.general.string = message.1
#elseif os(macOS)
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(message.1, forType: .string)
#endif
                        copiedMessageText = message.1
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copiedMessageText = nil
                        }
                    } label: {
                        copyLabel(text: message.1, isCopied: copiedMessageText == message.1)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.glassProminent)
                }
                Spacer(minLength: 20)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .contentTransition(.opacity)
            .animation(.easeInOut, value: message.1.isEmpty)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Copy Button
    
    private func copyLabel(text: String, isCopied: Bool) -> some View {
        Group {
            if isCopied {
                Image(systemName: "checkmark")
            } else {
                Image(systemName: "doc.on.doc")
            }
        }
        .foregroundStyle(.white)
    }
    
    // MARK: - Session Setup
    
    private func setupSession() {
        do {
            let config = SessionConfig(
                model: .default,
                systemPrompt: """
                You are a compassionate and supportive mental health assistant. 
                - Always respond with empathy, validation, and encouragement. 
                - Provide practical coping strategies, grounding exercises, and perspective where possible. 
                - Never give medical diagnoses or replace professional therapy. 
                - If the user mentions self-harm or suicidal thoughts, encourage them to reach out to a trusted person or professional, and provide crisis hotline information.
                - Keep responses clear, warm, and concise.
                """
            )
            session = try Session(config: config)
        } catch {
            print("Failed to set up session: \(error)")
        }
    }
    
    // MARK: - Send Message
    
    private func sendMessage() {
        guard !text.isEmpty, let session = session else { return }
        
        let userInput = text
        conversation.append((true, userInput))
        text = ""
        
        // Crisis check
        if userInput.localizedCaseInsensitiveContains("suicide") ||
            userInput.localizedCaseInsensitiveContains("kill myself") ||
            userInput.localizedCaseInsensitiveContains("end my life") {
            conversation.append((false,
            """
            I hear that you’re feeling overwhelmed and that’s very serious. 💙  
            Please, if you’re in danger of acting on these thoughts, call your local emergency number immediately.  
            You are not alone — in Australia you can call Lifeline at 13 11 14, in the U.S. dial 988, or search for the crisis line in your country.  
            Reaching out to someone you trust, a professional, or a helpline can help lighten the weight.
            """))
            return
        }
        
        // Placeholder AI response
        conversation.append((false, ""))
        let aiMessageIndex = conversation.count - 1
        
        Task {
            do {
                let prompt = """
                User message:
                \(userInput)
                """
                
                let stream = session.streamResponse(to: prompt)
                
                for try await partialResponse in stream {
                    await MainActor.run {
                        conversation[aiMessageIndex] = (false, partialResponse.content)
                    }
                }
                
            } catch {
                await MainActor.run {
                    conversation[aiMessageIndex] = (
                        false,
                        "Sorry, I encountered an error: \(error.localizedDescription)"
                    )
                }
            }
        }
    }
}
