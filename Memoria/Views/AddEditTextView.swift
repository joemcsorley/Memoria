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
    @Bindable var vm: AddEditViewModel
    @State private var text = MemoryText()

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
                Button(action: { vm.handleCancel() }) {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { vm.handleSave(text) }) {
                    Text("Save")
                }
            }
        }
        .onAppear {
            text.copy(from: vm.textToEdit)
        }
        .modalPresenting(using: vm, navCoordinator: navCoordinator)
    }
}
