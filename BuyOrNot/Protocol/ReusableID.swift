//
//  ReusableID.swift
//  BuyOrNot
//
//  Created by ungQ on 4/14/24.
//

import UIKit

extension UIView: ReusableID {

}

protocol ReusableID {

}

extension ReusableID {
	static var id: String {
		return String(describing: self)
	}
}
