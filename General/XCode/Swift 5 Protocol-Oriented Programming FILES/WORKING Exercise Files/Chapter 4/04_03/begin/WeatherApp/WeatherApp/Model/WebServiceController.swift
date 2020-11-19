//
//  WebServiceController.swift
//  WeatherApp
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2020 Nyisztor, Karoly. All rights reserved.
//

import Foundation

public enum WebServiceControllerError: Error {
    case invalidURL(String)
    case invalidPayload(URL)
    case forwarded(Error)
}

public protocol WebServiceController {
    func fetchWeatherData(for city: String, completionHandler: (String?, WebServiceControllerError?) -> Void)
}
