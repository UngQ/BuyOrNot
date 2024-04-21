////
////  TabManController.swift
////  BuyOrNot
////
////  Created by ungQ on 4/18/24.
////
//
//import UIKit
//import Tabman
//import Pageboy
//import RxSwift
//
//class TabManController: TabmanViewController {
//
//	let disposeBag = DisposeBag()
//
//	private let baseView = UIView()
//
//	var viewControllers: [UIViewController] = []
//
//	private let totalVC = UINavigationController(rootViewController: PostViewController())
//	private let topVC = ContentPostViewController()
//	private let bottomVC = ContentPostViewController()
//	private let shoesVC = ContentPostViewController()
//	private let accVC = ContentPostViewController()
//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//
//		viewControllers.append(totalVC)
//		viewControllers.append(topVC)
//		viewControllers.append(bottomVC)
//		viewControllers.append(shoesVC)
//		viewControllers.append(accVC)
//
//		self.dataSource = self
//
//		view.addSubview(baseView)
//
//		baseView.snp.makeConstraints { make in
//			make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
//			make.height.equalTo(72)
//		}
//
//
//
//		let bar = TMBar.ButtonBar()
////		bar.backgroundView.style = .clear
//		bar.layout.transitionStyle = .snap
//
//		bar.layout.alignment = .centerDistributed
//		bar.layout.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//		bar.layout.contentMode  = .fit
//
//
//		bar.backgroundColor = .viewPoint
//
//		bar.buttons.customize { (button) in
//			button.tintColor = .systemGray
//			button.selectedTintColor = .textPoint
//			button.font = .systemFont(ofSize: 16)
//			button.selectedFont = .boldSystemFont(ofSize: 16)
//		}
//
//		bar.indicator.weight = .custom(value: 2)
//		bar.indicator.tintColor = .textPoint
////		bar.indicator.overscrollBehavior = .none
//
//		addBar(bar, dataSource: self, at: .custom(view: baseView, layout: nil))
//	}
//}
//
//extension TabManController: PageboyViewControllerDataSource, TMBarDataSource {
//	func numberOfViewControllers(in pageboyViewController: Pageboy.PageboyViewController) -> Int {
//		viewControllers.count
//	}
//	
//	func viewController(for pageboyViewController: Pageboy.PageboyViewController, at index: Pageboy.PageboyViewController.PageIndex) -> UIViewController? {
//		viewControllers[index]
//	}
//	
//	func defaultPage(for pageboyViewController: Pageboy.PageboyViewController) -> Pageboy.PageboyViewController.Page? {
//		nil
//	}
//	
//	func barItem(for bar: any Tabman.TMBar, at index: Int) -> any Tabman.TMBarItemable {
//		switch index {
//		case 0:
//			return TMBarItem(title: "전체")
//		case 1:
//			return TMBarItem(title: "상의")
//		case 2:
//			return TMBarItem(title: "바지")
//		case 3:
//			return TMBarItem(title: "신발")
//		case 4:
//			return TMBarItem(title: "악세사리")
//		default:
//			return TMBarItem(title: "")
//		}
//	}
//}
//
