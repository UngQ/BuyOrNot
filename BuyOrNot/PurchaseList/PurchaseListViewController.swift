//
//  PurchaseListViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 5/5/24.
//

import UIKit

class PurchaseListViewController: BaseViewController {

	let viewModel = PurchaseListViewModel()

	let listTableView = UITableView(frame: .zero, style: .insetGrouped)
	weak var contentPostVCDelegate: ContentPostViewControllerDelegate?

	let emptyLabel = {
		let view = UILabel()
		view.text = "구매내역이 없습니다."
		view.font = .boldSystemFont(ofSize: 16)
		view.textAlignment = .center
		return view
	}()


	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(listTableView)

		listTableView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}

		listTableView.register(PurchaseListTableViewCell.self, forCellReuseIdentifier: PurchaseListTableViewCell.id)
		listTableView.rowHeight = 80

		viewModel.viewDidLoadTrigger.accept(())

		view.addSubview(emptyLabel)

		emptyLabel.snp.makeConstraints { make in
			make.centerY.centerX.equalToSuperview()
		}
	}

	override func bind() {

		let input = PurchaseListViewModel.Input()

		let output = viewModel.transform(input: input)

		output.data.map({ $0.data })
			.drive(with: self) { owner, data in
				if data == [] {
					owner.emptyLabel.isHidden = false

				} else {
					owner.emptyLabel.isHidden = true
				}
			}
			.disposed(by: disposeBag)


		output.data
			.map { $0.data }
			.drive(listTableView.rx.items(cellIdentifier: PurchaseListTableViewCell.id, cellType: PurchaseListTableViewCell.self)) { row, element, cell  in

				cell.nameLabel.text = element.productName
				cell.priceLabel.text = "\(element.price)원"

			}
			.disposed(by: disposeBag)

		listTableView.rx.itemSelected
			.asDriver()
			.drive(with: self) { owner, indexPath in
					owner.contentPostVCDelegate?.didSelectItem(index: indexPath.row)

			}
			.disposed(by: disposeBag)

		setupScrollBinding()
	}
	func setupScrollBinding() {

		listTableView.rx.didScroll
			  .map { [weak self] in
				  self?.listTableView.panGestureRecognizer.translation(in: self?.listTableView.superview)
			  }
			  .distinctUntilChanged() // 중복 값 필터링
			  .compactMap { $0 }
			  .subscribe(onNext: { [weak self] translation in
				  if translation.y > 0 {
					  self?.contentPostVCDelegate?.didScrollTableView(.down)
				  } else if translation.y < 0 {
					  self?.contentPostVCDelegate?.didScrollTableView(.up)
				  }
			  })
			  .disposed(by: disposeBag)
	  }
}
