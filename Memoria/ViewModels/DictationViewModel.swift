//
//  DictationViewModel.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/28/23.
//

import AVFoundation
import Combine
import SwiftUI

typealias MatchInfo = (masterStartIndex: Int, consecutiveMatches: Int)

/// This class is largely responsible for comparing the spoken (candidate) text to the master text for accuracy.  The strategy is this:
/// 1. Tokenize both texts into a series of words (without spaces or punctuation, keeping track of each word's index location in the original text).
/// 2. Start by matching series' of (6 or more) words between the two texts.
/// 3. Go through the remaining unmatched portions looking for a series of 5 matching words (then 4, 3, 2, 1).
/// 4. Once all of the ranges of matching, and non-matching words are identified between the two texts, then display the original master text, highlighted appropriately:
///    a. Green means the words match - the correct words were spoken.
///    b. Red indicates words in the master text that were missed (not spoken).
///    c. Orange indicates spoken words that were not in the master text.
@Observable
class DictationViewModel: NSObject {
    private(set) var masterText: MemoryText
    var displayText = AttributedString("")
    let speechRecognizer: SpeechRecognizer
    private var spokenInputCancellables = Set<AnyCancellable>()
    private var masterTokens = [Token]()
    private var candidateTokens = [Token]()
    private var transcripts = [String]()
    private var lastTranscript = ""
    private var lastTranscriptSize = 0
    

    init(text: MemoryText, speechRecognizer: SpeechRecognizer) {
        self.masterText = text
        self.speechRecognizer = speechRecognizer
        super.init()
        Task {
            await observeIsTranscribing()
            await observeTranscriptUpdates()
        }
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
                displayText = AttributedString(fullTranscript)
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
    
    /// Starting with a RangePair that encompasses the entirety of both the candidate, and master texts (tokenized), break it into an array of RangePairs where the matching ones have matching sequences of at least 6 tokens.  Then iterate over those RangePairs looking for matching tokens sequences of at least 5 in the remaining non-matching ones.  Then 4, 3, 2, 1, until the resulting array of RangePairs represent as much matched text (tokens) as possible.  Finally, iterate over the master text, using this resulting array of RangePairs to highlight it appropriately.
    func evaluateText() {
        guard !displayText.characters.isEmpty else { return }
        masterTokens = tokenize(AttributedString(masterText.text))
        candidateTokens = tokenize(displayText)
        transcripts = [String(displayText.characters)]

        var rangePairs = [RangePair(masterRange: 0..<masterTokens.count, candidateRange: 0..<candidateTokens.count, isMatched: false)]
        var updatedRangePairs = [RangePair]()
        for minMatches in [6, 5, 4, 3, 2, 1] {
            rangePairs.forEach { rangePair in
                if rangePair.isMatched {
                    updatedRangePairs.append(rangePair)
                } else {
                    updatedRangePairs.append(contentsOf: matchText(in: rangePair, minMatches: minMatches))
                }
            }
            rangePairs = consolidate(rangePairs: updatedRangePairs)
            updatedRangePairs = []
        }
        displayHighlightedText(using: rangePairs)
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
    
    // MARK: - Helpers
    
    private func tokenize(_ str: AttributedString) -> [Token] {
        var tokens = [Token]()
        var startIdx: AttributedString.Index?
        for i in str.characters.indices {
            if str.characters[i].isWhitespace || str.characters[i].isPunctuation {
                if let sIdx = startIdx {
                    // Produce a token representing the current word
                    let tokenValue = String(str.characters[sIdx..<i]).lowercased()
                    tokens.append(Token(value: tokenValue, startIndex: sIdx, endIndex: i))
                    startIdx = nil
                }
            } else {
                if startIdx == nil {
                    // Start capturing the next word
                    startIdx = i
                }
            }
        }
        if let sIdx = startIdx {
            // Capture the last word in the text
            let tokenValue = String(str.characters[sIdx..<str.endIndex]).lowercased()
            tokens.append(Token(value: tokenValue, startIndex: sIdx, endIndex: str.endIndex))
        }
        return tokens
    }
    
    private func match(_ t1: Token, _ t2: Token) -> Bool {
        t1.value == t2.value
    }
    
    /// For candidate tokens starting at the specified index (and ending at the specified index), return the number of matched tokens in the specified masterRange (starting at the first in the range).
    private func consecutiveMatches(for candidateIndex: Int, in masterRange: Range<Int>, candidateEndIndex: Int) -> Int {
        var matches = 0
        var candIdx = candidateIndex
        for mastIdx in masterRange {
            guard candIdx < candidateEndIndex, candidateTokens[candIdx].value == masterTokens[mastIdx].value else { break }
            candIdx += 1
            matches += 1
        }
        return matches
    }
    
    /// For candidate tokens starting at the specified index (and ending at the specified index), search the masterRange for the longest consecutive set of matching tokens.
    private func bestMatch(for candIdx: Int, in masterRange: Range<Int>, candidateEndIndex: Int) -> MatchInfo {
        var bestMatch = MatchInfo(masterRange.startIndex, 0)
        for mastIdx in masterRange {
            let consecutiveMatches = consecutiveMatches(for: candIdx, in: mastIdx..<masterRange.endIndex, candidateEndIndex: candidateEndIndex)
            if consecutiveMatches > bestMatch.consecutiveMatches {
                bestMatch = (mastIdx, consecutiveMatches)
            }
        }
        return bestMatch
    }
    
    /// Find the longest sequences of matching tokens in the candidate and master ranges of the specified RangePair, that are at least as long as minMatches.  Return an array of RangePairs which correspond to all sequences of matching and non-matching tokens.
    private func matchText(in rangePair: RangePair, minMatches: Int) -> [RangePair] {
        guard !rangePair.isMatched, rangePair.masterRange.count >= minMatches, rangePair.candidateRange.count >= minMatches else { return [rangePair] }
        var mastStartIdx = rangePair.masterRange.startIndex
        let mastEndIdx = rangePair.masterRange.endIndex
        var candStartIdx = rangePair.candidateRange.startIndex
        let candEndIdx = rangePair.candidateRange.endIndex
        var rangePairs = [RangePair]()
        var currentRangePair = RangePair(masterRange: mastStartIdx..<mastStartIdx, candidateRange: candStartIdx..<candStartIdx)
        
        var candIdx = candStartIdx
        while candIdx < candEndIdx {
            let bestMatch = bestMatch(for: candIdx, in: mastStartIdx..<mastEndIdx, candidateEndIndex: candEndIdx)
            if bestMatch.consecutiveMatches >= minMatches {
                // Complete the current (unmatched) range pair.
                currentRangePair.complete(masterEndIndex: bestMatch.masterStartIndex, candidateEndIndex: candIdx, isMatched: false)
                rangePairs.append(currentRangePair)
                // Add a (matched) range pair to represent the matched sequences.
                let matchedMasterRange = bestMatch.masterStartIndex..<bestMatch.masterStartIndex + bestMatch.consecutiveMatches
                let matchedCandidateRange = candIdx..<candIdx + bestMatch.consecutiveMatches
                currentRangePair = RangePair(masterRange: matchedMasterRange, candidateRange: matchedCandidateRange, isMatched: true)
                rangePairs.append(currentRangePair)
                // Create a new current range pair for the remaining, as yet unmatched, tokens.
                currentRangePair = RangePair(masterRange: matchedMasterRange.endIndex..<matchedMasterRange.endIndex, candidateRange: matchedCandidateRange.endIndex..<matchedCandidateRange.endIndex, isMatched: false)
                // Update the start indexes to come after the matched sequences.
                mastStartIdx = currentRangePair.masterStartIndex
                candStartIdx = currentRangePair.candidateStartIndex
                candIdx = candStartIdx
            } else {
                candIdx += 1
                // Complete the current (unmatched) range pair containing just the unmatched candidate token.
                currentRangePair.complete(masterEndIndex: mastStartIdx, candidateEndIndex: candIdx, isMatched: false)
                rangePairs.append(currentRangePair)
                // Create a new current range pair for the remaining, as yet unmatched, candidate tokens.
                currentRangePair = RangePair(masterRange: mastStartIdx..<mastStartIdx, candidateRange: candIdx..<candIdx, isMatched: false)
            }
        }
        // Add one last range pair containing the endIndex for both master, and candidate ranges.
        currentRangePair.complete(masterEndIndex: mastEndIdx, candidateEndIndex: candEndIdx, isMatched: false)
        rangePairs.append(currentRangePair)
        return rangePairs
    }
    
    /// Iterate over an array of RangePairs, and if two adjacent RangePairs both either match, or don't match, then consolidate them into one RangePair.  Also, remove any empty RangePairs.  The returned result is an array of RangePairs that alternately ..., match, don't match, match, don't match, etc.
    private func consolidate(rangePairs: [RangePair]) -> [RangePair] {
        var updatedRangePairs = [RangePair]()
        rangePairs.forEach { rangePair in
            guard !(rangePair.masterRange.isEmpty && rangePair.candidateRange.isEmpty) else { return }
            if let prevRangePairIsMatched = updatedRangePairs.last?.isMatched, prevRangePairIsMatched == rangePair.isMatched {
                updatedRangePairs[updatedRangePairs.count-1].complete(masterEndIndex: rangePair.masterEndIndex, candidateEndIndex: rangePair.candidateEndIndex, isMatched: prevRangePairIsMatched)
            } else {
                updatedRangePairs.append(rangePair)
            }
        }
        return updatedRangePairs
    }
    
    ///  Update the displayed text to be properly highlighted, and annotated to indicate the speaker's accuracy.
    private func displayHighlightedText(using rangePairs: [RangePair]) {
        // Start with a clean copy of the master text.
        var newText = AttributedString(masterText.text)
        
        // Highlight matched and unmatched words.
        rangePairs.forEach { rangePair in
            guard !rangePair.masterRange.isEmpty else { return }
            rangePair.masterRange.forEach { mastIdx in
                let token = masterTokens[mastIdx]
                newText[token.indexRange].foregroundColor = rangePair.isMatched ? .green : .red
            }
        }
        
        // Insert (highlighted) extraneous words that don't appear in the master text.  They are inserted after the last correctly matched text, and before any missed text.
        rangePairs.reversed().forEach { rangePair in
            guard !rangePair.isMatched, !rangePair.candidateRange.isEmpty else { return }
            let sourceStartToken = candidateTokens[rangePair.candidateRange.startIndex]
            let sourceEndToken = candidateTokens[rangePair.candidateRange.endIndex-1]
            let sourceRange = sourceStartToken.startIndex..<sourceEndToken.endIndex
            let targetIdx = switch rangePair.masterRange.endIndex {
            // The extraneous text falls at the beginning of the master text
            case 0: newText.startIndex
            // The extraneous text falls at the end of the master text
            case rangePair.masterRange.startIndex: newText.endIndex
            // The extraneous text falls somewhere in the middle of the master text
            default: newText.index(beforeCharacter: masterTokens[rangePair.masterRange.startIndex].startIndex)
            }
            var sourceText = (targetIdx == newText.startIndex ? "[" : " [") + displayText[sourceRange] + (targetIdx == newText.startIndex ? "] " : "]")
            sourceText.foregroundColor = .orange
            newText.insert(sourceText, at: targetIdx)
        }
        
        // Set the displayText to the highlighted, annotated master text.
        displayText = newText
    }
}
