//
//  MainMenuView.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/27/23.
//

import SwiftUI

struct MainMenuView: View {
    @Environment(NavigationCoordinator<AppScreens>.self) var navCoordinator
    @Bindable var vm: MainMenuViewModel

    var body: some View {
        List {
            ForEach(vm.texts) { text in
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
        .onAppear {
            vm.refreshTexts()
        }
        .modalPresenting(using: vm, navCoordinator: navCoordinator)
    }

    private func addNewRow() {
        withAnimation {
            let newText = vm.addNewEmptyText()
            navCoordinator.push(.addEditText(newText, true))
        }
    }

    private func moveRows(source: IndexSet, destination: Int) {
        vm.reorderTexts(source: source, destination: destination)
    }
    
    private func deleteRows(offsets: IndexSet) {
        withAnimation {
            vm.deleteTexts(offsets: offsets)
        }
    }
}

#Preview {
    let navCoordinator = NavigationCoordinator<AppScreens>()
    MainMenuView(vm: MainMenuViewModel(navCoordinator: navCoordinator))
        .modelContainer(for: MemoryText.self, inMemory: true)
        .environment(navCoordinator)
}
