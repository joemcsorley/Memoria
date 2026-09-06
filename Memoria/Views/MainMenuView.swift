//
//  MainMenuView.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/27/23.
//

import SwiftUI

struct MainMenuView: View {
    @Environment(NavigationCoordinator<AppScreens>.self) var navCoordinator
    @Bindable var vm: MainMenuViewModel
    @State private var editMode: EditMode = .inactive

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.codexBg.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                    .padding(.bottom, 16)

                if vm.texts.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(vm.texts) { text in
                            TextRowCard(title: text.title) {
                                navCoordinator.push(.dictation(text))
                            }
                            .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        .onMove(perform: moveRows)
                        .onDelete(perform: deleteRows)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .environment(\.editMode, $editMode)
                }
            }

            fabButton
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { vm.refreshTexts() }
        .modalPresenting(using: vm, navCoordinator: navCoordinator)
    }

    // MARK: - Sub-views

    private var headerView: some View {
        HStack(alignment: .bottom, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Memoria")
                    .font(.system(size: 34, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.codexLabel)
            }

            Spacer()

            if !vm.texts.isEmpty {
                Button(editMode == .active ? "Done" : "Edit") {
                    withAnimation {
                        editMode = editMode == .active ? .inactive : .active
                    }
                }
                .font(.system(size: 17))
                .foregroundStyle(Color.codexAccent)
                .padding(.bottom, 6)
                .padding(.trailing, 16)
            }

            Button { vm.presentModal(.help) } label: {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.codexAccent)
            }
            .padding(.bottom, 6)
        }
        .padding(.horizontal, 22)
        .padding(.top, 18)
        .padding(.bottom, 14)
    }

    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "book.pages")
                .font(.system(size: 54))
                .foregroundStyle(Color.codexTertiary)
            Text("No texts yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.codexLabel)
            Text("Add a passage to start\npracticing your memorization.")
                .font(.system(size: 15))
                .foregroundStyle(Color.codexSecondary)
                .multilineTextAlignment(.center)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var fabButton: some View {
        Button(action: addNewRow) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.codexAccent)
                .clipShape(Circle())
                .shadow(color: Color.codexAccent.opacity(0.4), radius: 12, x: 0, y: 4)
        }
        .padding(.trailing, 24)
        .padding(.bottom, 24)
    }

    // MARK: - Actions

    private func addNewRow() {
        withAnimation {
            let newText = vm.addNewEmptyText()
            navCoordinator.push(.addEditText(newText, true))
        }
    }

    private func moveRows(source: IndexSet, destination: Int) {
        vm.reorderTexts(source: source, destination: destination)
    }

    private func deleteRows(offsets: IndexSet) {
        withAnimation {
            vm.deleteTexts(offsets: offsets)
        }
    }
}

// MARK: - Row card

private struct TextRowCard: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                Color.codexAccent
                    .frame(width: 4.5)

                HStack {
                    Text(title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.codexLabel)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.codexTertiary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color.codexSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.codexBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let navCoordinator = NavigationCoordinator<AppScreens>()
    MainMenuView(vm: MainMenuViewModel(navCoordinator: navCoordinator))
        .modelContainer(for: MemoryText.self, inMemory: true)
        .environment(navCoordinator)
}
