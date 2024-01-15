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
    @State private var isDupAlert = false

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
            print("***** AddEditTextView.onAppear()  Called for text: '\(String(describing: text.title))'")
            text.copy(from: storedText)
        }
        .alert(isPresented: $isDupAlert) {
            Alert(title: Text("Duplicate"), message: Text("There is already a text entitled: \(text.title)"), dismissButton: .cancel())
        }
    }
    
    private func handleCancel() {
        if isNew {
            modelContext.delete(storedText)
        }
        dismiss()
    }

    private func handleSave() {
        let newTitle = text.title  // Can't use another model in the definition of the predicate
        let fetchDescriptor = FetchDescriptor<MemoryText>(predicate: #Predicate { $0.title == newTitle })
        let foundTexts = try? modelContext.fetch(fetchDescriptor)
        guard foundTexts?.isEmpty ?? true else {
            isDupAlert = true
            return
        }
        storedText.copy(from: text)
        dismiss()
    }
}
