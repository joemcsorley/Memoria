//
//  DictationView.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/28/23.
//

import SwiftUI

struct DictationView: View {
    @Environment(NavigationCoordinator<AppScreens>.self) var navCoordinator
    @Bindable var vm: DictationViewModel
    @State private var isRecordingPulse = false
    let scrollTopId = "DictationScrollTop"

    var body: some View {
        ZStack {
            Color.codexBg.ignoresSafeArea()

            VStack(spacing: 0) {
                customNavBar

                VStack(spacing: 14) {
                    scrollableText
                    dictationButton
                }
                .padding(16)
                .padding(.bottom, 8)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: vm.speechRecognizer.isTranscribing) { _, isTranscribing in
            if isTranscribing {
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    isRecordingPulse = true
                }
            } else {
                withAnimation(.easeOut(duration: 0.3)) {
                    isRecordingPulse = false
                }
            }
        }
    }

    // MARK: - Sub-views

    private var customNavBar: some View {
        HStack {
            Button {
                navCoordinator.pop()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Texts")
                        .font(.system(size: 17))
                }
                .foregroundStyle(Color.codexAccent)
            }

            Spacer()

            Text(vm.masterText.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.codexLabel)
                .lineLimit(1)
                .truncationMode(.middle)
                .padding(.horizontal, 24)

            Spacer()

            HStack(spacing: 16) {
                if !vm.displayText.unicodeScalars.isEmpty {
                    Button("Clear") { vm.clearText() }
                        .font(.system(size: 17))
                        .foregroundStyle(Color.codexSecondary)
                }
                Button("Edit") {
                    navCoordinator.push(.addEditText(vm.masterText, false))
                }
                .font(.system(size: 17))
                .foregroundStyle(Color.codexAccent)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.codexBorder)
                .frame(height: 0.5)
        }
    }

    private var scrollableText: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Text(vm.displayText)
                    .font(.system(size: 17))
                    .lineSpacing(6)
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .id(scrollTopId)
            }
            .background(Color.codexSurface2)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .onChange(of: vm.displayText) {
                if vm.speechRecognizer.isTranscribing {
                    proxy.scrollTo(scrollTopId, anchor: .bottom)
                } else {
                    proxy.scrollTo(scrollTopId, anchor: .top)
                }
            }
        }
    }

    private var dictationButton: some View {
        let isRecording = vm.speechRecognizer.isTranscribing

        return Button(action: handleDictationButtonTap) {
            HStack(spacing: 10) {
                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 16))
                Text(vm.dictationButtonTitle)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isRecording ? Color.codexRecord : Color.codexAccent)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .scaleEffect(isRecordingPulse ? 1.013 : 1.0)
            .shadow(
                color: isRecording ? Color.codexRecord.opacity(isRecordingPulse ? 0 : 0.4) : .clear,
                radius: isRecordingPulse ? 14 : 4
            )
        }
    }

    // MARK: - Actions

    @MainActor
    private func handleDictationButtonTap() {
        if vm.speechRecognizer.isTranscribing {
            vm.stopListening()
        } else {
            vm.handleSpokenInput()
        }
    }
}

#Preview {
    let navCoordinator = NavigationCoordinator<AppScreens>()
    let text = MemoryText(title: "Sample Text", text: "This is a sentence of sample text for the preview.")
    DictationView(vm: DictationViewModel(navCoordinator: navCoordinator, text: text, speechRecognizer: SpeechRecognizer()))
        .modelContainer(for: MemoryText.self, inMemory: true)
        .environment(navCoordinator)
}
