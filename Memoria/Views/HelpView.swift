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
        VStack {
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Text("Done")
                }
                .padding()
            }
            ScrollView {
                helpText
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
        }
    }
    
    private var helpText: some View {
        Text("Memoria ").font(.largeTitle).foregroundStyle(Color.orange) +
        Text("will help you memorize texts by allowing you to speak them out loud, then reporting your accuracy.\n\n") +
        Text("Start by adding texts you wish to memorize.  Tap the ") +
        Text("\(Image(systemName: "plus"))").foregroundStyle(Color.blue) +
        Text(" button, then enter a title for the text, and the text itself.\n") +
        Text("Hint: You can copy texts from other sources, and simply paste them into Memoria.\n\n").font(.footnote).foregroundStyle(Color.gray) +
        Text("Once your text is entered, then tap on it from the main menu. This will take you to the dictation screen, where you can begin speaking!\n\n") +
        Text("When you're done speaking the text, Memoria will display the original text with highlights:\n") +
        Text("• Green").foregroundStyle(Color.green) + 
        Text(": Words you spoke correctly.\n") +
        Text("• Red").foregroundStyle(Color.red) +
        Text(": Words you missed.\n") +
        Text("• Amber").foregroundStyle(Color.orange) +
        Text(": Words you spoke that were not in the original text.")
    }
}

#Preview {
    HelpView()
}
