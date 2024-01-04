//
//  ContentView.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/27/23.
//

import SwiftUI
import SwiftData

struct MainMenuView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var texts: [MemoryText]
    @State private var newText = MemoryText(title: "", text: "")
    @State private var isAddEditTextViewPresented = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(texts) { text in
                    NavigationLink(value: text) {
                        Text(text.title)
                    }
                }
                .onDelete(perform: deleteRows)
            }
            .navigationTitle("Texts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addNewRow) {
                        Label("Add Text", systemImage: "plus")
                    }
                }
            }
            .navigationDestination(for: MemoryText.self) { text in
                let speechRecognizer = SpeechRecognizer()
                let memoryTextViewModel = MemoryTextViewModel(text: text, speechRecognizer: speechRecognizer)
                MemoryTextView(memoryTextViewModel, speechRecognizer: speechRecognizer)
//                LazyWrapperView(MemoryTextView(memoryTextViewModel, speechRecognizer: speechRecognizer))
            }
            .navigationDestination(isPresented: $isAddEditTextViewPresented) {
                AddEditTextView(storedText: newText, isNew: true)
//                LazyWrapperView(AddEditTextView(vm: AddEditTextViewModel()))
            }
        }
    }

    private func addNewRow() {
        withAnimation {
            newText = MemoryText(title: "", text: "")
            modelContext.insert(newText)
            isAddEditTextViewPresented = true
        }
    }

    private func deleteRows(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(texts[index])
            }
        }
    }
}

#Preview {
    MainMenuView()
        .modelContainer(for: MemoryText.self, inMemory: true)
}
