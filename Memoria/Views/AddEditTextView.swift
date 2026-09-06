//
//  AddEditTextView.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/28/23.
//

import SwiftUI

struct AddEditTextView: View {
    @Environment(NavigationCoordinator<AppScreens>.self) var navCoordinator
    @Bindable var vm: AddEditViewModel
    @State private var text = MemoryText()
    @FocusState private var focusedField: Field?

    private enum Field { case title, body }

    var body: some View {
        ZStack {
            Color.codexBg.ignoresSafeArea()

            VStack(spacing: 0) {
                customNavBar

                VStack(alignment: .leading, spacing: 16) {
                    titleField
                    bodyEditor
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            text.copy(from: vm.textToEdit)
        }
        .modalPresenting(using: vm, navCoordinator: navCoordinator)
    }

    // MARK: - Sub-views

    private var customNavBar: some View {
        HStack {
            Button("Cancel") { vm.handleCancel() }
                .font(.system(size: 17))
                .foregroundStyle(Color.codexAccent)

            Spacer()

            Text(vm.isNew ? "New Text" : "Editing")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.codexLabel)

            Spacer()

            Button { vm.handleSave(text) } label: {
                Text("Save")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.codexAccent)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.codexBorder)
                .frame(height: 0.5)
        }
    }

    private var titleField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Added \(text.dateAdded.formatted(.dateTime.month(.wide).day().year()))")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.codexTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)

            TextField("", text: $text.title, prompt: Text("Untitled").foregroundStyle(Color.codexTertiary))
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.codexLabel)
                .disableAutocorrection(true)
                .focused($focusedField, equals: .title)
                .padding(.bottom, 10)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.codexBorder)
                        .frame(height: 1.5)
                }
        }
    }

    private var bodyEditor: some View {
        TextEditor(text: $text.text)
            .font(.system(size: 16))
            .foregroundStyle(Color.codexLabel)
            .lineSpacing(5)
            .disableAutocorrection(true)
            .scrollContentBackground(.hidden)
            .focused($focusedField, equals: .body)
            .padding(16)
            .background(Color.codexSurface2)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .frame(maxHeight: .infinity)
    }
}
