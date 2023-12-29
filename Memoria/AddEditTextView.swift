//
//  AddEditTextView.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/28/23.
//

import SwiftUI
import SwiftData

struct AddEditTextView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var text: MemoryText
    
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
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.bottom, 8)
            
            TextEditor(text: $text.text)
                .scrollContentBackground(.hidden)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .navigationTitle("Edit")
    }
}
