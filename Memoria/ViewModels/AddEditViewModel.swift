//
//  AddEditViewModel.swift
//  Memoria
//
//  Created by Joseph McSorley on 8/16/26.
//

import SwiftUI

@MainActor @Observable
class AddEditViewModel: ModalPresenter<AppScreens> {
    private(set) var textToEdit: MemoryText
    private(set) var isNew: Bool
    
    init(navCoordinator: NavigationCoordinator<AppScreens>, text: MemoryText, isNew: Bool) {
        self.textToEdit = text
        self.isNew = isNew
        super.init(navCoordinator: navCoordinator)
    }
    
    func handleCancel() {
        if isNew {
            dataStores.memoryTextStore.delete([textToEdit])
        }
        navCoordinator.pop()
    }

    func handleSave(_ text: MemoryText) {
        textToEdit.copy(from: text)
        dataStores.save()
        navCoordinator.pop()
    }
}
