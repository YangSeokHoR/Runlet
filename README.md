# Runlet

터미널에서 명령어를 쳐야만 실행되던 작업을, **메뉴바 드롭다운의 버튼 하나로** 실행하는 개인용 macOS 유틸리티.

자주 쓰는 셸 명령(예: 내가 만든 앱의 빌드+실행)을 "이름 붙은 버튼"으로 등록해두고, 메뉴바에서 한 번 클릭으로 백그라운드에서 조용히 실행한다. 반복적으로 Terminal을 열고 → 디렉토리 이동하고 → 긴 명령어를 입력하는 마찰을 없앤다.

> `Runlet`은 가칭이며 언제든 교체 가능하다.

## 특징

- **메뉴바 상주** — 상단 메뉴바 아이콘 클릭 시 등록된 명령이 리스트로 뜬다. (Dock 아이콘·창 없음)
- **원클릭 실행** — 명령을 누르면 드롭다운이 닫히고 백그라운드에서 조용히 실행된다. 별도 터미널 창·알림 없음(무피드백).
- **여러 명령 관리** — 별도 관리 창에서 이름·스크립트를 추가/수정/삭제. 변경은 즉시 저장되고 드롭다운에 반영된다.
- **로그인 셸 실행** — `/bin/zsh -l -c`로 스크립트 전체를 넘겨 파이프·치환·여러 줄 문법을 그대로 해석하고, `.zprofile`/`.zshrc`의 PATH(Homebrew 등)를 상속한다.
- **로그인 시 자동 실행**(옵션) — `SMAppService`로 로그인 항목 등록/해제.

## 요구 사항

- macOS 13 (Ventura) 이상 (`MenuBarExtra` 사용)
- Xcode 15 이상

## 빌드 & 실행

```
open Runlet.xcodeproj
```

Xcode에서 `Runlet` 스킴을 선택하고 실행(⌘R)하면 메뉴바에 아이콘이 뜬다. 또는:

```
xcodebuild -project Runlet.xcodeproj -scheme Runlet -configuration Debug -destination 'platform=macOS' build
```

> **샌드박스 OFF가 전제다.** 임의의 셸/바이너리를 실행해야 하므로 App Sandbox는 켜지 않는다. 그래서 Mac App Store 배포 대상이 아니며, 로컬 개인용으로 `.app`을 복사해 쓰거나 Xcode에서 직접 실행한다. 다른 곳에서 받은 것으로 처리돼 Gatekeeper 경고가 뜨면 최초 1회 우클릭 → 열기로 통과한다.

## 사용법

1. 메뉴바의 Runlet 아이콘을 클릭한다.
2. 등록된 명령을 클릭하면 백그라운드에서 실행된다.
3. 명령을 편집하려면 드롭다운 하단 **"명령어 관리…"** 로 관리 창을 연다. `+`/`−` 로 추가·삭제하고, 오른쪽에서 이름과 스크립트를 수정한다.

명령 예시:

```
이름:   KeyFlow 빌드+실행
스크립트:
cd ~/Developer/KeyFlow
./make-app.sh
open /Applications/KeyFlow.app
```

명령 목록은 `~/Library/Application Support/Runlet/commands.json` 에 저장되어 앱을 껐다 켜도 유지된다.

## 아키텍처

의존 방향은 위 → 아래 한 방향이다 (UI → 서비스 → 모델).

| 레이어 | 구성 요소 |
|---|---|
| UI | `MenuBarListView`(드롭다운) · `ManagerWindowView`(관리 창) · `RunletApp`(진입점) |
| 서비스 | `CommandStore`(목록 상태·JSON 저장/로드) · `CommandRunner`(셸 실행) · `LoginItemManager`(자동 실행) |
| 모델 | `RunCommand`(id + 이름 + 스크립트) |

- `CommandRunner`는 UI·저장소를 모른다 (스크립트 문자열만 받아 실행).
- `CommandStore`는 실행 로직을 모른다 (데이터만 관리).
- 드롭다운과 관리 창은 같은 `CommandStore`를 공유해 편집이 즉시 반영된다.

## 기술 스택

Swift · SwiftUI(`MenuBarExtra`) · Foundation `Process` · `Codable`/JSON · `ServiceManagement`(`SMAppService`)

## 문서

- [CLAUDE.md](CLAUDE.md) — 저장소 작업 기준 요약
- [Runlet_개발지침서.md](Runlet_개발지침서.md) — 제품·아키텍처 상세 명세
- [CONVENTIONS.md](CONVENTIONS.md) — 커밋/브랜치/PR 규칙
