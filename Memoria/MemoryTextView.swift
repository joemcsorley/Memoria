//
//  MemoryTextView.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/28/23.
//

import SwiftUI

struct MemoryTextView: View {
    @ObservedObject private var speechRecognizer: SpeechRecognizer
    @ObservedObject private var vm: MemoryTextViewModel
    @State private var isShowingEditView = false
    
    init(_ vm: MemoryTextViewModel, speechRecognizer: SpeechRecognizer) {
        self.vm = vm
        self.speechRecognizer = speechRecognizer
        print("***** MemoryTextView.init()  Called")
    }
    
    var body: some View {
        VStack {
            ScrollView {
                Text(vm.displayText)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            Spacer()
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
            print("***** MemoryTextView.onAppear()  Called")
        }
    }
    
    // MARK: - Helpers

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

