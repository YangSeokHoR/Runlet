//
//  CommandStore.swift
//  Runlet
//
//  서비스 레이어 — 명령 목록 상태를 메모리에 들고 JSON으로 저장/로드한다.
//  실행 로직은 모른다 (데이터만 관리).
//

import Foundation
import Combine

final class CommandStore: ObservableObject {
    /// 드롭다운·관리 창이 공유하는 명령 목록. 변경 시 자동 저장된다.
    @Published var commands: [RunCommand] = []

    private let fileURL: URL
    private var saveCancellable: AnyCancellable?

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let folder = support.appendingPathComponent("Runlet", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        fileURL = folder.appendingPathComponent("commands.json")

        load()

        // commands가 바뀔 때마다(관리 창 편집 포함) 디스크에 저장한다.
        // 타이핑마다 쓰지 않도록 살짝 debounce 한다. 첫 방출(현재값)은 건너뛴다.
        saveCancellable = $commands
            .dropFirst()
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .sink { [weak self] commands in
                self?.write(commands)
            }
    }

    // MARK: - CRUD

    /// 빈 명령을 추가하고 그 id를 돌려준다 (관리 창에서 바로 선택·편집용).
    @discardableResult
    func addCommand() -> RunCommand.ID {
        let new = RunCommand(name: "새 명령", script: "")
        commands.append(new)
        return new.id
    }

    func deleteCommand(id: RunCommand.ID) {
        commands.removeAll { $0.id == id }
    }

    // MARK: - 영속화

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else {
            commands = Self.seed
            return
        }
        do {
            commands = try JSONDecoder().decode([RunCommand].self, from: data)
        } catch {
            NSLog("Runlet: commands.json 로드 실패 — %@", error.localizedDescription)
            commands = []
        }
    }

    private func write(_ commands: [RunCommand]) {
        do {
            let data = try JSONEncoder().encode(commands)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            NSLog("Runlet: commands.json 저장 실패 — %@", error.localizedDescription)
        }
    }

    /// 저장된 목록이 없을 때 처음 보여줄 실사용 예시 (지침서 샘플).
    private static let seed: [RunCommand] = [
        RunCommand(
            name: "KeyFlow 빌드+실행",
            script: """
            cd ~/Developer/KeyFlow
            ./make-app.sh
            open /Applications/KeyFlow.app
            """
        )
    ]
}
