//
//  DictationViewModel.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/28/23.
//

import AVFoundation
import SwiftUI

@MainActor
@Observable
class DictationViewModel: NSObject {
    private(set) var masterText: MemoryText
    private var candidateText = ""
    var displayText = AttributedString("")
    private let textComparator = TextComparator()
    let speechRecognizer: SpeechRecognizer
    private var transcripts = [String]()
    private var lastTranscript = ""
    private var lastTranscriptSize = 0
    

    init(text: MemoryText, speechRecognizer: SpeechRecognizer) {
        self.masterText = text
        self.speechRecognizer = speechRecognizer
        super.init()
        // TODO: Do these need to be MainActor?
        observeIsTranscribing()
        observeTranscriptUpdates()
    }
    
    /// Observe, and capture changes to the speech recognizer's transcript, and update the displayed text accordingly.
    /// Whenever there is a momentary pause in speech, the speech recognizer will typically publish the transcript with a startTimeStamp, then clear out the transcript, and continue on.
    /// Sometimes, it doesn't publish the transcript with the startTimeStamp, however.  Therefore, there is also logic to look for a significant decrease in the size of the transcript from
    /// one update to the next, and if so, capture the otherwise "lost" transcript.
    @MainActor
    func observeTranscriptUpdates() {
        withObservationTracking {
//            print("***** MemoryTextViewModel.observeTranscriptUpdates()  New transcript = \(speechRecognizer.transcript.transcript)")
            guard speechRecognizer.isTranscribing else { return }
            if speechRecognizer.transcript.startTimeStamp != nil {
                transcripts.append(speechRecognizer.transcript.transcript)
                lastTranscript = ""
                lastTranscriptSize = 0
            } else {
                if (lastTranscriptSize - speechRecognizer.transcript.transcript.count) > 25 {
                    transcripts.append(lastTranscript)
                }
                var fullTranscript = ""
                transcripts.forEach { fullTranscript += ($0 + "\n") }
                fullTranscript += speechRecognizer.transcript.transcript
                candidateText = fullTranscript
                displayText = AttributedString(candidateText)
                lastTranscript = speechRecognizer.transcript.transcript
                lastTranscriptSize = lastTranscript.count
            }
        } onChange: {
//            print("***** MemoryTextViewModel.observeTranscriptUpdates()  onChange called")
            Task { [weak self] in
                await self?.observeTranscriptUpdates()
            }
        }
    }

    @MainActor
    func observeIsTranscribing() {
        withObservationTracking {
//            print("***** MemoryTextViewModel.observeIsTranscribing()  New value = \(speechRecognizer.isTranscribing)")
            guard !speechRecognizer.isTranscribing else { return }
            lastTranscript = ""
            lastTranscriptSize = 0
            evaluateText()
        } onChange: {
//            print("***** MemoryTextViewModel.observeIsTranscribing()  onChange called")
            Task { [weak self] in
                await self?.observeIsTranscribing()
            }
        }
    }
    
    @MainActor
    func handleSpokenInput() {
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
    }
    
    @MainActor
    func clearText() {
        transcripts = []
        displayText = ""
    }
    
    @MainActor
    func stopListening() {
        speechRecognizer.stopTranscribing()
    }
    
    /// Evaluate the candidate text, comparing it to the master text.  Display an appropriately highlighted text result.
    func evaluateText() {
        guard !candidateText.isEmpty else { return }
        transcripts = [candidateText]
        Task {
            displayText = await textComparator.compare(master: masterText.text, candidate: candidateText)
        }
    }
    
    @MainActor
    var dictationButtonTitle: String {
        if speechRecognizer.isTranscribing {
            return "Stop Dictation"
        } else if displayText.unicodeScalars.isEmpty {
            return "Start Dictation"
        } else {
            return "Continue Dictation"
        }
        
    }
}
