//
//  DeviceChatView.swift
//  Silicon Vault
//
//  Created by Adon Omeri on 16/8/2025.
//

import ColorfulX
import FoundationModels
import SwiftUI

struct ChatTab: View {
	@State private var text = ""
	@State private var session: LanguageModelSession?
	@State private var copiedMessageText: String?

	/// true if user, false if llm
	@State var conversation: [(Bool, String)] = []

	private let model = SystemLanguageModel.default

	@State var colorfulPreset = ColorfulPreset.starry

	private let instructions = """
	You must be concise and clear.
	Stay helpful to the user's questions.
	Do not be overly emotional, your job is to inform user only.
	When asked a question make sure to provide some information, not just qualitative info.

	IMPORTANT: You are provided with device data for context only. NEVER repeat, quote, or echo back the device data structure in your response. Only use it to answer questions about the device's specifications, features, or capabilities. Answer directly without referencing the data structure format.
	When referring to the deice use its name property.

	Use dot points when asked a question containing multiple pieces of data, such as a summary of the device or asking reasons why soemthing may be good/bad at gaming, photos, etc
	"""

	@FocusState private var isTextFieldFocused: Bool

	var body: some View {
		NavigationStack {
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
				List {
					ForEach(Array(conversation.enumerated()), id: \.offset) {
						_,
							message in
						if message.0 {
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

										// Reset the copied state after 2 seconds
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
							.animation(
								.easeInOut,
								value: message.1.isEmpty
							)

						}
					}

					// Add padding at bottom to prevent content being hidden behind input overlay
				}
				.safeAreaBar(edge: .bottom) {
					HStack {
						TextField("Enter message", text: $text)
							.padding()
							.textFieldStyle(.plain)
							.focused($isTextFieldFocused)
							.onSubmit { sendMessage() }
							.glassEffect(
								.regular,
								in: .capsule
							)
							.foregroundStyle(.white)

						Button {
							sendMessage()
						} label: {
							Label("Send", systemImage: "arrow.up")
								.bold()
								.foregroundStyle(.white)
								.padding(8)

						}
						.buttonStyle(.glassProminent)
						.tint(.purple)
						.disabled(
							text.isEmpty || session?.isResponding == true || session == nil
						)
					}
					.padding()
				}

//					.toolbar {
				// #if os(iOS)
//						ToolbarItem(placement: .bottomBar) {
//							TextField("Enter message", text: $text)
//								.textFieldStyle(.plain)
//								.focused($isTextFieldFocused)
//								.onSubmit { sendMessage() }
//						}
//						ToolbarItem(placement: .bottomBar) {
//							Button {
//								sendMessage()
//							} label: {
//								Text("Send")
//									.padding()
//							}
//
//							.buttonStyle(.glassProminent)
//							.disabled(
//								text.isEmpty || session?.isResponding == true || session == nil
//							)
//						}
				// #else
//
//
//
				// #endif

//					}

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

#if !os(iOS)
					.scrollEdgeEffectStyle(.soft, for: .all)
					.padding(.horizontal)
					.navigationTitle("Device Chat")
#endif // !os(iOS)
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

		session = LanguageModelSession(instructions: instructions)
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
				let stream = session.streamResponse(to: prompt)

				// Stream the response and update the UI in real-time
				for try await partialResponse in stream {
					await MainActor.run {
						conversation[aiMessageIndex] = (
							false,
							partialResponse.content
						)
					}
				}

			} catch {
				await MainActor.run {
					conversation[aiMessageIndex] = (false, "Sorry, I encountered an error:\n\n\(error.localizedDescription)")
				}
			}
		}
	}
}

#Preview {
	ChatTab()
}
