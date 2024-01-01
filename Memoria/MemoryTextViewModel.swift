//
//  MemoryTextViewModel.swift
//  Memoria
//
//  Created by Joseph McSorley on 12/28/23.
//

import AVFoundation
import Combine
import SwiftUI

typealias MatchInfo = (masterStartIndex: Int, consecutiveMatches: Int)

class MemoryTextViewModel: NSObject, ObservableObject {
    @Bindable private(set) var masterText: MemoryText
    @Published var displayText = AttributedString("")
    var addEditViewModel: AddEditTextViewModel
    private let speechRecognizer: SpeechRecognizer
    private var spokenInputCancellables = Set<AnyCancellable>()
    private var masterTokens = [Token]()
    private var candidateTokens = [Token]()
    private var transcripts = [String]()

    init(text: MemoryText, speechRecognizer: SpeechRecognizer) {
        self.masterText = text
        self.speechRecognizer = speechRecognizer
        self.addEditViewModel = AddEditTextViewModel(text)
        super.init()
    }
    
    @MainActor
    func handleSpokenInput() {
        Task {
            await speechRecognizer.$transcript
                .receive(on: RunLoop.main)
                .sink { [weak self] transcript in
                    if transcript.startTimeStamp != nil {
                        self?.transcripts.append(transcript.transcript)
                    } else {
                        self?.displayText = ""
                        self?.transcripts.forEach { self?.displayText += AttributedString($0) + "\n" }
                        self?.displayText += AttributedString(transcript.transcript)
                    }
                }
                .store(in: &spokenInputCancellables)
            
            await speechRecognizer.$isTranscribing
                .dropFirst()
                .receive(on: RunLoop.main)
                .sink { [weak self] isTranscribing in
                    guard !isTranscribing else { return }
                    self?.evaluateText()
                    Task { [weak self] in
                        self?.spokenInputCancellables.removeAll()
                    }
                }
                .store(in: &spokenInputCancellables)
        }
        
        transcripts = []
        displayText = ""
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
    }
    
    @MainActor
    func stopListening() {
        speechRecognizer.stopTranscribing()
    }
    
    func evaluateText() {
        guard !displayText.characters.isEmpty else { return }
        masterTokens = tokenize(AttributedString(masterText.text))
        candidateTokens = tokenize(displayText)

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
        updateText(using: rangePairs)
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
    private func updateText(using rangePairs: [RangePair]) {
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
        
        // Insert (highlighted) extraneous words that don't appear in the master text.
        rangePairs.reversed().forEach { rangePair in
            guard !rangePair.isMatched, !rangePair.candidateRange.isEmpty else { return }
            let sourceStartToken = candidateTokens[rangePair.candidateRange.startIndex]
            let sourceEndToken = candidateTokens[rangePair.candidateRange.endIndex-1]
            let sourceRange = sourceStartToken.startIndex..<sourceEndToken.endIndex
            let targetIdx = switch rangePair.masterRange.endIndex {
            case 0: newText.startIndex
            case masterTokens.count: newText.endIndex
            default: masterTokens[rangePair.masterRange.endIndex-1].endIndex
            }
            var sourceText = " [" + displayText[sourceRange] + "]"
            sourceText.foregroundColor = .orange
            newText.insert(sourceText, at: targetIdx)
        }
        
        // Set the displayText to the highlighted, annotated master text.
        displayText = newText
    }
}
