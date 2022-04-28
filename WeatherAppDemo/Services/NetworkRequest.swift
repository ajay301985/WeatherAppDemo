//
//  NetworkRequest.swift
//  WeatherAppDemo
//
//  Created by Ajay Rawat on 2022-04-28.
//

import Foundation

protocol PathableUrl {
		var baseUrlString: String { get }
}

enum ServiceRequestUrlString: PathableUrl {
	var baseUrlString: String {
		switch self {
		case .fetchWeather(let location):
			return "https://www.metaweather.com/api//location/search/?query=\(location)"
		case .fetchWeatherInfo(let weid):
			return "https://www.metaweather.com//api/location/\(weid)"
		case .imageUrl(let locationId):
			 return "https://www.metaweather.com/static/img/weather/png/64/\(locationId).png"
		}
	}

		case fetchWeather(location: String)
		case fetchWeatherInfo(weid: Int)
		case imageUrl(locationId: String)
}

struct NetworkRequestUrl {
	private let urlString: String
	init(with url: ServiceRequestUrlString) {
		urlString = url.baseUrlString
	}
	
	var urlRequest: URL {
		let escapedAddress = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
		guard let urladdress = escapedAddress, let url = URL(string: urladdress) else {
			fatalError("Invalid URL")
		}
		return url
	}
}
