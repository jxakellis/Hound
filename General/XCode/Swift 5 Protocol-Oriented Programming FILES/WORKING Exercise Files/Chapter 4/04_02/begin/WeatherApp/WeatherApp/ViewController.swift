//
//  ViewController.swift
//  WeatherApp
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var input: String = ""
    var body: some View{
        VStack{
            TextField("Enter city", text: $input).font(.title)
            
            Divider()
            
            Text(input).font(.body)
            }.padding()
    }
}
 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View{
        ContentView()
    }
}

