//
//  ManagerWindowView.swift
//  Runlet
//
//  UI 레이어 — 별도 관리 창. 명령을 추가/수정/삭제한다.
//  드롭다운과 같은 CommandStore를 공유하므로 편집이 즉시 반영된다.
//

import SwiftUI

struct ManagerWindowView: View {
    static let windowID = "manager"

    @EnvironmentObject private var store: CommandStore
    @State private var selection: RunCommand.ID?

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(store.commands) { command in
                    Text(command.name.isEmpty ? "(이름 없음)" : command.name)
                        .tag(command.id)
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 220)
            .safeAreaInset(edge: .bottom) {
                listToolbar
            }
        } detail: {
            if let index = selectedIndex {
                CommandEditor(command: $store.commands[index])
                    .id(store.commands[index].id)
            } else {
                ContentUnavailableMessage()
            }
        }
        .frame(minWidth: 560, minHeight: 360)
    }

    private var selectedIndex: Int? {
        guard let selection else { return nil }
        return store.commands.firstIndex { $0.id == selection }
    }

    private var listToolbar: some View {
        HStack {
            Button {
                selection = store.addCommand()
            } label: {
                Image(systemName: "plus")
            }
            .help("명령 추가")

            Button {
                deleteSelected()
            } label: {
                Image(systemName: "minus")
            }
            .help("선택한 명령 삭제")
            .disabled(selection == nil)

            Spacer()
        }
        .buttonStyle(.borderless)
        .padding(8)
    }

    private func deleteSelected() {
        guard let selection else { return }
        store.deleteCommand(id: selection)
        self.selection = nil
    }
}

/// 하나의 명령을 편집하는 폼.
private struct CommandEditor: View {
    @Binding var command: RunCommand

    var body: some View {
        Form {
            Section {
                TextField("이름", text: $command.name)
            }
            Section("스크립트") {
                TextEditor(text: $command.script)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 220)
            }
        }
        .formStyle(.grouped)
    }
}

/// 아무 명령도 선택되지 않았을 때의 안내.
private struct ContentUnavailableMessage: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "terminal")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("왼쪽에서 명령을 선택하거나 + 로 새로 추가하세요")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
