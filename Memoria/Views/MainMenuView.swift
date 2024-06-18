//
//  ContentView.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/27/23.
//

import SwiftUI
import SwiftData

struct MainMenuView: View {
    @Environment(NavigationCoordinator<AppScreens>.self) var navCoordinator
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MemoryText.displayOrder) private var texts: [MemoryText]
    @Bindable var vm: MainMenuViewModel
    @State private var newText = MemoryText(title: "", text: "")

    var body: some View {
        List {
            ForEach(texts) { text in
                Button(action: { navCoordinator.push(.dictation(text)) }) {
                    Text(text.title)
                }
            }
            .onMove(perform: moveRows)
            .onDelete(perform: deleteRows)
        }
        .navigationTitle("Texts")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { vm.presentModal(.help) }) {
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
        .modalPresenting(using: vm, navCoordinator: navCoordinator)
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
            navCoordinator.push(.addEditText(newText, true))
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

@Observable
class MainMenuViewModel: ModalPresenter<AppScreens> {}

#Preview {
//    let navCoordinator = NavigationCoordinator<AppScreens>()
    MainMenuView(vm: MainMenuViewModel())
        .modelContainer(for: MemoryText.self, inMemory: true)
//        .environment(navCoordinator)
}
