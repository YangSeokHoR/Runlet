//
//  RunletApp.swift
//  Runlet
//
//  앱 진입점 — 메뉴바 scene(MenuBarExtra)만 SwiftUI로 두고, 관리 창은 앱델리게이트가 AppKit으로 연다.
//  (SwiftUI Window scene은 URL로 앱이 활성화될 때 딸려 뜨는 문제가 있어 AppKit 창으로 관리한다)
//  menub 허브가 관리 중이면 메뉴바 아이템을 만들지 않는다(계약 3).
//

import SwiftUI

@main
struct RunletApp: App {
    @NSApplicationDelegateAdaptor(RunletAppDelegate.self) private var appDelegate
    @StateObject private var loginItem = LoginItemManager()

    var body: some Scene {
        // 허브가 관리하지 않을 때만 자기 메뉴바 아이템을 만든다.
        MenuBarExtra("Runlet", systemImage: "terminal", isInserted: .constant(appDelegate.showsMenuBar)) {
            MenuBarListView(onOpenManager: { appDelegate.showManager() })
                .environmentObject(appDelegate.store)
                .environmentObject(loginItem)
        }
        .menuBarExtraStyle(.menu)
    }
}
