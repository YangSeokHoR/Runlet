//
//  MenubIntegration.swift
//  Runlet
//
//  Runlet ↔ menub 허브 통합. 3계약 + 허브 액션 목록 구성(설정 → 명령들 → 종료).
//  MenubKit 소스는 Runlet/MenubKit/에 벤더링됨.
//

import AppKit
import Combine
import SwiftUI

/// 명령 목록을 menub 액션으로 노출하고 URL 호출로 실행하는 브리지.
final class RunletMenub {
    /// 최상단 "설정"(명령어 관리 창 열기) 액션 id.
    static let settingsActionID = "settings"

    let satellite = MenubSatellite(
        id: "runlet",
        displayName: "Runlet",
        urlScheme: "runlet",
        bundleIdentifier: Bundle.main.bundleIdentifier,
        iconRef: "sf:terminal"
    )

    private var cancellable: AnyCancellable?

    func start(store: CommandStore, onOpenSettings: @escaping () -> Void) {
        satellite.setQuitAction { NSApp.terminate(nil) }   // 맨 아래 "종료" 자동

        // 계약 2: "설정"이면 관리 창을 열고, 그 외(명령 UUID)면 해당 명령 실행
        satellite.onInvoke { [weak store] actionID in
            if actionID == Self.settingsActionID {
                onOpenSettings()
                return
            }
            guard let store,
                  let command = store.commands.first(where: { $0.id.uuidString == actionID })
            else { return }
            CommandRunner.run(command.script)
        }

        // 계약 1(동적): "설정"을 맨 위에, 그 아래 명령들. 명령이 바뀔 때마다 재기록.
        cancellable = store.$commands.sink { [weak self] commands in
            guard let self else { return }
            var actions = [
                self.satellite.makeAction(id: Self.settingsActionID, title: "설정", iconRef: "sf:gearshape")
            ]
            actions += commands.map {
                self.satellite.makeAction(id: $0.id.uuidString, title: $0.name)
            }
            self.satellite.setActions(actions)
            self.satellite.writeManifest()
        }
    }

    func route(_ url: URL) {
        satellite.route(url)
    }

    var showsMenuBar: Bool {
        satellite.shouldCreateStatusItem()
    }
}

/// 앱 생명주기 훅 + 관리 창(AppKit)을 소유한다.
final class RunletAppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    let store = CommandStore()
    private let menub = RunletMenub()
    private var managerWindow: NSWindow?

    let showsMenuBar: Bool

    override init() {
        showsMenuBar = menub.showsMenuBar
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        menub.start(store: store, onOpenSettings: { [weak self] in self?.showManager() })
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        urls.forEach { menub.route($0) }
    }

    /// 명령어 관리 창을 연다(메뉴바 버튼·허브 "설정" 액션 공용). SwiftUI 뷰를 AppKit 창에 얹는다.
    func showManager() {
        if managerWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 560, height: 360),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.title = "명령어 관리"
            window.isReleasedWhenClosed = false
            window.contentView = NSHostingView(rootView: ManagerWindowView().environmentObject(store))
            window.center()
            managerWindow = window
        }
        NSApp.activate(ignoringOtherApps: true)
        managerWindow?.makeKeyAndOrderFront(nil)
    }
}
