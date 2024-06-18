//
//  AddEditTextView.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/28/23.
//

import SwiftUI
import SwiftData

struct AddEditTextView: View {
    @Environment(NavigationCoordinator<AppScreens>.self) var navCoordinator
    @Environment(\.modelContext) private var modelContext
    @Bindable var vm: AddEditViewModel
    @Bindable var storedText: MemoryText
    @State private var text = MemoryText()
    @State var isNew = false

    var body: some View {
        VStack {
            HStack {
                Text("Date added: \(text.dateAdded, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                Spacer()
            }
            .padding(.bottom, 8)
            
            TextField("Title", text: $text.title)
                .disableAutocorrection(true)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.bottom, 8)
            
            TextEditor(text: $text.text)
                .disableAutocorrection(true)
                .scrollContentBackground(.hidden)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { handleCancel() }) {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { handleSave() }) {
                    Text("Save")
                }
            }
        }
        .onAppear {
            text.copy(from: storedText)
        }
        .modalPresenting(using: vm, navCoordinator: navCoordinator)
    }
    
    private func handleCancel() {
        if isNew {
            modelContext.delete(storedText)
        }
        navCoordinator.pop()
    }

    private func handleSave() {
        if isNew {
            let newTitle = text.title  // Can't use another model in the definition of the predicate
            let fetchDescriptor = FetchDescriptor<MemoryText>(predicate: #Predicate { $0.title == newTitle })
            let foundTexts = try? modelContext.fetch(fetchDescriptor)
            guard foundTexts?.isEmpty ?? true else {
                vm.presentAlert(AlertViewComponents(title: "Duplicate",
                                                    message: "There is already a text entitled: \(text.title)",
                                                    buttons: [AlertButton(id: 1, title: "Ok", role: .cancel)]))
                return
            }
        }
        storedText.copy(from: text)
        navCoordinator.pop()
    }
}

class AddEditViewModel: ModalPresenter<AppScreens> {}
