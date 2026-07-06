//
//  CommandRunner.swift
//  Runlet
//
//  서비스 레이어 — 스크립트 문자열을 받아 셸로 실행하는 순수 실행기.
//  UI·저장소를 모른다.
//

import Foundation

enum CommandRunner {
    /// 스크립트 전체를 로그인 zsh(`/bin/zsh -l -c`)에 넘겨 백그라운드로 실행한다.
    ///
    /// - 로그인 셸(`-l`)이라 `.zprofile`/`.zshrc`의 PATH(Homebrew 등)를 상속한다.
    /// - `-c`로 스크립트 전체를 넘기므로 파이프·치환·여러 줄이 zsh 문법 그대로 해석된다.
    /// - `run()`은 프로세스를 띄운 뒤 즉시 반환하므로 UI를 막지 않는다.
    /// - 무피드백 원칙에 따라 결과는 표시하지 않고, 실패 시 종료 코드만 내부 로깅한다.
    nonisolated static func run(_ script: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-l", "-c", script]

        process.terminationHandler = { finished in
            if finished.terminationStatus != 0 {
                NSLog("Runlet: 명령이 종료 코드 %d 로 끝났습니다.", finished.terminationStatus)
            }
        }

        do {
            try process.run()
        } catch {
            NSLog("Runlet: 명령 실행에 실패했습니다 — %@", error.localizedDescription)
        }
    }
}
