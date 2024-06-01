
# 🕹️ Buy Or Not (살까요? 말까요?)

- 프로젝트 기간: 2024. 04. 13. ~ 2024. 05. 05.

![Apple iPhone 11 Pro Max Presentation](https://github.com/UngQ/BuyOrNot/assets/106305918/5f6be77b-a128-4039-b154-bdbae6d9f325)

## 🗒️ Introduction

- 살지 말지 고민되는 패션 아이템을 공유하여 함께 투표한 결과로 쇼핑 결정에 도움이 될 수 있는 어플
- SeSAC iOS 4기 Light Service Level Project(LSLP) 경진대회 3등 수상
- Configuration: iOS 16.0+ / 라이트모드 지원

## 🗒️ Features

- 회원가입 로직 구현 (이메일, 비밀번호 등 정규식 검사) 및 수정, 탈퇴, 로그인, 로그아웃
- 포스트 업로드 / 삭제 / 조회
- 포스트 좋아요 / 싫어요
- 해시태그 검색 / 특정 게시물 조회
- 댓글 작성 / 수정 / 삭제 / 조회
- 프로필 조회 ( 팔로우, 팔로워 / 작성한 게시물 / 좋아요한 게시물 / 싫어요한 게시물 / 결제한 게시물 조회 )
- 팔로우 / 언팔로우
- 포트원 활용한 결제

### Update (2024. 05. 24.)
- 1:1 채팅방 개설 / 내 채팅방 조회 / 채팅방 대화 내역 조회 / 소켓 활용한 실시간 대화

## 🗒️ Technology Stack

- Framework
    - **UIKit (RxSwift 기반)**
      
- Pattern
    - **MVVM**
      - UI와 비즈니스 로직을 분리하여 유지보수와 테스트가 용이하도록 하기 위해 MVVM 패턴을 사용
    
- Library
  - **비동기 및 반응형 프로그래밍**
    - **RxSwift**
      - 비동기 프로그래밍과 데이터 스트림을 관리하는 데 있어서 효율적이고 간결한 코드를 작성을 위해 사용
    - **RxGesture**
      - RxSwift와 연동하여, 제스처 인식을 쉽게 처리하기 위해 사용

  - **네트워크**
    - **Alamofire**
      - 네트워크 요청을 간편하고 효율적으로 처리하기 위해 사용
        
  - **이미지 처리**     
    - **Kingfisher**
      - 이미지를 다운로드하고 캐싱하는 작업을 간편하게 처리하기 위해 사용
     
  - **보안 및 인증**  
    - **KeychainSwift**
      - 사용자 인증 정보를 안전하게 저장하고 자동 로그인 기능을 구현하기 위해 사용
     
  - **결제**
    - **iamport-ios**
      - 결제 기능을 쉽게 통합하고 관리하기 위해 사용
     
  - **애니메이션**
    - **Lottie**
      - 애니메이션을 쉽게 구현하여 사용자 경험을 향상시키기 위해 사용
     
  - **UI 구성**
    - **Tabman**
      - 직관적이고 사용하기 쉬운 탭 인터페이스를 제공하기 위해 사용
    - **Snapkit**
      - 오토 레이아웃을 코드로 쉽게 작성하고 관리하기 위해 사용
    - **Toast**
      - 사용자에게 간단한 팝업 메시지를 표시하여 인터페이스를 직관적으로 만들기 위해 사용
    - **IQKeyboardManager**
      - 키보드가 나타날 때 UI를 자동으로 조정하여 사용성 향상을 위해 사용
    
## 👍🏻👎🏻 Key Feature 
https://github.com/UngQ/BuyOrNot/assets/106305918/6496eae7-2f06-47cd-b9ce-7ce43137842d
- RxGesture를 활용하여 이미지의 가운데 x좌표를 0으로 가정 <br>
  사용자가 이 기준선을 기준으로 왼쪽 영역(x < 0)을 더블터치하면 "좋아요" 기능이, <br>
  오른쪽 영역(x > 0)을 더블터치하면 "싫어요" 기능이 동작하도록 구현
- 동일한 영역에 다시 투표할 경우 기존 투표를 취소


## 🎮 주요 기능 Previews

### - 채팅 기능 ( Updated at 2024. 05. 24. )

![Simulator Screen Recording - iPhone 15 Pro - 2024-05-24 at 12 38 06](https://github.com/UngQ/BuyOrNot/assets/106305918/611aa623-8a7c-48b6-b583-c4cb8e27cdeb)

- 내 채팅방 목록 전체 조회
- 채팅방 진입시, 대화 내역 조회 및 소켓 통신 활성화 후 실시간 대화 기능
- Disappear 시점에, 소켓 통신 disconnect

![Simulator Screen Recording - iPhone 15 Pro - 2024-05-24 at 12 38 45](https://github.com/UngQ/BuyOrNot/assets/106305918/fa615597-3659-403b-821c-4577c289fee8)

- 다른 유저 프로필에서 대화 버튼 클릭시, 채팅방 개설 후 진입
- 이미 있을 경우도 기존 채팅방 진입 후 대화 내역 조회

### - 회원가입 ~ 탈퇴

|![회원가입-탈퇴](https://github.com/UngQ/BuyOrNot/assets/106305918/bf3eac4e-b716-4d4a-a7a8-4d834992be02)|![자동로그인](https://github.com/UngQ/BuyOrNot/assets/106305918/7e1bb436-695b-4c23-ba44-a97a26b29437)|![프로필수정](https://github.com/UngQ/BuyOrNot/assets/106305918/4063fbf8-b3bc-40b1-a723-f7ec3e379997)|![게시글작성-삭제](https://github.com/UngQ/BuyOrNot/assets/106305918/6abe442d-5266-4b6c-a485-2f33f7d16d1a)|
|:--:|:--:|:--:|:--:|
|회원가입 ~ 탈퇴|Keychain 활용한 자동로그인|프로필 수정|포스트 CRUD|



- 회원가입 API
- 이메일 중복체크 API
- NSPredicate를 활용한 이메일 형식,
비밀번호 형식, 닉네임 자체 정규식 검사
- 가입 성공시, 전체 게시물 조회뷰로 이동
- 회원 탈퇴
    - 탈퇴시, 가입/로그인시 저장된 계정 비밀번호 확인 검사 후 진행하도록 구현

### - 자동 로그인 On/Off


- KeychainSwift 를 활용한 자동로그인 기능
    - 로그인시 자동로그인 체크
    - refreshToken 만료 후 로그인창으로 이동시, 사용자의 별도 입력 없이 자동로그인

### - 프로필 수정

- 프로필 수정
    - 이미지 수정 기능
        - 이미지 삭제 API 지원하지 않아, [기본 프로필 이미지] 선택시 지정해놓은 System UIImage로 업로드하도록 구현
    - 닉네임 수정 기능
        - 회원가입시 적용한 닉네임 필터링 동일하게 적용

### - 게시글 작성 (이미지 업로드), 삭제

- 이미지 업로드
    - 업로드할 카테고리 선택
        - 카테고리를 Content에 저장하도록 구현하여, Hashtag 검색으로 활용함
    - 갤러리 / 카메라 / 네이버 검색 으로 이미지 업로드 진행
- 게시글 작성
    - 이미지 업로드 후 게시글 작성 뷰로 이동
    - Price TextField에는 숫자만 입력가능,
    입력시 자동 decimal 및 [원] 입력
- 게시글 삭제
    - 내가 작성한 게시글에서만 상단에 
    삭제 버튼 활성화
    - 삭제 후 새로고침


|![Simulator Screen Recording - iPhone 15 Pro - 2024-05-05 at 11 05 03](https://github.com/UngQ/BuyOrNot/assets/106305918/1b06e0a5-432c-483b-8684-9a5f1dfc976a)|![내프로필](https://github.com/UngQ/BuyOrNot/assets/106305918/5cdcfa4e-f32a-4230-922a-38666f0f9891)|![다른프로필](https://github.com/UngQ/BuyOrNot/assets/106305918/6d5e2610-a853-4ca8-9da3-99c80a76dd61)|![팔로우](https://github.com/UngQ/BuyOrNot/assets/106305918/c0d82806-0adb-46dc-95de-a3bd31c045e7)|
|:--:|:--:|:--:|:--:|
|포스트 좋아요/싫어요|내 프로필 조회|다른 유저 프로필 조회|팔로우|


### - 게시글 Like / DisLike

- 게시글 좋아요(사세요) / 싫어요(마세요) 기능
    - 미투표시, 결과 Hidden
    - 위,아래 엄지버튼 클릭시 투표
    - 이미지 넓이 절반 기준,
    왼쪽 Double Tap ⇒ 좋아요 
    오른쪽 Double Tap ⇒ 싫어요
    - Lotti 활용하여, 투표 성공을 직관적으로 표현

### - 내 프로필 조회

- 내 프로필 조회
    - 내가 작성한 게시글 조회
    - 좋아요/싫어요 한 게시글 조회
    - 내 팔로워
        - 내 팔로잉 목록과 비교 후 버튼 분기처리 (언팔/팔로우)
    - 내 팔로잉
        - 팔로잉 삭제(언팔) 버튼
    - 내 구매목록(결제내역) 조회

### - 다른 유저 프로필 조회

- 상대 프로필 조회
    - 작성한 게시글 조회
    - 팔로워 조회, 팔로잉 조회
        - [나] 팔로우 버튼 Hidden
        내 팔로잉과 비교 후 언팔/팔로우 분기처리
        
### - 팔로우 기능

- 상대 프로필 조회
    - 내 프로필과 비교 후 Navigation Right Button 언팔/팔로우 분기처리


|![카테고리조회-사용자별조회](https://github.com/UngQ/BuyOrNot/assets/106305918/fa9d0656-0ee1-4a96-87ff-9bcaa4cdb411)|![댓글](https://github.com/UngQ/BuyOrNot/assets/106305918/13d22eb9-6ff6-4a4a-8e19-6a536a1e7209)|![Simulator Screen Recording - iPhone 15 Pro - 2024-05-05 at 20 07 20](https://github.com/UngQ/BuyOrNot/assets/106305918/c98d45f5-a6be-44a0-aa6f-3272005e1947)|
|:--:|:--:|:--:|
|게시물 조회|댓글 작성, 삭제, 수정|결제 기능|


### - 게시물 조회

- Hashtag 활용한 카테고리 조회
    - Post 작성시, content에 입력한 category를 활용한 hashtag 검색 조회
- 특정 게시물 조회
    - hashtag 검색된 게시글 디테일 조회
    및 작성자 프로필 조회
    
### - 댓글 작성, 삭제, 수정


- 댓글 작성 / 삭제 / 수정
    - 각 게시물의 고유 ID와 댓글의 고유 ID를 
    활용한 댓글 작성, 삭제, 수정 기능
    - 금일 작성한 댓글은 방금, 15분전, 10시간 전 등으로 표시 (게시물에도 적용)
    
### - 결제 기능


- 포트원 활용한 결제 기능
- 결제 완료 후, 결제 영수증 검증 API 통하여 서버에 구매 처리 요청
- 구매내역이 생긴 Post는 [판매완료] 처리
- 내 프로필에서 구매내역 확인
- 판매완료된 내 게시글의 삭제 버튼 위치 분기처리


