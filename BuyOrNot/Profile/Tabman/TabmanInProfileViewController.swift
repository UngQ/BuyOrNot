//
//  TabmanInProfileViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/27/24.
//

import UIKit
import Tabman
import Pageboy



class TabmanInProfileViewController: TabmanViewController {

	var myOrOthers = true

	var viewControllers: [UIViewController] = []
	let myPostsVC = ContentPostViewController()
	let likePostsVC = ContentPostViewController()
	let dislikePostsVC = ContentPostViewController()

	private let baseView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .systemRed

		if myOrOthers {
			myPostsVC.collectionViewLayout = UICollectionViewFlowLayout.createThreeColumnFlowLayout(in: self.view)
			myPostsVC.viewModel.content = .myPosts


			likePostsVC.collectionViewLayout = UICollectionViewFlowLayout.createThreeColumnFlowLayout(in: self.view)
			likePostsVC.viewModel.content = .likePosts


			dislikePostsVC.collectionViewLayout = UICollectionViewFlowLayout.createThreeColumnFlowLayout(in: self.view)
			dislikePostsVC.viewModel.content = .dislikePosts

			viewControllers.append(UINavigationController(rootViewController: myPostsVC))
			viewControllers.append(UINavigationController(rootViewController: likePostsVC))
			viewControllers.append(UINavigationController(rootViewController: dislikePostsVC))
		} else {
			myPostsVC.collectionViewLayout = UICollectionViewFlowLayout.createThreeColumnFlowLayout(in: self.view)
			myPostsVC.viewModel.content = .myPosts

			viewControllers.append(UINavigationController(rootViewController: myPostsVC))


		}



		self.dataSource = self


		view.addSubview(baseView)
		baseView.snp.makeConstraints { make in
			make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
		}

		let bar = TMBar.TabBar()

		bar.backgroundView.style = .blur(style: .regular)
		bar.layout.contentInset = UIEdgeInsets.zero
//		bar.

		bar.buttons.customize { (button) in

			button.tintColor = .systemGray
			button.selectedTintColor = .textPoint
			button.font = .systemFont(ofSize: 12)
//			button.selectedFont = .boldSystemFont(ofSize: 12)
		  }
//		bar.indicator.weight = .light
		bar.indicator.tintColor = Color.black
		bar.indicator.overscrollBehavior = .compress
		bar.layout.alignment = .centerDistributed
//		bar.layout.contentMode = .fit
//		bar.layout.interButtonSpacing = 0
		bar.layout.transitionStyle = .snap

		addBar(bar, dataSource: self, at: .custom(view: baseView, layout: nil))



    }


}

extension TabmanInProfileViewController: PageboyViewControllerDataSource, TMBarDataSource {
	func numberOfViewControllers(in pageboyViewController: Pageboy.PageboyViewController) -> Int {
		viewControllers.count
	}

	func viewController(for pageboyViewController: Pageboy.PageboyViewController, at index: Pageboy.PageboyViewController.PageIndex) -> UIViewController? {
		viewControllers[index]
	}

	func defaultPage(for pageboyViewController: Pageboy.PageboyViewController) -> Pageboy.PageboyViewController.Page? {
		.first
	}

	func barItem(for bar: any Tabman.TMBar, at index: Int) -> any Tabman.TMBarItemable {
		let item = TMBarItem(title: "") // 타이틀을 비워둠
		switch index {
		case 0:
			item.image = UIImage(systemName: "tablecells") // 첫 번째 탭 아이템 이미지
		case 1:
			item.image = UIImage(systemName: "hand.thumbsup") // 두 번째 탭 아이템 이미지
		case 2:
			item.image = UIImage(systemName: "hand.thumbsdown") // 세 번째 탭 아이템 이미지
		default:
			break
		}
		return item
		}


	}

	


