//
//  WeatherAppDemoTests.swift
//  WeatherAppDemoTests
//
//  Created by Ajay Rawat on 2022-04-24.
//

import XCTest
import Combine

@testable import WeatherAppDemo

class WeatherAppDemoTests: XCTestCase {

	private var serviceTest: LocationServiceTest = LocationServiceTest()
	private var fetchFormattedDate = Date.nextDate.formattedDate
	var collectionViewModel: CollectionViewModel!
    override func setUpWithError() throws {
			collectionViewModel = CollectionViewModel(with: Date.nextDate, service: serviceTest)
    }

		func testInitialDataCount() throws {
			 XCTAssertEqual(collectionViewModel.numberOfRows, 6)
		}
	
	func testFormattedDate() throws {
		let formattedDate = Date().formattedDate
		let date = Date()
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		let formatDate = dateFormatter.string(from: date)
		XCTAssertEqual(formattedDate, formatDate)
	}
	
    func testWeatherDataLoadingState() throws {
			collectionViewModel.dataLoaded = { details, indexOb, cellStyle in
			}

			let formattedDate = Date.nextDate.formattedDate
			let displayModel = WeatherDisplayInfoModel(with: "Gothenburg", applicableDate: formattedDate)

			let jobsToTest = [WeatherDetails.testData]
			serviceTest.fetchWeatherDetails = Result.success(jobsToTest).publisher.eraseToAnyPublisher()
			let details = collectionViewModel.weatherData1(for: IndexPath(row: 0, section: 0))
			XCTAssertEqual(details.0, displayModel)
			XCTAssertEqual(details.1, .loading)
    }
	
	func testWeatherDataState() throws {
		let expectation = XCTestExpectation(description: "Weather data")

		collectionViewModel.dataLoaded = { details, indexOb, cellStyle in
			let formattedDate = Date.nextDate.formattedDate
			let displayModel = WeatherDisplayInfoModel(with: "Gothenburg", applicableDate: formattedDate).testData()
			XCTAssertEqual(cellStyle, .infoData)
			XCTAssertEqual(displayModel, details)
			
			expectation.fulfill()
		}

		let jobsToTest = [WeatherDetails.testData]
		serviceTest.fetchWeatherDetails = Result.success(jobsToTest).publisher.eraseToAnyPublisher()
		_ = collectionViewModel.weatherData1(for: IndexPath(row: 0, section: 0))
		wait(for: [expectation], timeout: 1)
	}
	
	func testWeatherFailedState() throws {
		let expectation = XCTestExpectation(description: "Failed to fetch weather data")

		collectionViewModel.dataLoaded = { details, indexOb, cellStyle in
			XCTAssertEqual(cellStyle, .error)
			expectation.fulfill()
		}

		serviceTest.fetchWeatherDetails = Result.failure(StatusError.networkError).publisher.eraseToAnyPublisher()
		_ = collectionViewModel.weatherData1(for: IndexPath(row: 0, section: 0))
		wait(for: [expectation], timeout: 1)
	}
}

class LocationServiceTest: LocationServiceProtocol {
	var fetchWeatherDetails: AnyPublisher<[WeatherDetails], Error>!
	func fetchWeather(for location: String) -> AnyPublisher<[WeatherDetails], Error> {
		return fetchWeatherDetails
	}
}

extension WeatherDetails {
	static let testData = WeatherDetails(title: "Gothenburg", timezone: "North", woeid: 123, consolidated_weather: [WeatherDetails.Consolidated_weather.testData])
}
		

extension WeatherDetails.Consolidated_weather {
	static var testData = WeatherDetails.Consolidated_weather(id: 123, weather_state_name: "Gothenburg", weather_state_abbr: "LS", applicable_date: Date.nextDate.formattedDate, min_temp: 5.99, max_temp: 13.89, the_temp: 6.78, humidity: 6.7, wind_direction: 23, air_pressure: 34.2)
}

extension WeatherDisplayInfoModel: Equatable {
	public static func == (lhs: WeatherDisplayInfoModel, rhs: WeatherDisplayInfoModel) -> Bool {
		lhs.title == rhs.title &&
		lhs.date == rhs.date &&
		lhs.info == rhs.info
	}
	
	func testData() -> Self {
		var testData = WeatherDisplayInfoModel(with: "Gothenburg", applicableDate: Date.nextDate.formattedDate)
		testData.updateInfo(details: WeatherDetails.testData)
		return testData
	}
}

extension WeatherDisplayInfoModel.WeatherInformation: Equatable {
	public static func == (lhs: WeatherDisplayInfoModel.WeatherInformation, rhs: WeatherDisplayInfoModel.WeatherInformation) -> Bool {
		lhs.averageTemp == rhs.averageTemp &&
		lhs.temprature == rhs.temprature &&
		lhs.location == rhs.location
	}
}
