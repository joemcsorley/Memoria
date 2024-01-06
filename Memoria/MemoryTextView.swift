//
//  MemoryTextView.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/28/23.
//

import SwiftUI

struct MemoryTextView: View {
    @State private var speechRecognizer: SpeechRecognizer
    @State private var vm: MemoryTextViewModel
    @State private var isShowingEditView = false
    let scrollTopId = "MemoryTextViewScrollBottom"
    let scrollBottomId = "MemoryTextViewScrollBottom"
    
    init(_ vm: MemoryTextViewModel, speechRecognizer: SpeechRecognizer) {
        self.vm = vm
        self.speechRecognizer = speechRecognizer
//        print("***** MemoryTextView.init()  Called")
    }
    
    var body: some View {
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
                Button(action: { isShowingEditView = true }) {
                    NavigationLink {
                        AddEditTextView(storedText: vm.masterText)
//                        LazyWrapperView(AddEditTextView(storedText: vm.masterText))
                    } label: {
                        Text("Edit")
                    }
                }
            }
            ToolbarItem {
                Button(action: { vm.clearText() }) {
                    Text("Clear")
                }
            }
        }
        .onAppear {
//            print("***** MemoryTextView.onAppear()  Called")
        }
    }
    
    // MARK: - Helpers

    @MainActor
    private func handleDictationButtonTap() {
        if speechRecognizer.isTranscribing {
            vm.stopListening()
        } else {
            vm.handleSpokenInput()
        }
    }
}

#Preview {
    let text = MemoryText(title: "Sample Text", text: "This is a sentence of sample text for the preview.")
    return MemoryTextView(MemoryTextViewModel(text: text, speechRecognizer: SpeechRecognizer()), speechRecognizer: SpeechRecognizer())
}

