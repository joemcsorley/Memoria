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

    var body: some View {
        NavigationStack {
            List {
                ForEach(texts) { text in
                    NavigationLink {
                        let speechRecognizer = SpeechRecognizer()
                        let memoryTextViewModel = MemoryTextViewModel(text: text, speechRecognizer: speechRecognizer)
                        MemoryTextView(memoryTextViewModel, speechRecognizer: speechRecognizer)
                    } label: {
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
        }
    }

    private func addNewRow() {
        withAnimation {
            let newText = MemoryText(title: "", text: "")
            modelContext.insert(newText)
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
