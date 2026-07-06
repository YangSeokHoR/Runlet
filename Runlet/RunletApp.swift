//
//  RunletApp.swift
//  Runlet
//
//  앱 진입점 — 메뉴바 scene(MenuBarExtra)과 관리 창(Window) scene을 구성한다.
//

import SwiftUI

@main
struct RunletApp: App {
    // 드롭다운과 관리 창이 공유하는 단일 상태 소스.
    @StateObject private var store = CommandStore()
    @StateObject private var loginItem = LoginItemManager()

    var body: some Scene {
        MenuBarExtra("Runlet", systemImage: "terminal") {
            MenuBarListView()
                .environmentObject(store)
                .environmentObject(loginItem)
        }
        .menuBarExtraStyle(.menu)

        Window("명령어 관리", id: ManagerWindowView.windowID) {
            ManagerWindowView()
                .environmentObject(store)
        }
        .windowResizability(.contentMinSize)
    }
}
