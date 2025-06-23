# 프로젝트 개요

LoveLoveRaid는 Flutter로 제작된 크로스 플랫폼 비주얼 노벨 게임입니다. Firebase와 연동하여 캐릭터 이미지와 대화 데이터를 관리하며, 선택지에 따른 스토리 진행과 TTS 음성 지원을 제공합니다.

## 주요 기능
- `GameScreenController`를 통한 대화 진행 및 선택지 처리
- Firebase Storage와 Firestore를 이용한 리소스 관리(`ResourceManager`)
- 외부 API 기반의 TTS 기능(`TTSService`)
- Android, iOS, Web, Windows, macOS, Linux 지원

## 디렉터리 구조
```
lib/
├── components/           # 재사용 가능한 위젯 모음
├── constants/            # 전역 상수 정의
├── controller/           # 화면 상태 컨트롤러
├── exceptions/           # 커스텀 예외 정의
├── model/                # 데이터 모델
├── providers/            # Provider 기반 상태 관리
├── screen/               # 상태ful 화면 구현
└── view/                 # 화면 구성을 위한 위젯
```
상위 폴더에는 각 플랫폼 프로젝트(android, ios 등)와 이미지가 포함된 `assets/` 디렉터리가 존재합니다.

## 화면 흐름
1. **TitleScreen** – 네트워크 및 리소스 업데이트를 확인한 뒤 게임 시작 여부를 결정합니다.
2. **PlayerNameInputScreen** – 플레이어 이름을 입력받아 프로필을 생성합니다.
3. **LoadingScreen** – 암호화된 리소스를 로컬에서 불러옵니다.
4. **GameScreen** – 대화 내용과 캐릭터 이미지를 표시하며 사용자 입력을 처리합니다.
5. **AffectionResultScreen / EndScreen** – 게임 회차 종료 시 결과를 요약하고 재시작을 제안합니다.

`GameScreenController`는 대화 시스템을 조율하고 API 통신을 담당하며 UI 상태를 갱신합니다. Firestore는 리소스 메타데이터를, Storage는 암호화된 파일을 저장합니다.

## 설정 파일
환경 설정은 `.env`, `.env.local` 파일에 저장되며 `.gitignore`에 포함되어 있습니다. 실행 전 해당 파일을 생성해야 합니다.

## 시작 방법
Flutter ^3.7.2 설치 후 `flutter pub get`을 실행합니다. 최초 실행 시 업데이트 기능을 통해 리소스를 다운로드할 수 있습니다.

## 기능별 주요 함수
- **타이틀 화면**(`TitleScreen`)
  - `_checkInternetConnection()`
  - `_checkResources()`
  - `initGame()`
  - `getNpcList()`
- **플레이어 이름 입력**(`PlayerNameInputScreen`)
  - `_handleSubmit()`
- **로딩 화면**(`LoadingScreen`)
  - `_startLoading()`
  - `_preloadImages()`
- **리소스 다운로드**(`ResourceDownloadScreen`, `ResourceManager`)
  - `ResourceDownloadScreen._startDownload()`
  - `ResourceManager.initialize()`
  - `ResourceManager.checkForUpdates()`
  - `ResourceManager.update()`
  - `ResourceManager.fetchLatestVersion()`
  - `ResourceManager.downloadResources()`
  - `ResourceManager.getResourcePath()`
  - `ResourceManager.readEncryptedJson()`
  - `ResourceManager.readEncryptedBinary()`
  - `ResourceManager.clearImageCache()`
- **게임 진행**(`GameScreen`, `GameScreenController`)
  - `GameScreen._handleSend()`
  - `GameScreen._handleKeyEvent()`
  - `GameScreenController.init()`
  - `sendPlayerMessage()`
  - `goToPreviousMessage()`
  - `goToNextMessage()`
  - `showHistoryPopup()`
  - `showCGView()`
  - `skipOrNext()`
  - `toggleUI()`
  - `handleKeyEvent()`
  - `initSession()`
  - `getInitialEvent()`
  - `addDialogue()`
  - `addErrorDialogueLine()`
  - `playTTS()`
  - `markCharacterAsAnimated()`
  - `_showHistoryMessage()`
  - `_handleError()`
- **API 서비스**(`GameApiService`)
  - `startSession()`
  - `getInitialEvent()`
  - `sendDialogue()`
- **TTS 서비스**(`TTSService`)
  - `generateSpeech()`
- **플레이어 관리**(`PlayerProvider`)
  - `setId()`
  - `setName()`
  - `resetPlayer()`

