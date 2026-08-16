//
//  MemoryTextStore.swift
//  Memoria
//
//  Created by Joseph McSorley on 8/9/26.
//

import SwiftData

@MainActor
class MemoryTextStore {
    var modelContainer: ModelContainer?
    
    init() {}
    
//    var game: Game? {
//        do {
//            if let games = try modelContainer?.mainContext.fetch(FetchDescriptor<Game>()), let game = games.first { return game }
//            return createGame()
//        } catch {
//            print("GameStore.game  Error fetching Game")
//        }
//        return nil
//    }
    
    func save() {
        do {
            try modelContainer?.mainContext.save()
        } catch {
            print("MemoryTextStore.save():  Error saving MemoryText")
        }
    }
    
    // MARK: - Helpers
    
//    private func createGame() -> Game? {
//        do {
//            try modelContainer?.mainContext.delete(model: Game.self)
//            let newGame = Game(pointsPerGame: initialPointsPerGame, playersPerTeam: initialPlayersPerTeam)
//            modelContainer?.mainContext.insert(newGame)
//            save()
//            return newGame
//        } catch {
//            print("GameStore.game  Error creating Game instance")
//        }
//        return nil
//    }
}
