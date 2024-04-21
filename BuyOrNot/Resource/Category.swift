//
//  Category.swift
//  BuyOrNot
//
//  Created by ungQ on 4/21/24.
//

import Foundation

enum Category: String {

	case top
	case bottom
	case shoes
	case acc

	var title: String {
		switch self {
		case .top:
			"상의 (Top)"
		case .bottom:
			"하의 (Bottom)"
		case .shoes:
			"신발 (Shoes)"
		case .acc:
			"악세사리 (Acc)"
		}
	}

	var hashTag: String {
		switch self {
		case .top:
			"#Top"
		case .bottom:
			"#Bottom"
		case .shoes:
			"#Shoes"
		case .acc:
			"#Acc"
		}
	}
}
