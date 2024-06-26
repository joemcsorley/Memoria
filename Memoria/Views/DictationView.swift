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
    let scrollTopId = "MemoryTextViewScrollBottom"
    let scrollBottomId = "MemoryTextViewScrollBottom"
    
    var body: some View {
        @Bindable var speechRecognizer = vm.speechRecognizer
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    Text(vm.displayText)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .id(scrollTopId)
                    Spacer().id(scrollBottomId)
                }
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onChange(of: vm.displayText) {
                    if speechRecognizer.isTranscribing {
                        scrollViewProxy.scrollTo(scrollBottomId)
                    } else {
                        scrollViewProxy.scrollTo(scrollTopId, anchor: .top)
                    }
                }
            }
            Button(action: { handleDictationButtonTap() }) {
                Text(vm.dictationButtonTitle)
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(speechRecognizer.isTranscribing ? Color.red : Color.green)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.top, 12)
        }
        .padding()
        .navigationTitle(vm.masterText.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { navCoordinator.push(.addEditText(vm.masterText, false)) }) {
                    Text("Edit")
                }
            }
            ToolbarItem {
                Button(action: { vm.clearText() }) {
                    Text("Clear")
                }
            }
        }
    }
    
    // MARK: - Helpers

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
    let text = MemoryText(title: "Sample Text", text: "This is a sentence of sample text for the preview.")
    return DictationView(vm: DictationViewModel(text: text, speechRecognizer: SpeechRecognizer()))
}

