//
//  WeatherStackData.swift
//  WeatherApp2
//
//  Created by Nyisztor, Karoly on 11/9/19.
//  Copyright © 2019 Nyisztor, Karoly. All rights reserved.
//

import Foundation

struct WeatherStackContainer: Codable {
    var current: WeatherStackCurrent?
}

struct WeatherStackCurrent: Codable {
    let temperature: Int?
    let weather_descriptions: [String]?
}

struct WeatherStackCondition: Codable {
    var text: String
    var icon: String // icon image url
}
