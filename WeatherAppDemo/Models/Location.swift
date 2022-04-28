//
//  Location.swift
//  WeatherAppDemo
//
//  Created by Ajay Rawat on 2022-04-24.
//

import Foundation

typealias WeatherId = LocationModel.LocationID
typealias WeatherDetails = LocationModel.WeatherInfo
typealias WeatherConsolidateDetails = LocationModel.WeatherInfo.Consolidated_weather

struct LocationModel: Decodable {
	struct LocationID: Decodable {
		let woeid: Int
	}
	
	struct WeatherInfo: Decodable {
		let title, timezone: String
		let woeid: Int
		let consolidated_weather: [Consolidated_weather]
		struct Consolidated_weather: Decodable, Identifiable {
			let id: Int
			let weather_state_name, weather_state_abbr: String
			let applicable_date: String
			let min_temp, max_temp, the_temp: Float
			let humidity,wind_direction,air_pressure: Float
			var imageUrl: NetworkRequestUrl {
				return NetworkRequestUrl(with: .imageUrl(locationId: weather_state_abbr))
			}
		}
	}
}

struct WeatherDisplayInfoModel {
	let title: String
	let date: String
	var info: WeatherInformation?
	
	struct WeatherInformation {
		let temprature: Float?
		let averageTemp: String?
		let location: String?
		let thumbnail: NetworkRequestUrl?
	}
	
	mutating func updateInfo(details: WeatherDetails) {
		guard let detailInfo = details.consolidated_weather.first(where: {
			$0.applicable_date == self.date
		}) else {
			return
		}
		self.info = WeatherInformation(temprature: detailInfo.the_temp, averageTemp: "H:\(String(Int(detailInfo.max_temp))), L:\(String(Int(detailInfo.min_temp)))", location: detailInfo.weather_state_name, thumbnail: detailInfo.imageUrl)
	}
	
	init(with locationName: String, applicableDate: String) {
		self.title = locationName
		self.date = applicableDate
		self.info = nil
	}
}
