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
            print("***** AddEditTextView.onAppear()  Called for text: '\(String(describing: text.title))'")
            text.copy(from: storedText)
        }
    }
    
    private func handleCancel() {
        if isNew {
            modelContext.delete(storedText)
        }
        dismiss()
    }

    private func handleSave() {
        storedText.copy(from: text)
        dismiss()
    }
}
