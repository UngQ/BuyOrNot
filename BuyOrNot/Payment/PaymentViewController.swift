//
//  PaymentViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 5/3/24.
//

import UIKit
import WebKit
import iamport_ios
import RxSwift
import RxCocoa

final class PaymentViewController: BaseViewController {


	let disposebag = DisposeBag()

	lazy var wkWebView: WKWebView = {
		var view = WKWebView()
		view.backgroundColor = UIColor.clear
		return view
	}()

	var element = PostModel(post_id: "", product_id: "", title: "", content: "", content1: "", createdAt: "", creator: CreatorModel(user_id: "", nick: "", profileImage: nil), files: [], likes: [], likes2: [], hashTags: [], comments: [], buyers: [])

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)


	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(wkWebView)
		wkWebView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}
		setupPaymentProcess()

	}

	func setupPaymentProcess() {
		let payment = IamportPayment(
			pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"), // PG 사
			merchant_uid: "ios_\(APIKey.sesacKey)_\(Int(Date().timeIntervalSince1970))",                   // 주문번호
			amount: element.content1.numericString()).then {                        // 가격
				$0.pay_method = PayMethod.card.rawValue                     // 결제수단
				$0.name = element.title               // 주문명
				$0.buyer_name = "이승환"
				$0.app_scheme = "buyOrNot"                   // 결제 후 앱으로 복귀 위한 app scheme
			}

		Iamport.shared.paymentWebView(webViewMode: wkWebView,
									  userCode: "imp57573124",
									  payment: payment) {  [weak self] response in
			guard let self = self else { return }

			if let success = response?.success, success {
				if let imp_uid = response?.imp_uid,
				   let price = Int(element.content1.numericString()) {
					let query = BuyerQueryAndModel(imp_uid: imp_uid,
												   post_id: element.post_id,
												   productName: element.title,
												   price: price)

					print(query)

					NetworkManager.performRequestVoidType(route: .validationPayment(query: query))
						.catch({ error in
							print(error.localizedDescription)

							return .never()
						})
						.subscribe(with: self) { owner, result in

							UIViewController.changeRootView(to: CustomTabBarController(), isNav: true)
						}
						.disposed(by: self.disposebag)
				}
			} else {
				errorAlert()
			}
		}

	}
	func errorAlert() {
			let alertController = UIAlertController(title: "결제 오류", message: "결제를 다시 시도해주세요.", preferredStyle: .alert)
			let logoutAction = UIAlertAction(title: "확인", style: .cancel) { _ in

				self.navigationController?.popViewController(animated: true)

			}

			alertController.addAction(logoutAction)

			self.present(alertController, animated: true)
		}





}
