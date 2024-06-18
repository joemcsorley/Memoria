//
//  NavigationCoordinator.swift
//  MultiNav
//
//  Created by Joseph McSorley on 4/22/24.
//

import SwiftUI

// MARK: - NavigationCoordinator

@Observable
class NavigationCoordinator<S: NavigationScreenDefinition> {
    var navStack = [S]() {
        willSet {
            handleNavStackUpdate(oldStack: navStack, newStack: newValue)
        }
    }
    @ObservationIgnored private var observablesDict: [S: any Observable] = [:]

    @ViewBuilder
    func navigate(to screen: S) -> some View {
        if screen != S.root && !navStack.contains(screen) {
            EmptyView()
        } else {
            screen.screenView(navCoordinator: self)
        }
    }
    
    func push(_ screen: S) {
        navStack.append(screen)
    }
    
    func pop() {
        navStack.removeLast()
    }
    
    func popToRoot() {
        navStack.removeAll()
    }
    
    func jumpTo(_ navStack: [S]) {
        self.navStack = navStack
    }
    
    func observable<T: Observable>(for screen: S, default defaultValue: @autoclosure () -> T) -> T {
        if let observable = observablesDict[screen] as? T {
            return observable
        }
        let observable = defaultValue()
        register(observable, for: screen)
        return observable
    }
    
    func removeObservable(for screen: S) {
        observablesDict.removeValue(forKey: screen)
    }
    
    private func register(_ newObservable: any Observable, for screen: S) {
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
    let navCoordinator: NavigationCoordinator<S>
    
    var body: some View {
        @Bindable var navCoordinator = navCoordinator
        return NavigationStack(path: $navCoordinator.navStack) {
            navCoordinator.navigate(to: S.root)
                .navigationDestination(for: S.self) { screen in
                    navCoordinator.navigate(to: screen)
                }
        }
        .environment(navCoordinator)
    }
}

// MARK: - Modal Presentation

/// Make ModalPresenter the superclass of a ViewModel (Observable), then its presentSheet() func can be used, in conjunction with a NavigationScreenDefinition enum, to present modals from either the View, or the ViewModel.
@Observable
class ModalPresenter<S: NavigationScreenDefinition> {
    var sheet: S?
    var fullScreenCover: S?
    var alertComponents: AlertViewComponents?
    var isAlertPresented = false
    @ObservationIgnored var lastModalPresented: S?
    
    func presentModal(_ modalToPresent: S, isFullScreen: Bool = false) {
        lastModalPresented = modalToPresent
        // If you're debugging, and you get here, and your modal is not being presented, it's probably because you didn't add the .modalPresenting() modifier to your View.
        if isFullScreen {
            fullScreenCover = modalToPresent
        } else {
            sheet = modalToPresent
        }
    }
    
    func presentAlert(_ alertComponents: AlertViewComponents) {
        self.alertComponents = alertComponents
        isAlertPresented = true
    }
    
    func handleAlertButton(id: Int) {}
}

struct ModalPresentingViewModifier<S: NavigationScreenDefinition>: ViewModifier {
    var presenter: ModalPresenter<S>
    let navCoordinator: NavigationCoordinator<S>
    
    func body(content: Content) -> some View {
        @Bindable var presenter = presenter
        content
            .sheet(item: $presenter.sheet, onDismiss: {
                handleDismiss()
            }, content: {
                $0.screenView(navCoordinator: navCoordinator)
            })
            .fullScreenCover(item: $presenter.fullScreenCover, onDismiss: {
                handleDismiss()
            }, content: {
                $0.screenView(navCoordinator: navCoordinator)
            })
            .alert(presenter.alertComponents?.title ?? "", isPresented: $presenter.isAlertPresented, presenting: presenter.alertComponents, actions: { alertComponents in
                ForEach(alertComponents.buttons) { btn in
                    Button(btn.title, role: btn.role.role) {
                        presenter.handleAlertButton(id: btn.id)
                    }
                }
            }, message: { alertComponents in
                Text(alertComponents.message)
            })
    }
    
    private func handleDismiss() {
        guard let dismissedModal = presenter.lastModalPresented else { return }
        navCoordinator.removeObservable(for: dismissedModal)
        presenter.lastModalPresented = nil
    }
}

extension View {
    func modalPresenting<S: NavigationScreenDefinition>(using presenter: ModalPresenter<S>, navCoordinator: NavigationCoordinator<S>) -> some View {
        self.modifier(ModalPresentingViewModifier(presenter: presenter, navCoordinator: navCoordinator))
    }
}

// MARK: - AlertViewComponents

struct AlertViewComponents: Hashable {
    var title = ""
    var message = ""
    var buttons = [AlertButton(id: 0, title: "Ok")]
}

struct AlertButton: Identifiable, Hashable {
    var id: Int
    var title: String
    var role = AlertButtonRole.cancel
}

enum AlertButtonRole {
    case cancel
    case destructive
    
    var role: ButtonRole {
        switch self {
        case .cancel: .cancel
        case .destructive: .destructive
        }
    }
}

