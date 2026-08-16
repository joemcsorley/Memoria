//
//  ModalPresenter.swift
//  Memoria
//
//  Created by Joseph McSorley on 8/9/26.
//

import SwiftUI

/// Make ModalPresenter the superclass of an Observable, then presentModal(), and presentAlert() can be used, in conjunction with a NavigationScreenDefinition enum, to present modals from either the View, or the Observable.
@MainActor @Observable
class ModalPresenter<S: NavigationScreenDefinition>: DynamicProperty {
    let navCoordinator: NavigationCoordinator<S>
    var sheet: S?
    var fullScreenCover: S?
    var alertComponents: AlertViewComponents?
    var isAlertPresented = false
    @ObservationIgnored var lastModalPresented: S?
    
    init(navCoordinator: NavigationCoordinator<S>) {
        self.navCoordinator = navCoordinator
    }
    
    func presentModal(_ modalToPresent: S, _ observable: (any Observable)? = nil, isFullScreen: Bool = false) {
        lastModalPresented = modalToPresent
        if let observable {
            navCoordinator.register(observable, for: modalToPresent)
        }
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
