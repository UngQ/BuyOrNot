//
//  FollowViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/28/24.
//

import UIKit
import RxSwift

class FollowViewController: BaseViewController {

	var viewModel: ProfileViewModel?

	

	let listTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

		setNavigationTitleImage()
		print(viewModel?.profileData.value)

    }

	override func bind() {

		let input = ProfileViewModel.Input(navigationRightButtonTapped: nil)

		guard let viewModel = viewModel else { return }

		let output = viewModel.transform(input: input)

		output.data.map { $0.followers }
			.drive(listTableView.rx.items(cellIdentifier: UITableViewCell.id, cellType: UITableViewCell.self)) {
				row, element, cell in
				cell.textLabel?.text = element.nick
			}
			.disposed(by: disposeBag)

	
	}

	override func configureLayout() {
		view.addSubview(listTableView)

		listTableView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}

		listTableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.id)


	}



}
