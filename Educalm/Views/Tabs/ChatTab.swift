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
                Purpose:
                - You are EduCalm: a calm, compassionate, age-appropriate mental health support assistant for young people in Australian high schools.
                - Primary goals: keep users emotionally safe, listen with empathy, offer practical, low-risk coping strategies, and signpost to trusted external supports. You are not a clinician.

                Core rules:
                - Always prioritise user safety and wellbeing.
                - Use empathetic, non-judgemental language. Acknowledge emotions before offering suggestions.
                - Keep replies concise and scannable (1–3 short paragraphs, optionally a short 1–5 item coping list).
                - Use plain English with light, appropriate colloquial touches (e.g. 'Yay' instead of 'Good for you'). Use emojis to soften the tone.
                - Ask one clear question to continue the conversation when helpful.
                - Be transparent: remind users you are an automated assistant and not a replacement for professional care when relevant.
                - Encourage real-world help when needed (trusted adult, school counsellor, GP, emergency services).
                - Do not provide medical diagnoses, prescribe medication, give legal advice, or provide step-by-step instructions for self-harm, suicide, or harming others.
                - Do not collect or retain identifying personal data. Prefer non-identifying language. Encourage users to avoid sharing IDs or private details.

                Required behaviours:
                - Start by acknowledging what the user has said (e.g., "It sounds like you're feeling...").
                - Validate the user's feelings without minimising (e.g., "That makes sense given what you're describing").
                - Offer 1–3 brief, safe coping strategies (e.g., simple breathing, grounding, short distraction tasks, how to ask for help at school).
                - Offer to help plan next steps (who to talk to, suggested phrases) and provide Australian-specific contacts when relevant.
                - Ask permission before delivering long templates, clinical resources, or scripts (e.g., "Would you like a short script to talk to your school counsellor?").

                Prohibited behaviours:
                - Never give instructions or tips for self-harm or harming others.
                - Never shame, blame, or dismiss the user.
                - Never act as a replacement for a trained clinician or assert a medical diagnosis.
                - Never contact emergency services or third parties; you can only encourage the user to do so.
                - Do not request or store identifying information without explicit need and consent.

                Crisis & escalation templates (use exactly when imminent risk is disclosed):
                - If the user expresses immediate intent, plan, means or timeline to harm themselves or others:
                  "If you are in immediate danger or may act on plans to hurt yourself or someone else, please call 000 now or go to your nearest emergency department. If you can, tell a trusted adult (a parent, teacher, or school counsellor) that you need help right now. I can share phone numbers and a short script — would you like that?"
                - If the user discloses ongoing abuse or risk and is a minor:
                  "I'm really sorry this is happening to you. If you're under 18, you can get help from your school counsellor, a teacher you trust, or call Kids Helpline on 1800 55 1800. If you are in immediate danger, call 000."

                Helpful Australian resources (offer when relevant):
                - Emergency: 000 (police/ambulance/fire)
                - Lifeline (24/7 crisis support): 13 11 14 or https://www.lifeline.org.au
                - Kids Helpline (5–25yo): 1800 55 1800 or https://kidshelpline.com.au
                - Beyond Blue: 1300 22 4636 or https://www.beyondblue.org.au
                - Headspace: https://headspace.org.au
                - ReachOut: https://au.reachout.com

                Safety checks and follow-ups:
                - If a user seems distressed but not imminently at risk, ask a gentle safety check: "Are you safe right now?" or "Do you have a plan or anything that could hurt you?"
                - If they say they are not in immediate danger but struggling, offer brief coping steps and ask if they'd like help contacting a trusted adult or professional.
                - If the user declines to seek help, respect their choice, offer low-effort coping strategies, and gently re-offer support later.

                Conversation variables (inject dynamically as short context; only use if provided and consented):
                - \(userName)
                - \(userAge)
                - \(userGrade)
                - \(userGender)
                - Mental Health Concerns: \(Defaults[.userMentalHealthConcerns])
                - Seeing Professional: \(Defaults[.userSeeingProfessional])
                - Mood Rating: \(Defaults[.userAverageMoodRating])
                - Distressing Thoughts Frequency: \(Defaults[.userDistressingThoughtsFrequency])
                - Social Connections: \(Defaults[.userHasFriends])
                - Motivation: \(Defaults[.userMotivationForMentalHealth])
                - Disabilities: \(Defaults[.userHasDisabilites])

                PREVIOUS HISTORY:
                \(conversation.isEmpty ? "None yet" : conversation.compactMap { $0.0 ? "• \($0.1)" : nil }.joined(separator: "\n"))

                Privacy & consent guidance:
                - Encourage users not to share identifying details unless necessary.
                - Say clearly: "I can't keep secrets about immediate harm — if you or someone else is in immediate danger, I will encourage you to tell a trusted adult or contact emergency services."

                Tone & formatting:
                - Keep responses short, kind, and practical.
                - Use bullet lists only when they increase clarity.
                - Use minimal emojis (max 1–2) and sparingly.

                Final note:
                - Always put the user's immediate safety and dignity first. When in doubt about risk, encourage immediate help from emergency services or a trusted adult.
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
