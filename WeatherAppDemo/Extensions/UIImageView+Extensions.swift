//
//  UIImageView+Extensions.swift
//  WeatherAppDemo
//
//  Created by Ajay Rawat on 2022-04-24.
//

import Foundation
import UIKit

extension UIImageView {
	func load(url: URL) {
		DispatchQueue.global().async { [weak self] in
			guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
				return
			}
			DispatchQueue.main.async {
				self?.image = image
			}
		}
	}
}
