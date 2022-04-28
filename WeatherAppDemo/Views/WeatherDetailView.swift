//
//  WeatherDetailView.swift
//  WeatherAppDemo
//
//  Created by Ajay Rawat on 2022-04-27.
//

import SwiftUI

/// This View is displaying weather details for next 6 days
struct WeatherDetailView: View {
	var weatherDetails: WeatherDetails
		
    var body: some View {
			VStack {
				Text(weatherDetails.title).font(.largeTitle)
				Text(weatherDetails.timezone).font(.title)
			}
			List(weatherDetails.consolidated_weather) { details in
				WeatherListView(details: details)
			}
		}
}

struct WeatherListView: View {
	var details: WeatherConsolidateDetails
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text(details.weather_state_name).font(.title).foregroundColor(Color.red)
				Spacer()
				Text(details.applicable_date).font(.subheadline)
			}
			HStack {
				Text("Temprature: \(details.the_temp)")
			}
			Text("High:\(details.max_temp) , Low:\(details.min_temp)")
			Text("Humidity: \(details.humidity)")
			Text("Wind Direction: \(details.wind_direction)")
			Text("Air Pressure: \(details.air_pressure)")
		}.padding([.top,.bottom], 10)
	}
}
