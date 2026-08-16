//
//  DataStores.swift
//  Memoria
//
//  Created by Joseph McSorley on 8/9/26.
//

import SwiftData

@MainActor
class DataStores {
    static let instance = DataStores()
    var modelContainer: ModelContainer? {
        didSet {
            set(modelContainer: modelContainer)
        }
    }
    let memoryTextStore = MemoryTextStore()

    private init() {
        set(modelContainer: modelContainer)
    }
    
    private func set(modelContainer: ModelContainer?) {
        memoryTextStore.modelContainer = modelContainer
    }
}

@MainActor
let dataStores = DataStores.instance

extension DataStores {
    func setMockEnv() {
        let schema = Schema([MemoryText.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            dataStores.modelContainer = modelContainer
        } catch {
            fatalError("DataStores.setMockEnv()  Error creating mock ModelContainer: \(error)")
        }
        
//        // Create new game
//        let game = gameStore.game
//        game?.pointsPerGame = 200
//        gameStore.save()
//        
//        // Add Players
//        playerStore.updatePlayers([
//            Player(seqId: 0, name: "Alph", team: .team1),
//            Player(seqId: 0, name: "Bob", team: .team2)
//        ])
//        
//        // Add MatchSets
//        guard let team1Player = playerStore.players(for: .team1).first, let team2Player = playerStore.players(for: .team2).first else {
//            fatalError("DataStores.setMockEnv()  Unable to fetch mock Players")
//        }
//        matchSetStore.add(MatchSet(seqId: 0, scores: [
//            Match(player: team1Player, score: 44)
//        ]))
//        matchSetStore.add(MatchSet(seqId: 1, scores: [
//            Match(player: team2Player, score: 88)
//        ]))
//        matchSetStore.add(MatchSet(seqId: 2, scores: [
//            Match(player: team1Player, score: 33)
//        ]))
//        matchSetStore.add(MatchSet(seqId: 3, scores: [
//            Match(player: team1Player, score: 22)
//        ]))
//        matchSetStore.add(MatchSet(seqId: 4, scores: [
//            Match(player: team2Player, score: 55)
//        ]))
    }
}
