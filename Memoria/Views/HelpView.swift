//
//  HelpView.swift
//  Memoria
//
//  Created by Joseph McSorley on 1/5/24.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.codexBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Done button row
                HStack {
                    Spacer()
                    Button("Done") { dismiss() }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.codexAccent)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                }

                ScrollView {
                    VStack(spacing: 0) {
                        // Hero
                        VStack(spacing: 8) {
                            Text("Memoria")
                                .font(.system(size: 42, weight: .semibold, design: .serif))
                                .foregroundStyle(Color.codexAccent)
                            Text("Master anything you want to remember.")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.codexSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 16)
                        .padding(.bottom, 24)

                        // Step cards
                        VStack(spacing: 12) {
                            StepCard(
                                systemImage: "plus",
                                title: "Add your text",
                                description: "Paste any passage you want to memorize and give it a title."
                            )

                            StepCard(
                                systemImage: "mic.fill",
                                title: "Speak it aloud",
                                description: "Tap **Begin Dictation** and recite what you remember. Speak naturally."
                            )

                            StepCard(
                                systemImage: "chart.line.uptrend.xyaxis",
                                title: "Read the feedback",
                                description: "Each word is color-coded after you finish."
                            ) {
                                HStack(spacing: 6) {
                                    ColorChip(label: "Correct", foreground: .codexCorrect, background: .codexCorrectBg)
                                    ColorChip(label: "Missed",  foreground: .codexMissed,  background: .codexMissedBg)
                                    ColorChip(label: "Extra",   foreground: .codexExtra,   background: .codexExtraBg)
                                }
                                .padding(.top, 6)
                            }
                        }
                        .padding(.horizontal, 18)

                        // Footer
                        Text("Practice repeatedly to see your memory improve over time.")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.codexTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                            .padding(.top, 28)
                            .padding(.bottom, 40)
                    }
                }
            }
        }
    }
}

// MARK: - Step card

private struct StepCard<Legend: View>: View {
    let systemImage: String
    let title: String
    let description: String
    @ViewBuilder var legend: Legend

    init(systemImage: String,
         title: String,
         description: String,
         @ViewBuilder legend: () -> Legend = { EmptyView() }) {
        self.systemImage = systemImage
        self.title = title
        self.description = description
        self.legend = legend()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon well
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.codexAccentTint)
                    .frame(width: 46, height: 46)
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.codexAccent)
            }
            .padding(.top, 1)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.codexLabel)
                Text(LocalizedStringKey(description))
                    .font(.system(size: 13.5))
                    .foregroundStyle(Color.codexSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                legend
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.codexSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.codexBorder, lineWidth: 1)
        )
    }
}

// MARK: - Color chip

private struct ColorChip: View {
    let label: String
    let foreground: Color
    let background: Color

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(foreground)
                .frame(width: 7, height: 7)
            Text(label)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundStyle(foreground)
        .padding(.vertical, 3)
        .padding(.horizontal, 9)
        .background(background)
        .clipShape(Capsule())
    }
}

#Preview {
    HelpView()
}
