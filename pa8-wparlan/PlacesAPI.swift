//
//  PlacesAPI.swift
//  pa8-wparlan
//
//  Created by Parlan, William C on 12/9/20.
//

import Foundation


// TODO: find and add the photo information and the rating information
struct PlacesAPI {
    static let apiKey = "AIzaSyChyWD9EbgNopC_ecgLrA--91VDh6BCwOs"
    static let placeBaseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch"
    static let detailBaseURL = "https://maps.googleapis.com/maps/api/place/details"
    
    // builds url to be used for init place search
    static func placeSeachURL(withCoordinates coords: String, withKeyword keyword: String) -> URL{
        // start with parameters for query
        let params = [
            "output": "json",
            "key": PlacesAPI.apiKey,
            "location": coords,
            "keyword": keyword,
            "rankby": "distance"
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
            "place_id": ID
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
    
    // This function fetches the place's name, place_id, and vicinity
    static func fetchNearbyPlaces(withCoordinates coordinates:String, withKeyword keyword:String, completion: @escaping ([Place]?) -> Void){
        let url = placeSeachURL(withCoordinates: coordinates, withKeyword: keyword)
        let task = URLSession.shared.dataTask(with: url){ (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional, let dataString = String(data: data, encoding: .utf8){
                print("Data recieved holy molyeye ewe didi itt")
                print(dataString)
                if let places: [Place] = decodePlace(fromData: data){
                    print("we got place array")
                    DispatchQueue.main.async {
                        completion(places)
                    }
                    
                }
                else{
                    DispatchQueue.main.async{
                        completion(nil)
                    }
                }
            }
            else{
                if let error = errorOptional{
                    print("Error gettign the Daata \(error)")
                }
                DispatchQueue.main.async{
                    completion(nil)
                }
            }
        }
    }
    
    // this function decodes data into json (DOES NOT DECODE RATING OR PHOTO INFO)
    static func decodePlace(fromData data: Data) -> [Place]?{
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonDictionary = jsonObject as? [String: Any], let placeArray = jsonDictionary["results"] as? [[String: Any]] else{
                print("Error getting results")
                return nil
            }
            print("we got results")
            var places = [Place]()
            for placeObject in placeArray{
                if let place = place(fromJson: placeObject){
                    places.append(place)
                }
            }
            if !places.isEmpty{
                return places
            }
        }
        catch{
            print("Error converting data tot json \(error)")
        }
        return nil
    }
    
    // TODO: add line to capture photo reference
    static func place(fromJson json: [String: Any]) -> Place?{
        guard let name = json["name"] as? String, let id = json["place_id"] as? String, let vicinity = json["vicinity"] as? String else {
            return nil
        }
        let returnValue: Place = Place(name: name, id: id, vicinity: vicinity, rating: -1, photoReference: "")
        return returnValue
    }
}
