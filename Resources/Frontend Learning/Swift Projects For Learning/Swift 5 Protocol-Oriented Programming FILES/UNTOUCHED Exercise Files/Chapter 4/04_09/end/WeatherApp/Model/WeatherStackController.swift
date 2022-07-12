//
//  WeatherStackController.swift
//  WeatherApp2
//
//  Created by Nyisztor, Karoly on 11/9/19.
//  Copyright © 2019 Nyisztor, Karoly. All rights reserved.
//

import Foundation

// To get your API key, follow the steps at https://weatherstack.com/signup
private enum API {
    static let key = "5a199cf437729ee14a43ef2cd88ef686"
}

final class WeatherStackController: WebServiceController {
    func fetchWeatherData(for city: String, completionHandler: @escaping (String?, WebServiceControllerError?) -> Void) {
        let endpoint = "http://api.weatherstack.com/current?access_key=\(API.key)&query=\(city)&units=f"
        
        // create a string that can be used in URLs
        let safeURLString = endpoint.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        guard let endpointURL = URL(string: safeURLString) else {
            completionHandler(nil, WebServiceControllerError.invalidURL(safeURLString))
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: endpointURL, completionHandler: { (data, response, error) -> Void in
            guard error == nil else {
                // we wrap the error in our dedicated error type and pass it back to the caller
                completionHandler(nil, WebServiceControllerError.forwarded(error!))
                return
            }
            guard let responseData = data else {
                completionHandler(nil, WebServiceControllerError.invalidPayload(endpointURL))
                return
            }
            
            // decode json
            let decoder = JSONDecoder()
            do {
                let weatherContainer = try decoder.decode(WeatherStackContainer.self, from: responseData)
                
                guard let weatherInfo = weatherContainer.current,
                    let weather = weatherInfo.weather_descriptions?.first,
                    let temperature = weatherInfo.temperature else {
                        completionHandler(nil, WebServiceControllerError.invalidPayload(endpointURL))
                        return
                }
                
                // compose weather information
                let weatherDescription = "\(weather) \(temperature) °F"
                completionHandler(weatherDescription, nil)
            } catch let error {
                completionHandler(nil, WebServiceControllerError.forwarded(error))
            }
        })
        
        dataTask.resume()
    }
}
