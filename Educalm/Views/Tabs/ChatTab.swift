//
//  ChatTab.swift
//  EduCalm
//
//  Created by Adon Omeri on 16/8/2025.
//  Dylan here: i helped with the ai s
//

import ColorfulX
import Defaults
import FoundationModels
import SwiftUI

struct ChatTab: View {
	@State private var text = ""
	@State private var session: LanguageModelSession?
	@State private var copiedMessageText: String?

	/// true if user, false if llm
	@State var conversation: [(Bool, String)] = []

	private let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)

	private let options = GenerationOptions(temperature: 1)

	@State var colorfulPreset = ColorfulPreset.starry

	private var instructions: String {
		let userName = Defaults[.userName].isEmpty ? "the user" : Defaults[.userName]
		let userAge = Defaults[.userAge].isEmpty ? "unknown age" : "\(Defaults[.userAge]) years old"
		let userGrade = Defaults[.userSchoolGrade].title
		let userGender = Defaults[.userGender].title.lowercased()

        return """
        WHO ARE YOU:
        You are EduCalm, a mental health support model for young people in Australian high schools. Your role is to be someone to talk to about anything, providing empathetic guidance and coping strategies if needed.

        PRIORITIES:
        - The user's safety and wellbeing come first.
        - Always respond with kindness and empathy, acknowledging them; never dismiss or ignore them.
        - Your responses should always help the user with their goals assuming its necessary for their health (and safe for others too).
        - If you can't help the user, encourage them; for example, if they share an achievement, celebrate with them! If they ask for a recipe, provide a healthy one. Use your judgement to keep answers related.
        - If you can't encourage or help them, discourage them from doing bad and negative things.
        - Emojis can help lighten the mood, so use them efficiently and sparingly.
        - Make responses easy to read and concise, and avoid overwhelming with too much text.
        - Use text formatting sparingly but effectively (lists are okay but not always needed).
        - Use proper grammer and proper english
        - Use a bit of colloquial language to connect more with the user (e.g. 'Yay' instead of 'Good for you'); again, your judgement is important here.
        - Try to help as best you can, but if you are unsure how to help, gently ask for clarification; otherwise refer them to real-world resources that are better equipped to help.
        - If the user seems in danger, advise them to seek immediate help from trusted adults or emergency services.
        

        USER CONTEXT:
        - Name: \(userName)
        - Age: \(userAge)
        - School: \(userGrade)
        - Gender: \(userGender)
        - Mental Health Concerns: \(Defaults[.userMentalHealthConcerns])
        - Seeing Professional: \(Defaults[.userSeeingProfessional])
        - Mood Rating: \(Defaults[.userAverageMoodRating] )
        - Distressing Thoughts Frequency: \(Defaults[.userDistressingThoughtsFrequency])
        - Social Connections: \(Defaults[.userHasFriends])
        - Motivation: \(Defaults[.userMotivationForMentalHealth])
        - Disabilities: \(Defaults[.userHasDisabilites])

        PREVIOUS HISTORY:
        \(conversation.isEmpty ? "None yet" : conversation.compactMap { $0.0 ? "• \($0.1)" : nil }.joined(separator: "\n"))
        """.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	@FocusState private var isTextFieldFocused: Bool

	var body: some View {
		NavigationStack {
			Group {
				switch model.availability {
				case .available:
					chatInterface()
				case .unavailable(.deviceNotEligible):
					unavailableView("Device not eligible for Apple Intelligence")
				case .unavailable(.appleIntelligenceNotEnabled):
					unavailableView("Please enable Apple Intelligence in Settings")
				case .unavailable(.modelNotReady):
					unavailableView("Model is downloading or not ready")
				case let .unavailable(other):
					unavailableView("Model unavailable: \(other)")
				}
			}
			#if os(iOS)
			.toolbar {
				ToolbarItem(placement: .title) {
					Text("Chat")
				}
			}
			#endif
		}
		.onAppear {
			warmUpModel()
			isTextFieldFocused = true
		}
	}

	private func chatInterface() -> some View {
        ScrollViewReader { proxy in
            ZStack {
                ColorfulView(color: $colorfulPreset)
                    .ignoresSafeArea()
                    .opacity(0.5)
                ScrollView {
                    LazyVStack {
                        ForEach(Array(conversation.enumerated()), id: \.offset) {
                            _,
                            message in
                            if message.0 {
                                HStack {
                                    Spacer(minLength: 50)
                                    Text(message.1)
                                        .textSelection(.enabled)
                                        .padding(10)
                                        .foregroundStyle(.white)
                                        .glassEffect(
                                            .clear.tint(.gray).interactive(),
                                            in: .rect(cornerRadius: 15)
                                        )
                                }
                                .padding(.horizontal, 10)
                                
                            } else {
                                HStack(alignment: .bottom) {
                                    if message.1.isEmpty {
                                        Image(systemName: "ellipsis")
                                            .symbolEffect(.variableColor.iterative.hideInactiveLayers.reversing, options: .repeat(.continuous))
                                            .foregroundStyle(.white)
                                            .padding(10)
                                            .glassEffect(
                                                .clear.tint(.blue).interactive(),
                                                in: .rect(cornerRadius: 15)
                                            )
                                    } else {
                                        Text(.init(message.1))
                                            .textSelection(.enabled)
                                            .contentTransition(.numericText())
                                            .padding(10)
                                            .foregroundStyle(.white)
                                            .animation(.easeInOut(duration: 0.3), value: message.1)
                                            .glassEffect(
                                                .clear.tint(.blue).interactive(),
                                                in: .rect(cornerRadius: 15)
                                            )
                                        
                                        Button {
#if os(iOS)
                                            UIPasteboard.general.string = message.1
#elseif os(macOS)
                                            NSPasteboard.general.clearContents()
                                            NSPasteboard.general.setString(message.1, forType: .string)
#endif
                                            copiedMessageText = message.1
                                            
                                            // Reset the copied state after 2 seconds
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                copiedMessageText = nil
                                            }
                                        } label: {
                                            copyLabel(text: message.1, isCopied: copiedMessageText == message.1)
                                                .foregroundStyle(.white)
                                        }
                                        .buttonStyle(.plain)
                                        .frame(width: 25, height: 25)
                                        .glassEffect(
                                            .clear.tint(.purple).interactive(),
                                            in: .rect(cornerRadius: 5)
                                        )
                                    }
                                    Spacer(minLength: 50)
                                }
                                .padding(.horizontal, 10)
                                .animation(
                                    .easeInOut,
                                    value: message.1.isEmpty
                                )
                            }
                        }
                        
                        Rectangle()
                            .frame(width: 1, height: 1)
                            .opacity(0)
                            .id("bottom")
                            .listRowBackground(Color.clear)
                    }
                }
            }
            .safeAreaBar(edge: .bottom) {
                VStack(spacing: 0) {
                    Text("⚠️ EduCalm is not a substitute for professional mental health care. If you're in danger, please seek help immediately.")
                        .font(.footnote)
						.foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
//                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 8)
						.padding(.bottom, -10)

                    HStack {
                        TextField("Enter message", text: $text)
                            .padding(10)
                            .textFieldStyle(.plain)
                            .background(Color.clear)
                            .focused($isTextFieldFocused)
                            .onSubmit { sendMessage() }
                            .glassEffect(
                                .clear,
                                in: .capsule
                            )
                            .foregroundStyle(.white)
                        
                        Button {
                            sendMessage()
                        } label: {
                            Label("Send", systemImage: "arrow.up")
                                .bold()
                                .foregroundStyle(.white)
                                .padding(10)
                        }
                        .buttonStyle(.glassProminent)
                        .buttonBorderShape(.capsule)
                        //					.glassEffect(
                        //						.clear.tint(.purple).interactive(),
                        //						in: .capsule
                        //					)
                        .disabled(
                            text.isEmpty || session?.isResponding == true || session == nil
                        )
                    }
                    .padding()
                }
                
                .onChange(of: conversation.count) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        if session?.isResponding == true {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        } else if !conversation.isEmpty {
                            proxy.scrollTo(conversation.count - 1, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: conversation.last?.1) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .onChange(of: session?.isResponding) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        if session?.isResponding == true {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
                .background(.clear)
                .scrollContentBackground(.hidden)
            }
        }
	}

	private func copyLabel(text _: String, isCopied: Bool) -> some View {
		return Label(
			isCopied ? "Copied" : "Copy",
			systemImage: isCopied ? "checkmark.circle.fill" : "doc.on.doc"
		)
		.padding()
		.contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating))
		.animation(.easeInOut, value: isCopied)
		.labelStyle(.iconOnly)
	}

	private func unavailableView(_ message: String) -> some View {
		VStack(spacing: 16) {
			Image(systemName: "exclamationmark.triangle")
				.font(.system(size: 50))
				.foregroundColor(.orange)

			Text(message)
				.multilineTextAlignment(.center)
				.foregroundColor(.secondary)
		}
		.padding()
	}

	private func warmUpModel() {
		guard model.availability == .available else {
			return
		}

		session = LanguageModelSession(
			model: model,
			tools: [],
			instructions: instructions
		)
		session?.prewarm()
	}

	private func sendMessage() {
		guard !text.isEmpty, let session = session else { return }

		let userInput = text
		conversation.append((true, text))
		text = ""

		// Add placeholder for AI response that will be updated as it streams
		conversation.append((false, ""))
		let aiMessageIndex = conversation.count - 1

		Task {
			do {
				let prompt = """
				\(userInput)
				"""

				// Use streaming response instead of regular respond
				let stream = session.streamResponse(to: prompt, options: options)

				// Stream the response and update the UI in real-time
				for try await partialResponse in stream {
					await MainActor.run {
                        let cleaned = partialResponse.content
                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                                    .replacingOccurrences(of: "\n+", with: "\n", options: .regularExpression)
                        
						conversation[aiMessageIndex] = (
							false,
							cleaned
						)
					}
				}

			} catch {
				await MainActor.run {
					conversation[aiMessageIndex] = (false, """
					It sounds like you’re in serious danger. Please **seek help immediately**. You can connect with professionals or support services:

					**People:**
					- Psychologist: Mental health professional specializing in therapy
					- Counselor: Trained professional providing guidance and support
					- Therapist: Licensed practitioner for mental health treatment

					**Helplines:**
					- Lifeline: 131114 (24/7 crisis support)
					- Beyond Blue: 1300224636 (Depression and anxiety support)
					- Kids Helpline: 1800 551 800 (Support for young people)

					**Websites:**
					- Beyond Blue: beyondblue.org.au (Mental health information)
					- Headspace: headspace.org.au (Youth mental health)
					- ReachOut: reachout.com (Mental health resources for young people)

					Your safety is the priority — reach out immediately.
					""")
				}
			}
		}
	}
}

#Preview {
	ChatTab()
}
