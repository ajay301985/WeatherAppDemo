//
//  LocationCollectionCell.swift
//  WeatherAppDemo
//
//  Created by Ajay Rawat on 2022-04-24.
//

import Foundation
import UIKit

typealias CellLoadingStyle = LocationCollectionCell.LoadingStyle

final class LocationCollectionCell: UICollectionViewCell {
	
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var title: UILabel!
	@IBOutlet var date: UILabel!
	@IBOutlet var temprature: UILabel!
	@IBOutlet var staus: UILabel!
	@IBOutlet var dateLabel: UILabel!
	
	@IBOutlet var loadingView: UIView!
	@IBOutlet var indicatorView: UIActivityIndicatorView!
	@IBOutlet var errorLabel: UILabel!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		contentView.layer.cornerRadius = Constants.cornerRadius
		contentView.layer.masksToBounds = true
		self.contentView.layer.shadowColor = UIColor.black.cgColor
	}
	
	func updateCell(with location: WeatherDisplayInfoModel, style: LoadingStyle) {
		updateCell(style: style)
		title.text = location.title
		dateLabel.text = location.date
		guard let info = location.info else { return }
		date.text = String(Int(info.temprature ?? 0))
		temprature.text = info.averageTemp
		staus.text = info.location
		imageView.load(url: (info.thumbnail?.urlRequest)!)
	}
	
	private func updateCell(style: LoadingStyle) {
		indicatorView.isHidden = true
		errorLabel.isHidden = true

		switch style {
		case .loading:
			loadingView.isHidden = false
			indicatorView.isHidden = false
			indicatorView.startAnimating()
		case .infoData:
			loadingView.isHidden = true
		case .error:
			loadingView.isHidden = false
			indicatorView.isHidden = true
			errorLabel.isHidden = false
		}
	}
	
	enum LoadingStyle {
		case loading
		case infoData
		case error
	}
	
	struct Constants {
		static let cornerRadius = 15.0
	}
}


