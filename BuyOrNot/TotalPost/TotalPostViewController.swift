//
//  TotalPostViewController.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher



class TotalPostViewController: BaseViewController {

	let viewModel = TotalPostViewModel()

	
	let tableView = UITableView()
	

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		print("GGG")
		viewModel.viewWillAppearTrigger.accept(())
		tableView.reloadData()
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		navigationItem.title = "Asdf"

    }

	override func bind() {


		let input = TotalPostViewModel.Input()

		let output = viewModel.transform(input: input)

		output.data
			.drive(tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) {
				row, element, cell in
				cell.textLabel?.text = "\(element.title) / \(element.content1)"

				cell.imageView?.image = UIImage(systemName: "pencil")

				guard let test = element.files, test != [""] else { return }
				let image = "\(APIKey.baseURL.rawValue)/v1/\(test[0])"

				cell.imageView?.kf.setImage(with: URL(string: image), options: [.requestModifier(NetworkManager.imageDownloadRequest)], completionHandler: { response in
					switch response {
					case .success(let data):
						DispatchQueue.main.async {
							cell.imageView?.image = data.image

							cell.layoutSubviews() // Refresh cell layout if needed
						}
					case .failure(let error):
						print("Error setting image: \(error)")
						DispatchQueue.main.async {
							cell.imageView?.image = UIImage(systemName: "exclamationmark.triangle") // Fallback image in case of error
						}
					}
				}
				)

//				KingfisherManager.shared.retrieveImage(with: URL(string: image)!, options: [.requestModifier(self.imageDownloadRequest)], completionHandler: { result in
//
//				})


			}
			.disposed(by: disposeBag)

		tableView.rx.itemSelected
			.bind(with: self) { owner, indexPath in
				owner.navigationController?.pushViewController(TotalPostViewController(), animated: true)
			}
			.disposed(by: disposeBag)
	}

	override func configureLayout() {
		view.addSubview(tableView)

		tableView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide)
			make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
		}

		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
	}


}
