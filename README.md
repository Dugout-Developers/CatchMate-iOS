# CatchMate-iOS
![앱 소개 이미지](https://github.com/user-attachments/assets/125c11b8-c591-4ef6-99b9-4c3b1f70e148)


## 📌 프로젝트 소개
> 2024.06.01 ~ (진행중) <br/>
- 같은 팀을 응원하는 사람들을 만나 직관하고 싶은 혼직관러, 혹은 갑자기 빈 티켓 자
리를위한 사람들을 위한 KBO 직관 친구 구하기 APP
- 앱스토어 링크: https://apps.apple.com/kr/app/catchmate/id6504273234

<br/><br/>

## 📌 기능 소개
**로그인 / 회원가입**
- 카카오톡, 네이버, 애플 로그인을 통한 간편 로그인 기능 제공합니다.
- 회원가입 절차를 통해 앱 사용 시 나와 잘 맞는 사용자를 찾을 수 있도록 응원팀, 응원 스타일 등의 부가 정보를 입력할 수 있습니다.

**Post**
- 사용자들이 올린 직관 친구 구하기 Post를 확인할 수 있습니다.
- 원하는 날짜, 구단, 인원 수 필터를 통해 사용자가 원하는 Post를 검색할 수 있습니다.
- 사용자가 직접 원하는 조건의 Post를 등록하여 직관 친구를 찾을 수 있습니다.

**직관 신청 및 수락**
- 게시글 정보 및 게시글 작성자의 정보(응원 구단, 응원 스타일, 나이대, 성별)을 확인하여 나에게 딱 맞는 게시물에 직관 신청을 할 수 있습니다.
- 게시물 작성자는 신청자 정보(응원 구단, 응원 스타일, 나이대, 성별)를 확인하여 나에게 딱 맞는 친구를 선택하여 직관 모임을 주도할 수 있습니다.

**채팅**
- 게시글 작성자에 의해 수락된 사용자들은 게시글 단톡방에 자동 참여되어 실시간으로 채팅을 주고받으며 직관 계획 등 메시지를 나눌 수 있습니다.
- 채팅방 정보를 확인하여 본인 외의 다른 직관 참여자들의 정보를 확인할 수 있습니다.
- 채팅방 정보 제공 시 해당 게시글 정보를 같이 제공하여, 어떤 직관의 채팅방인지 확인할 수 있습니다.

**마이페이지**
- 마이페이지에서는 공지사항, 고객센터와 같은 지원 메뉴, 계정 및 앱 내 설정 메뉴를 제공합니다.
- 마이페이지에서는 기본 메뉴 외에 "직관 생활"이라는 메뉴를 제공하여 내가 작성한 글, 보낸 신청, 받은 신청을 확인할 수 있습니다.
- 상대방 프로필을 확인 시 상대방의 정보와 상대방이 작성한 글을 확인할 수 있습니다. 

<br/><br/>


## 📌 개발 도구 및 기술 스택
#### 개발환경
- Swift 5.10, Xcode 15.3, iOS 16.0 이상
#### 협업도구
- Figma, Github, Team Notion, Discord
#### 기술스택
- UIkit
- Clean Architeture + MVVM
- RxSwift, ReactorKit, SnapKit, PinLayout, FlexLayout, Kingfisher, RxAlamofire
- Starscream
- Firebase Cloud Messaging, Firebase App Distribution

<br/><br/>
## 📌 Folder Convention
```
📦 CatchMate
+-- 🗂 APP
+-- 🗂 Resources 
+-- 🗂 Utilities 
|    +-- 🗂 Font
|    +-- 🗂 Extensions
|    +-- 🗂 Constraints
|    +-- 🗂 Service
|    +-- 🗂 Helpers
|    +-- 🗂 UtilitiesDTO
+-- 🗂 Service
+-- 🗂 Common
|    +-- 🗂 Constraints
|    +-- 🗂 View
|    +-- 🗂 Transition
+-- 🗂 Presentaions 
|    +-- 🗂 View
|    +-- 🗂 ViewModel
+-- 🗂 Domain
|    +-- 🗂 Model
|    +-- 🗂 UseCases
|    +-- 🗂 Repositories
+-- 🗂 Data
|    +-- 🗂 DTO 
|    +-- 🗂 Mapper 
|    +-- 🗂 Repositories
|    +-- 🗂 DataSources 
+-- 🗂 DesignSystem
```
