//
//  WebServiceController.swift
//  WeatherApp
//
//  Created by Nyisztor, Karoly on 11/9/19.
//  Copyright © 2019 Nyisztor, Karoly. All rights reserved.
//

import Foundation

public protocol WebServiceController {
    func fetchWeatherData(for city: String,
                          completionHandler: @escaping(String?, WebServiceControllerError?) -> Void)
}

// MARK: - WebServiceControllerError
public enum WebServiceControllerError: Error {
    case invalidURL(String)
    case invalidPayload(URL)
    case forwarded(Error)
}
