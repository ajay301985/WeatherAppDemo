//
//  ViewController.swift
//  WeatherAppDemo
//
//  Created by Ajay Rawat on 2022-04-24.
//

import UIKit
import SwiftUI

class ViewController: UICollectionViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		viewModel.dataLoaded = { [weak self] details, indexOb, cellStyle in
			DispatchQueue.main.async {
			if let collectionCell = self?.collectionView.cellForItem(at: indexOb) as? LocationCollectionCell {
				collectionCell.updateCell(with: details, style: cellStyle)
			}
			}
		}
	}
	
	private let viewModel = CollectionViewModel(with: Date.nextDate, service: LocationService())

}

extension ViewController {

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		viewModel.numberOfRows
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell: LocationCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationCellIdentifier", for: indexPath) as? LocationCollectionCell
		else {
			fatalError("Failed to init")
		}
		
		let weatherInfo = viewModel.weatherData1(for: indexPath)
		cell.updateCell(with: weatherInfo.0, style: weatherInfo.1)
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let details = viewModel.weatherDetails(at: indexPath) else { return }
		let detailsView = WeatherDetailView(weatherDetails: details)
		let detailController = UIHostingController(rootView: detailsView)
		present(detailController, animated: true, completion: nil)
	}
}
