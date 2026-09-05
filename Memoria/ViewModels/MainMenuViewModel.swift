//
//  MainMenuViewModel.swift
//  Memoria
//
//  Created by Joseph McSorley on 8/16/26.
//

import SwiftUI

@MainActor @Observable
class MainMenuViewModel: ModalPresenter<AppScreens> {
    var texts: [MemoryText]

    override init(navCoordinator: NavigationCoordinator<AppScreens>) {
        self.texts = []
        super.init(navCoordinator: navCoordinator)
    }
    
    func refreshTexts() {
        texts = dataStores.memoryTextStore.texts
    }
    
    func addNewEmptyText() -> MemoryText {
        let newText = MemoryText(title: "", text: "")
        newText.displayOrder = texts.count + 1
        dataStores.memoryTextStore.add(newText)
        refreshTexts()
        return newText
    }
    
    func deleteTexts(offsets: IndexSet) {
        var textsToDelete = [MemoryText]()
        for index in offsets {
            textsToDelete.append(texts[index])
        }
        dataStores.memoryTextStore.delete(textsToDelete)
        refreshTexts()
    }
    
    func reorderTexts(source: IndexSet, destination: Int) {
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
        dataStores.save()
        refreshTexts()
    }
}
