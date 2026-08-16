//
//  NavigationCoordinator.swift
//  Memoria
//
//  Created by Joseph McSorley on 4/22/24.
//

import SwiftUI

// MARK: - NavigationCoordinator

@MainActor @Observable
class NavigationCoordinator<S: NavigationScreenDefinition> {
    @ObservationIgnored private var observablesDict: [S: any Observable] = [:]
    var navStack = [S]() {
        willSet {
            handleNavStackUpdate(oldStack: navStack, newStack: newValue)
        }
    }

    @ViewBuilder
    func navigate(to screen: S) -> some View {
        if screen != S.root && !navStack.contains(screen) {
            EmptyView()
        } else {
            screen.screenView(navCoordinator: self)
        }
    }
    
    func push(_ screen: S, _ observable: (any Observable)? = nil) {
        if let observable {
            register(observable, for: screen)
        }
        navStack.append(screen)
    }
    
    func pop() {
        navStack.removeLast()
    }
    
    func popToRoot() {
        navStack.removeAll()
    }
    
    func jumpTo(_ navStack: [S], _ od: [S: any Observable]? = nil) {
        if let od {
            self.observablesDict.merge(od, uniquingKeysWith: { $1 })
        }
        self.navStack = navStack
    }
    
    func observable<T: Observable>(for screen: S, default defaultValue: @autoclosure () -> T) -> T {
        if let observable = observablesDict[screen] as? T {
            return observable
        }
        if let badObservable = observablesDict[screen] {
            print("Navigation Error: An incorrectly typed observable was found (\(type(of: badObservable))) for view \(screen).  Proceeding with default observable.")
        }
        let observable = defaultValue()
        register(observable, for: screen)
        return observable
    }
    
    func removeObservable(for screen: S) {
        observablesDict.removeValue(forKey: screen)
    }
    
    func register(_ newObservable: any Observable, for screen: S) {
        observablesDict[screen] = newObservable
    }
    
    private func handleNavStackUpdate(oldStack: [S], newStack: [S]) {
        let removedScreens = Set(oldStack).subtracting(Set(newStack))
        removedScreens.forEach { observablesDict.removeValue(forKey: $0) }
    }
}

// MARK: - NavigationScreenDefinition

protocol NavigationScreenDefinition: Hashable, Identifiable {
    associatedtype V: View
    static var root: Self { get }
    func screenView(navCoordinator: NavigationCoordinator<Self>) -> V
}

extension NavigationScreenDefinition {
    var id: Self { self }
}

// MARK: - NavigationRootView

struct NavigationRootView<S: NavigationScreenDefinition>: View {
    @Bindable var navCoordinator: NavigationCoordinator<S>
    
    var body: some View {
        return NavigationStack(path: $navCoordinator.navStack) {
            navCoordinator.navigate(to: S.root)
                .navigationDestination(for: S.self) { screen in
                    navCoordinator.navigate(to: screen)
                }
        }
        .environment(navCoordinator)
    }
}
