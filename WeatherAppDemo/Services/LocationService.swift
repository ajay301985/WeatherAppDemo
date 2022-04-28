//
//  LocationService.swift
//  WeatherAppDemo
//
//  Created by Ajay Rawat on 2022-04-24.
//

import Foundation
import Combine

protocol LocationServiceProtocol {
	func fetchWeather(for location: String) -> AnyPublisher<[WeatherDetails], Error>
}

protocol WeatherServiceProtocol {
	func getWeatherInfo(request: NetworkRequestUrl) -> AnyPublisher<[WeatherDetails], Error>
	func weatherDetails(
		for weather: WeatherId
	) -> AnyPublisher<WeatherDetails, Error>
}

class LocationService: LocationServiceProtocol {
	
	func fetchWeather(for location: String) -> AnyPublisher<[WeatherDetails], Error> {
		getWeatherInfo(request: NetworkRequestUrl(with: .fetchWeather(location: location)))
	}
}

extension LocationService: WeatherServiceProtocol {
	internal func getWeatherInfo(request: NetworkRequestUrl) -> AnyPublisher<[WeatherDetails], Error> {
		return URLSession.shared
			.dataTaskPublisher(for: request.urlRequest)
			.tryMap { data, response -> [WeatherId] in
									guard
											let response = response as? HTTPURLResponse,
											(200..<300).contains(response.statusCode)
									else {
											throw StatusError.networkError
									}
				return try JSONDecoder().decode([WeatherId].self, from: data)
			}
//			.map(\.data)
//			.decode(
//				type: [WeatherId].self,
//				decoder: JSONDecoder()
//			)
			.flatMap(loadWeatherDetails)
			.eraseToAnyPublisher()
		
	}
	
	private func loadWeatherDetails(
		for entries: [WeatherId]
	) -> AnyPublisher<[WeatherDetails], Error> {
		entries.publisher
			.flatMap(weatherDetails)
			.collect()
			.eraseToAnyPublisher()
	}
	
	internal func weatherDetails(
		for weather: WeatherId
	) -> AnyPublisher<WeatherDetails, Error> {
		let request = NetworkRequestUrl(with: .fetchWeatherInfo(weid: weather.woeid))
		return URLSession.shared.dataTaskPublisher(for: request.urlRequest)
			.tryMap { data, response -> WeatherDetails in
									guard
											let response = response as? HTTPURLResponse,
											(200..<300).contains(response.statusCode)
									else {
											throw StatusError.networkError
									}
				return try JSONDecoder().decode(WeatherDetails.self, from: data)
			}
//			.map(\.data)
//			.decode(
//				type: WeatherDetails.self,
//				decoder: JSONDecoder()
//			)
			.eraseToAnyPublisher()
	}
}

enum StatusError: Error {
		case networkError

		var localisedDescription: String {
				switch self {
				case .networkError:
						return "Unable to fetch the status"
				}
		}

		var debugDescription: String {
				switch self {
				case .networkError:
						return "Failed to get the data"
				}
		}
}
