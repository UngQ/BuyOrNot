
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
### 1. ImageView에 RxGesture 적용, Double Tapped 으로 좋아요/싫어요
   
https://github.com/UngQ/BuyOrNot/assets/106305918/6496eae7-2f06-47cd-b9ce-7ce43137842d
- 이미지의 가운데 x좌표를 0으로 가정, 왼쪽 영역(x < 0)을 더블탭하면 "좋아요", 오른쪽 영역(x > 0)을 더블탭하면 "싫어요" 기능이 동작하도록 구현
- 동일한 영역에 다시 투표할 경우 기존 투표를 취소
  <details>
  <summary><b>주요코드</b></summary>

  ```swift
  cell.postImageView.rx.tapGesture(configuration: { gestureRecognizer, delegate in
				gestureRecognizer.numberOfTapsRequired = 2 })
			.when(.recognized)
			.subscribe(onNext: { [weak self] gesture in
				let touchPoint = gesture.location(in: gesture.view)
				if let width = gesture.view?.bounds.width {
					if touchPoint.x < width / 2 {
						likeButtonTapped.onNext(row)
						self?.playAppropriateAnimation(for: "like", likeCondition: cell.like, dislikeCondition: cell.dislike)
					} else {
						disLikeButtonTapped.onNext(row)
						self?.playAppropriateAnimation(for: "dislike", likeCondition: cell.like, dislikeCondition: cell.dislike)
					}
				}
			})
			.disposed(by: cell.disposeBag)
  ```
    
</details>

### 2. MVVM의 효과적인 활용도를 높이기 위한 `ViewModel` Protocl 정의
- ViewModel의 인터페이스를 명확하게 정의하여 일관된 구조 유지
- Input, Output 타입을 통하여 입, 출력 명확
- RxSwift의 disposeBag을 사용한 메모리 관리
  <details>
  <summary><b>주요코드</b></summary>

  ```swift
  protocol ViewModelType {

	associatedtype Input
	associatedtype Output

	var disposeBag: DisposeBag { get set }

	func transform(input: Input) -> Output
  }
  ```
    
</details>

### 3. Router Pattern 적용하여, 효과적인 30개 이상의 API 통신 관리
- TargetType 프로토콜과 Router 열거형을 사용하여 다양한 API 엔드포인트를 정의하고, 각 요청의 세부 사항을 설정
- 네트워크 요청을 하나의 Router 열거형으로 관리함으로써 코드의 모듈화와 재사용성을 높임
- 새로운 API 엔드포인트를 추가할 때 Router 열거형에 새로운 케이스를 추가하고 필요한 속성을 정의하면 되므로, 확장성이 뛰어남
  <details>
  <summary><b>주요코드</b></summary>

  ```swift
  protocol TargetType: URLRequestConvertible {
	var baseURL: String { get }
	var method: HTTPMethod { get }
	var path: String { get }
	var header: [String: String] { get }
	var parameters: String? { get }
	var queryItems: [URLQueryItem]? { get }
	var body: Data? { get }
  }

  enum Router {
	case tokenRefresh
  }

  extension Router: TargetType {
      ...
  }

  ```
    
</details>

### 4. RxSwift의 retry(when:)을 이용한 토큰 갱신 및 통신 재시도
- 네트워크 요청이 특정 오류(예: HTTP 상태 코드 419)로 실패할 경우, 토큰을 갱신하고 원래의 요청을 다시 시도
  <details>
  <summary><b>주요코드</b></summary>

  ```swift
  static func performRequest<T: Decodable>(route: Router, decodingType: T.Type?) -> Single<T> {
    return Single<T>.create { single in
        do {
            let urlRequest = try route.asURLRequest()

            AF.request(urlRequest)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let result):
                        single(.success(result))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
        } catch {
            single(.failure(error))
        }

        return Disposables.create()
    }
    .retry(when: { errors in
        errors.flatMap { error -> Single<Void> in
            guard let afError = error as? AFError, afError.responseCode == 419 else {
                throw error
            }
            return refreshToken().flatMap { _ in
                performRequest(route: route, decodingType: T.self).map { _ in Void() }
            }
        }
    })
  }
  ```

    - performRequest<T: Decodable>: 주어진 라우트에 따라 네트워크 요청을 수행하고, 결과를 Single<T>로 반환합니다.
    - 요청이 실패하면 retry(when:) 연산자가 실행되어 오류를 검사합니다.
    - 오류가 HTTP 419 상태 코드인 경우 refreshToken() 메서드를 호출하여 토큰을 갱신합니다.
    - 토큰이 갱신되면 원래의 요청을 다시 시도합니다.
    - refreshToken(): 토큰 갱신을 처리하는 메서드로, 성공적으로 토큰이 갱신되면 Single<Void>를 반환하여 재시도를 허용합니다. 실패하면 오류를 발생시켜 재시도를 중단하고 로그인 창으로 이동하도록 합니다.

    
</details>

### 5. SocketIO 활용한 실시간 채팅 구현
- 소켓 연결 상태를 일관되게 유지하기 위하여 Singleton Pattern 적용
  <details>
  <summary><b>주요코드</b></summary>

  ```swift
  final class SocketIOManager {

	static var shared: SocketIOManager = SocketIOManager()

	var manager: SocketManager?
	var socket: SocketIOClient?

	let baseURL = URL(string: "\(APIKey.baseURL.rawValue)/v1")!

	var receivedChatData = PassthroughSubject<ChatContentModel, Never>()

	private init() {}

	func fetchSocket(roomId: String) {
		manager = SocketManager(socketURL: baseURL, config: [.log(true), .compress])

		socket = manager?.socket(forNamespace: "/chats-\(roomId)")

		socket?.on(clientEvent: .connect) { data, ack in
			print("socket connected", data, ack)
		}

		socket?.on(clientEvent: .disconnect) { data, ack in
			print("socket disconnected", data, ack)
		}

		socket?.on("chat") { dataArray, ack in
			print("chat received", dataArray, ack )

			if let data = dataArray.first {
				 do {
  					let result = try JSONSerialization.data(withJSONObject: data)
         				let decodedData = try JSONDecoder().decode(ChatContentModel.self, from: result)
  					self.receivedChatData.send(decodedData)
      				} catch {
            				print(error.localizedDescription)
       				}
			}
		}
	}

	func establishConnection() {
		socket?.connect()
	}

	func leaveConnection() {
		socket?.disconnect()
	}
  
  }
  ```
    
</details>

### 6. @propertyWrapper를 활용한 UserDefaults 캡슐화
- 자주 사용되는 UserDefaults 의 상용구 코드를 줄이고 가독성을 높이기 위하여 구현
- @propertyWrapper 속성을 적용한 MyDefaults 구조체 생성 후 UserDefaultsManager 정의
  <details>
  <summary><b>주요코드</b></summary>

  ```swift
  @propertyWrapper
  struct MyDefaults<T> {
    let key: String
    let defaultValue: T

    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
  }

  enum UserDefaultsManager {

    enum Key: String {
        case userId
        ...
    }

    @MyDefaults(key: Key.userId.rawValue, defaultValue: "")
    static var userId: String
    ...
  }

  //기존 사용법
  UserDefaults.standard.string(forKey: UserDefaultsKey.userId.key) ?? ""

  //개선된 사용법
  let myId = UserDefaultsManager.userId //get
  UserDefaultsManager.userId = "변경된닉네임" //set
  ```
    
</details>



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


