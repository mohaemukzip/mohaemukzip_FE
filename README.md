# mohaemukzip_FE
mohaemukzip_FE_Repo


# 🚀 뭐해먹집?



## 📱 소개

> 반복되는 '뭐해 먹지'를 집밥 루틴으로 바꾸다, 뭐해먹집? 

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)]()
[![Xcode](https://img.shields.io/badge/Xcode-16.0-blue.svg)]()

---

<br>

## 👥 멤버
| 팀원 1 | 팀원 2 | 팀원 3 | 팀원 4 | 팀원 5 |
|:------:|:------:|:------:|:------:|:------:|
| <img src="" width=120px alt="고석현"/> | <img src="" width=120px alt="김지우"/> | <img src="" width=120px alt="김영택"/> | <img src="" width=120px alt="엄민서"/> | <img src="" width=120px alt="양윤서"/> |
| [고석현](https://github.com/dev-koh) | [김지우](https://github.com/keemeoow) | [김영택](https://github.com/kim0taek) | [엄민서](https://github.com/seo1v) | [양윤서](https://github.com/yys-63) |

<br>

## 📆 프로젝트 기간
- 전체 기간: `2025.12.20 - 2025.02.20`
- 개발 기간: `2025.12.20 - 2025.02.20`

<br>

## 🤔 요구사항
For building and running the application you need:

iOS 18.2 <br>
Xcode 16.2 <br>
Swift 6.0

<br>

## ⚒️ 개발 환경
* Front : SwiftUI
* 버전 및 이슈 관리 : Github, Github Issues
* 협업 툴 : Discord, Notion

<br>

## 🔎 기술 스택
### Envrionment
<div align="left">
<img src="https://img.shields.io/badge/git-%23F05033.svg?style=for-the-badge&logo=git&logoColor=white" />
<img src="https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white" />
<img src="https://img.shields.io/badge/SPM-FA7343?style=for-the-badge&logo=swift&logoColor=white" />
</div>

### Development
<div align="left">
<img src="https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white" />
<img src="https://img.shields.io/badge/Firebase-DD2C00?style=for-the-badge&logo=Firebase&logoColor=white" />
<img src="https://img.shields.io/badge/SwiftUI-42A5F5?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Alamofire-FF5722?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Moya-8A4182?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Kingfisher-0F92F3?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Combine-FF2D55?style=for-the-badge&logo=apple&logoColor=white" />
</div>

### Communication
<div align="left">
<img src="https://img.shields.io/badge/Notion-white.svg?style=for-the-badge&logo=Notion&logoColor=000000" />
<img src="https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=Discord&logoColor=white" />
<img src="https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white" />
</div>

<br>

## 📱 화면 구성

## 🔖 브랜치 컨벤션
* `main` - 제품 출시 브랜치
* `dev` - 출시를 위해 개발하는 브랜치
* `feat/xx` - 기능 단위로 독립적인 개발 환경을 위해 작성
* `refac/xx` - 개발된 기능을 리팩토링 하기 위해 작성
* `hotfix/xx` - 출시 버전에서 발생한 버그를 수정하는 브랜치
* `chore/xx` - 빌드 작업, 패키지 매니저 설정 등
* `design/xx` - 디자인 변경
* `bugfix/xx` - 버그 수정



<br>

## 🌀 코딩 컨벤션
* 변수와 상수는 `camelCase`를 사용한다.
* 클래스, 구조체, 열거형, SwiftUI View 등의 타입은 `PascalCase`를 사용한다.

<br>


* 파라미터 이름을 기준으로 줄바꿈 한다.
```swift
let actionSheet = UIActionSheet(
  title: "정말 계정을 삭제하실 건가요?",
  delegate: self,
  cancelButtonTitle: "취소",
  destructiveButtonTitle: "삭제해주세요"
)
```

<br>

* if let 구문이 길 경우에 줄바꿈 한다
```swift
if let user = self.veryLongFunctionNameWhichReturnsOptionalUser(),
   let name = user.veryLongFunctionNameWhichReturnsOptionalName(),
  user.gender == .female {
  // ...
}
```

* View 내부는 `Properties → Body → Functions` 순으로 구성한다.`
* 나중에 추가로 작업해야 할 부분에 대해서는 `// TODO: - xxx 주석을 남기도록 한다.`
* 코드의 섹션을 분리할 때는 `// MARK: - xxx 주석을 남기도록 한다.`
* 함수에 대해 전부 주석을 남기도록 하여 무슨 액션을 하는지 알 수 있도록 한다.`
* 버튼, 입력창 등 자주 사용되는 UI는 컴포넌트로 분리하여 재사용한다.

<br>

## 📁 PR 컨벤션
* PR 시, 템플릿이 등장한다. 해당 템플릿에서 작성해야할 부분은 아래와 같다
    1. `PR 유형 작성`, 어떤 변경 사항이 있었는지 [] 괄호 사이에 x를 입력하여 체크할 수 있도록 한다.
    2. `작업 내용 작성`, 작업 내용에 대해 자세하게 작성을 한다.
    3. `스크린샷`, 작업한 화면을 스크린샷해서 올린다.
    4. `리뷰 포인트`, 본인 PR에서 꼭 확인해야 할 부분을 작성한다.
    5. `PR 태그 종류`, PR 제목의 태그는 아래 형식을 따른다.

#### 🌟 태그 종류 (커밋 컨벤션과 동일)
| 태그        | 설명                                                   |
|-------------|--------------------------------------------------------|
| [Feat]      | 새로운 기능 추가                                       |
| [Fix]       | 버그 수정                                              |
| [Refactor]  | 코드 리팩토링 (기능 변경 없이 구조 개선)              |
| [Style]     | 코드 포맷팅, 들여쓰기 수정 등                         |
| [Docs]      | 문서 관련 수정                                         |
| [Test]      | 테스트 코드 추가 또는 수정                            |
| [Chore]     | 빌드/설정 관련 작업                                    |
| [Design]    | UI 디자인 수정                                         |
| [Hotfix]    | 운영 중 긴급 수정                                      |
| [CI/CD]     | 배포 및 워크플로우 관련 작업                          |

### ✅ PR 예시 모음
>  [Chore] 프로젝트 초기 세팅 <br>
>  [Feat] 프로필 화면 UI 구현 <br>
>  [Fix] iOS 17에서 버튼 클릭 오류 수정 <br>
>  [Design] 로그인 화면 레이아웃 조정 <br>
>  [Docs] README에 프로젝트 소개 추가 <br>

<br>

## 📑 커밋 컨벤션

### 🏷️ 커밋 태그 가이드

 | 태그        | 설명                                                   |
|-------------|--------------------------------------------------------|
| [Feat]      | 새로운 기능 추가                                       |
| [Fix]       | 버그 수정                                              |
| [Refactor]  | 코드 리팩토링 (기능 변경 없이 구조 개선)              |
| [Style]     | 코드 포맷팅, 세미콜론 누락, 들여쓰기 수정 등          |
| [Docs]      | README, 문서 수정                                     |
| [Test]      | 테스트 코드 추가 및 수정                              |
| [Chore]     | 패키지 매니저 설정, 빌드 설정 등 기타 작업           |
| [Design]    | UI, CSS, 레이아웃 등 디자인 관련 수정                |
| [Hotfix]    | 운영 중 긴급 수정이 필요한 버그 대응                 |
| [CI/CD]     | 배포 관련 설정, 워크플로우 구성 등                    |

### ✅ 커밋 예시 모음
>  [Chore] 프로젝트 초기 세팅 <br>
>  [Feat] 프로필 화면 UI 구현 <br>
>  [Fix] iOS 17에서 버튼 클릭 오류 수정 <br>
>  [Design] 로그인 화면 레이아웃 조정 <br>
>  [Docs] README에 프로젝트 소개 추가 <br>

<br>

## 🗂️ 폴더 컨벤션
```
weady
├── Resources
│   ├── Fonts                // 커스텀 폰트 관련 파일
│   └── Assets.xcassets      // 이미지 및 컬러 에셋 등
│
├── Service                  // API 관련 네트워크 레이어
│   └── [API 이름 폴더]        // 예: Auth, Board, Comment 등
│       ├── Endpoints        // API Endpoint 정의
│       ├── RequestDTOs      // 요청 모델 정의
│       ├── ResponseDTOs     // 응답 모델 정의
│       └── Service          // 실제 API 호출을 담당하는 서비스 클래스
│
├── Sources
│   ├── Common               // 앱 전반에서 공통으로 사용하는 코드
│   │   ├── Components       // 공통 UI 컴포넌트 
│   │   ├── Extensions       // Swift 기본 타입,SwiftUI 확장
│   │   ├── Navigation       // 라우팅 및 네비게이션 관련 코드
│   │   └── Utilities        // Helper, Manager, Constants 등 유틸리티성 코드
│   │
│   └── Feature              // 기능 단위로 분리된 폴더 (MVVM 구조)
│       └── [Feature 이름]    // 예: Login, Weadyboard, Comment 등
│           ├── View         // SwiftUI View
│           ├── ViewModel    // 상태 및 로직 처리
│           └── Model        // 도메인 모델 정의
