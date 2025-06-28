# LoveLoveRaid

Flutter로 개발된 크로스 플랫폼 애플리케이션입니다.

## 프로젝트 개요

이 프로젝트는 Flutter 프레임워크를 사용하여 개발된 모바일/데스크톱 애플리케이션입니다. Firebase를 백엔드로 활용하며, 다양한 플랫폼(iOS, Android, Web, Windows, macOS, Linux)을 지원합니다.

## 주요 기능

- Firebase 연동 (Firestore, Storage)
- 오디오 재생 기능
- 환경 변수 관리
- 네트워크 연결 상태 모니터링
- 로컬 데이터 저장

## 기술 스택

- Flutter SDK (^3.7.2)
- Firebase (Core, Firestore, Storage)
- HTTP 통신
- 오디오 재생 (just_audio)
- 로컬 스토리지 (shared_preferences)
- 환경 변수 관리 (flutter_dotenv)

## 프로젝트 구조

```
lib/
├── components/     # 재사용 가능한 UI 컴포넌트
├── constants/      # 상수 정의
├── controller/     # 비즈니스 로직 컨트롤러
├── exceptions/     # 예외 처리
├── model/         # 데이터 모델
├── screen/        # 화면 UI
├── services/      # 서비스 로직
└── view/          # 뷰 컴포넌트
```

## 시작하기

1. Flutter SDK 설치 (^3.7.2)
2. 프로젝트 클론
3. 의존성 설치:
   ```bash
   flutter pub get
   ```
4. 환경 변수 설정:
   - `.env` 및 `.env.local` 파일 생성
5. 앱 실행:
   ```bash
   flutter run
   ```

## 개발 환경 설정

- VS Code 또는 Android Studio 사용 권장
- Flutter 및 Dart 플러그인 설치
- Firebase CLI 설치 및 프로젝트 설정

## 프로젝트 설정 파일

다음 파일들은 보안상의 이유로 버전 관리에서 제외되어 있으며, 프로젝트 설정 시 별도로 인계가 필요합니다:

### 환경 변수 파일

- `.env` - 기본 환경 변수 설정
- `.env.local` - 로컬 환경 변수 설정

### Firebase 설정 파일

- `lib/firebase_options.dart` - Firebase 프로젝트 설정
- `firebase.json` - Firebase 호스팅 및 함수 설정
- `assets/service_account.json` - Firebase 서비스 계정 키

### 플랫폼별 Firebase 설정

- iOS: `ios/Runner/GoogleService-Info.plist`
- Android: `android/app/google-services.json`
- macOS: `macos/Runner/GoogleService-Info.plist`

## 라이선스

이 프로젝트는 비공개로 유지됩니다.

## 사용된 라이브러리

- [window_size](https://pub.dev/packages/window_size) - 윈도우 크기 조절을 위한 패키지
- [http](https://pub.dev/packages/http) - HTTP 통신을 위한 패키지
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) - 환경 변수 관리를 위한 패키지
- [just_audio](https://pub.dev/packages/just_audio) - 오디오 재생을 위한 패키지
- [firebase_core](https://pub.dev/packages/firebase_core) - Firebase 핵심 기능
- [firebase_storage](https://pub.dev/packages/firebase_storage) - Firebase 스토리지
- [path_provider](https://pub.dev/packages/path_provider) - 파일 시스템 경로 접근
- [shared_preferences](https://pub.dev/packages/shared_preferences) - 로컬 데이터 저장
- [cloud_firestore](https://pub.dev/packages/cloud_firestore) - Firebase Firestore
- [connectivity_plus](https://pub.dev/packages/connectivity_plus) - 네트워크 연결 상태 모니터링
- [path](https://pub.dev/packages/path) - 경로 조작 유틸리티
- [encrypt](https://pub.dev/packages/encrypt) - 암호화 기능
- [provider](https://pub.dev/packages/provider) - 상태 관리
- [uuid](https://pub.dev/packages/uuid) - 고유 식별자 생성
