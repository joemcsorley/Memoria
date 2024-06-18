//
//  AppScreens.swift
//  Veritask
//
//  Created by Joseph McSorley on 6/18/24.
//

import SwiftUI

indirect enum AppScreens: NavigationScreenDefinition {
    case mainMenu
    case dictation(MemoryText)
    case addEditText(MemoryText, Bool)
    case help
    
    static let root = AppScreens.mainMenu
    
    @ViewBuilder
    func screenView(navCoordinator: NavigationCoordinator<Self>) -> some View {
        switch self {
        case .mainMenu:
            mainMenuView(navCoordinator: navCoordinator)
        case .dictation(let memoryText):
            dictationView(memoryText: memoryText, navCoordinator: navCoordinator)
        case .addEditText(let memoryText, let isNew):
            addEditTextView(memoryText: memoryText, isNew: isNew, navCoordinator: navCoordinator)
        case .help:
            HelpView()
        }
    }

    private func mainMenuView(navCoordinator: NavigationCoordinator<Self>) -> some View {
        let vm = navCoordinator.observable(for: self, default: MainMenuViewModel())
        return MainMenuView(vm: vm)
    }

    private func dictationView(memoryText: MemoryText, navCoordinator: NavigationCoordinator<Self>) -> some View {
        let speechRecognizer = SpeechRecognizer()
        let vm = navCoordinator.observable(for: self, default: DictationViewModel(text: memoryText, speechRecognizer: speechRecognizer))
        return DictationView(vm: vm)
    }
    
    private func addEditTextView(memoryText: MemoryText, isNew: Bool, navCoordinator: NavigationCoordinator<Self>) -> some View {
        let vm = navCoordinator.observable(for: self, default: AddEditViewModel())
        return AddEditTextView(vm: vm, storedText: memoryText, isNew: isNew)
    }
}
