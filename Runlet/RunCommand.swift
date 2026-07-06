//
//  RunCommand.swift
//  Runlet
//
//  모델 레이어 — 명령 하나를 나타내는 값 타입.
//

import Foundation

/// 드롭다운에 표시되고 셸로 실행되는 명령 하나.
/// 작업 디렉토리는 별도 필드 없이 `script` 안의 `cd`로 처리한다.
struct RunCommand: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var script: String

    init(id: UUID = UUID(), name: String, script: String) {
        self.id = id
        self.name = name
        self.script = script
    }
}
