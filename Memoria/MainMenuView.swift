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
    @Query(sort: \MemoryText.displayOrder) private var texts: [MemoryText]
    @State private var newText = MemoryText(title: "", text: "")
    @State private var isAddEditTextViewPresented = false
    @State private var isHelpViewPresented = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(texts) { text in
                    NavigationLink(value: text) {
                        Text(text.title)
//                        Text("\(text.displayOrder) \(text.title)")
                    }
                }
                .onMove(perform: moveRows)
                .onDelete(perform: deleteRows)
            }
            .navigationTitle("Texts")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isHelpViewPresented.toggle() }) {
                        Image(systemName: "questionmark.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addNewRow) {
                        Label("Add Text", systemImage: "plus")
                    }
                }
            }
            .onAppear {
                print("***** MainMenuView.onAppear()  Called")
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
            .sheet(isPresented: $isHelpViewPresented) {
                HelpView()
            }
        }
    }

    private func reorderRows() {
        
    }
    
    private func addNewRow() {
        withAnimation {
            newText = MemoryText(title: "", text: "")
            modelContext.insert(newText)
            var i = 1
            texts.forEach {
                $0.displayOrder = i
                i += 1
            }
            isAddEditTextViewPresented = true
        }
    }

    private func moveRows(source: IndexSet, destination: Int) {
        guard let sourceIndex = source.first else { return }
        if sourceIndex < destination {
            texts[safe: sourceIndex]?.displayOrder = texts[safe: destination-1]?.displayOrder ?? destination
            for i in (sourceIndex+1)..<destination {
                texts[safe: i]?.displayOrder -= 1
            }
        } else {
            texts[safe: sourceIndex]?.displayOrder = texts[safe: destination]?.displayOrder ?? destination+1
            for i in destination..<sourceIndex {
                texts[safe: i]?.displayOrder += 1
            }
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
