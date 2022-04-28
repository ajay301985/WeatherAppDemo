//
//  CollectionViewModel.swift
//  WeatherAppDemo
//
//  Created by Ajay Rawat on 2022-04-25.
//

import Foundation
import Combine

/// This viewmodel class this responsible to fetch data from services and make it available to the view controller

final class CollectionViewModel {

	var dataLoaded:((_ details:WeatherDisplayInfoModel, _ indexObj:IndexPath,
									 _ style: CellLoadingStyle) -> Void)?

	var numberOfRows: Int {
		return weatherInfoList.count
	}

	private var cancellables = Set<AnyCancellable>()
	private var weatherData: [WeatherDetails] = []
	private var weatherInfoList: [WeatherDisplayInfoModel] = []
	private let locationService: LocationServiceProtocol
	private var fetchDate: Date = Date()
	private var requestDate: String {
			return fetchDate.formattedDate
	}
	
	init(with fetchDate: Date = Date(), service: LocationServiceProtocol) {
		self.fetchDate = fetchDate
		self.locationService = service
		loadInitialData()
	}
	
	func weatherData1(for indexPath: IndexPath) -> (WeatherDisplayInfoModel, CellLoadingStyle) {
		var miniInfo = weatherInfoList[indexPath.row]
		updateDetailInformation(for: &miniInfo)
		if miniInfo.info == nil {
			fetchWeatherData(miniInfo, indexPath)
		}
		return (miniInfo, (miniInfo.info != nil) ? .infoData : .loading)
	}
	
	func updateWeatherData(for indexPath: IndexPath) {
		var miniInfo = weatherInfoList[indexPath.row]
		updateDetailInformation(for: &miniInfo)
		self.dataLoaded?(miniInfo, indexPath, .infoData)
	}
	
	func weatherDetails(at indexPath: IndexPath) -> WeatherDetails? {
		let miniInfo = weatherInfoList[indexPath.row]
		return weatherData.first(where: { $0.title == miniInfo.title})
	}
}

extension CollectionViewModel {
	
	private func loadInitialData () {
		let locations = ["Gothenburg","Stockholm","Mountain View","London","New York","Berlin"]
		let weatherData = locations.map { name in
			WeatherDisplayInfoModel(with: name, applicableDate: requestDate)
		}
		weatherInfoList = weatherData
	}
	
	private func updateDetailInformation(for weather: inout WeatherDisplayInfoModel) {
		guard let locationData = weatherData.first(where: { location in
			location.title == weather.title
		}) else { return }
		weather.updateInfo(details: locationData)
	}
	
	private func fetchWeatherData(_ weather: WeatherDisplayInfoModel, _ indexPath: IndexPath) {
		locationService.fetchWeather(for: weather.title)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { completion in
				switch completion {
				case .failure(_):
					self.dataLoaded?(weather, indexPath, .error)
				case .finished:
					break
				}
			}, receiveValue: {
				guard let details = $0.first else { return }
				self.weatherData.append(details)
				self.updateWeatherData(for: indexPath)
			}
			)
			.store(in: &cancellables)
	}
}

extension Date {
	var formattedDate: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		let dateString = formatter.string(from: self)
		return dateString
	}
	
	static var nextDate: Date {
		Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
	}
}
