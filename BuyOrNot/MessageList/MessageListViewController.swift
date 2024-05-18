//
//  MessageListViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 5/17/24.
//

import UIKit

class MessageListViewController: BaseViewController {

	let viewModel = MessageListViewModel()

	let listTableView = UITableView(frame: .zero, style: .plain)

	let emptyLabel = {
		let view = UILabel()
		view.text = "대화내역이 없습니다."
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
		listTableView.rowHeight = 60

		viewModel.viewDidLoadTrigger.accept(())

		view.addSubview(emptyLabel)

		emptyLabel.snp.makeConstraints { make in
			make.centerY.centerX.equalToSuperview()
		}
	}

	override func bind() {

		let input = MessageListViewModel.Input()

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

				cell.nameLabel.text = "🗒️ \(element.room_id)"
				cell.priceLabel.text = "\(element.participants)"

			}
			.disposed(by: disposeBag)

		listTableView.rx.itemSelected
			.asDriver()
			.drive(with: self) { owner, indexPath in
				

			}
			.disposed(by: disposeBag)


	}

}
