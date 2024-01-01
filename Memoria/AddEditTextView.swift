//
//  AddEditTextView.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/28/23.
//

import SwiftUI
import SwiftData

struct AddEditTextView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var vm: AddEditTextViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Date added: \(vm.text.dateAdded, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                Spacer()
            }
            .padding(.bottom, 8)
            
            TextField("Title", text: $vm.text.title)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.bottom, 8)
            
            TextEditor(text: $vm.text.text)
                .scrollContentBackground(.hidden)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
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
            vm.originalText = MemoryText(title: vm.text.title, text: vm.text.text)
            if vm.isNew {
                vm.text.title = ""
                vm.text.text = ""
                vm.text.dateAdded = Date()
            }
        }
    }

    private func handleCancel() {
        if let originalText = vm.originalText, !vm.isNew {
            vm.text.title = originalText.title
            vm.text.text = originalText.text
        }
        dismiss()
    }

    private func handleSave() {
        if vm.isNew {
            modelContext.insert(vm.text)
        }
        dismiss()
    }
}

class AddEditTextViewModel: ObservableObject {
    @Bindable var text: MemoryText
    var originalText: MemoryText?
    var isNew = false
    
    init(_ text: MemoryText? = nil) {
        self.text = text ?? MemoryText(title: "", text: "")
        self.isNew = (text == nil)
    }
}
