//
//  LoginItemManager.swift
//  Runlet
//
//  서비스 레이어 — 로그인 시 자동 실행(로그인 항목) 등록/해제를 감싼다.
//  `SMAppService.mainApp` 사용 (ServiceManagement, macOS 13+).
//

import Foundation
import Combine
import ServiceManagement

final class LoginItemManager: ObservableObject {
    /// 현재 로그인 항목으로 등록돼 있는지. 토글 UI가 이 값을 반영한다.
    @Published private(set) var isEnabled: Bool = false

    init() {
        refresh()
    }

    /// 시스템의 실제 상태를 다시 읽어 `isEnabled`에 반영한다.
    func refresh() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    /// 로그인 항목 등록/해제. 실패해도(무피드백) 내부 로깅만 남긴다.
    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("Runlet: 로그인 항목 변경 실패 — %@", error.localizedDescription)
        }
        refresh()
    }
}
