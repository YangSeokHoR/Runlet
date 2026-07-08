//
//  MenuBarListView.swift
//  Runlet
//
//  UI 레이어 — 메뉴바 드롭다운. 명령을 버튼으로 렌더링하고(실행 전용)
//  하단에 관리 창 진입점을 둔다.
//

import SwiftUI
import AppKit

struct MenuBarListView: View {
    let onOpenManager: () -> Void

    @EnvironmentObject private var store: CommandStore
    @EnvironmentObject private var loginItem: LoginItemManager

    var body: some View {
        if store.commands.isEmpty {
            Text("등록된 명령이 없습니다")
        } else {
            ForEach(store.commands) { command in
                Button(command.name.isEmpty ? "(이름 없음)" : command.name) {
                    // 클릭 즉시 드롭다운이 닫히고, 명령은 백그라운드에서 조용히 실행된다.
                    CommandRunner.run(command.script)
                }
            }
        }

        Divider()

        Button("명령어 관리…") {
            onOpenManager()
        }

        Toggle("로그인 시 자동 실행", isOn: Binding(
            get: { loginItem.isEnabled },
            set: { loginItem.setEnabled($0) }
        ))

        Divider()

        Button("Runlet 종료") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
