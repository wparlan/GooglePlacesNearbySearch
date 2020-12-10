//
//  PlacesAPI.swift
//  pa8-wparlan
//
//  Created by Parlan, William C on 12/9/20.
//

import Foundation

struct PlacesAPI {
    static let apiKey = "AIzaSyChyWD9EbgNopC_ecgLrA--91VDh6BCwOs"
    static let placeBaseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch"
    static let detailBaseURL = "https://maps.googleapis.com/maps/api/place/details"
    
    //TODO: finish params/figure out inputs/outputs
    static func placeSeachURL(withCoordinates coords: String) -> URL{
        // start with parameters for query
        let params = [
            "output": "json",
            "key": PlacesAPI.apiKey,
            "location": coords,
            "radius": "textquery"
        ]
        // we nned to get the params into url
        var queryItems = [URLQueryItem]()
        for (key, value) in params{
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        var components = URLComponents(string: placeBaseURL)!
        components.queryItems = queryItems
        let url = components.url!
        print(url)
        return url
    }
    
    //build url to request details
    static func detailURL(ID: String) -> URL{
        // start with parameters for query
        let params = [
            "output": "json",
            "key": PlacesAPI.apiKey,
        ]
        // we nned to get the params into url
        var queryItems = [URLQueryItem]()
        for (key, value) in params{
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        var components = URLComponents(string: detailBaseURL)!
        components.queryItems = queryItems
        let url = components.url!
        print(url)
        return url
    }
    
    //TODO: Figure out inputs/outputs
    static func fetchPlace(named name:String, completion: @escaping (Place) -> Void){
        let url = placeSeachURL(withCoordinates: name)
        let task = URLSession.shared.dataTask(with: url){ (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional, let dataString = String(data: data, encoding: .utf8){
                print("Data recieved holy molyeye ewe didi itt")
                print(dataString)
                if let placeID = parseID(fromData: data){
                    
                }
            }
        }
    }
    
    //TODO: Build this entire function and look into what the api returns and what to do with that
    static func parseID(fromData data: Data) -> Place{
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let
        }
    }
}
