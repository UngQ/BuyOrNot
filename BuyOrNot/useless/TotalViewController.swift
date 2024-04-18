////
////  TotalViewController.swift
////  BuyOrNot
////
////  Created by ungQ on 4/18/24.
////
//
//import UIKit
//
//class TotalViewController: BaseViewController {
//
//	private var containerView = UIView()
//	let tabManVC = TabManController()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//		view.addSubview(containerView)
//		containerView.addSubview(tabManVC.view)
//
//		containerView.snp.makeConstraints { make in
//			make.top.equalTo(view.safeAreaLayoutGuide)
//			make.bottom.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
//		}
//
//		tabManVC.view.snp.makeConstraints { make in
//			make.edges.equalToSuperview()
//		}
//
////		let test = tabManVC.viewControllers[0] as? TotalPostViewController
////
////
////		test?.tableView.rx.itemSelected
////			.bind(with: self) { owner, indexPath in
////				owner.navigationController?.pushViewController(SignInViewController(), animated: true)
////			}
////			.disposed(by: disposeBag)
//
//    }
//
//
//}
