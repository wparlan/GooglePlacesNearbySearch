//
//  PlacesAPI.swift
//  pa8-wparlan
//  This file holds the functions to request data from the Google Places API and decode its return
//  CPSC 315-01, Fall 2020
//  Programming Assignment #8
//  No sources to site
//  Greeley worked on cocoaPods and main.storyboard and debugging
//  William worked on APIs and PlaceTableViewController and PlaceDetailViewController
//
//  Created by Parlan, William C and Lindberg, Greeley B on 12/11/20.
//

import Foundation
import UIKit

struct PlacesAPI {
    // MARK: - Private Variables
    static let apiKey = "AIzaSyChyWD9EbgNopC_ecgLrA--91VDh6BCwOs"
    static let placeBaseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    static let detailBaseURL = "https://maps.googleapis.com/maps/api/place/details/json"
    static let photoBaseURL = "https://maps.googleapis.com/maps/api/place/photo?/"
    
    //MARK:- URL Buliding Functions
    /**
     Builds URL to use for placeSearch()
     - Parameters:
        - withCoordinates: String containing "lat,long" for location to search
        - withKeyword: String containing keyword to search
     - Returns: URL for placeSearch()
     */
    static func placeSeachURL(withCoordinates coords: String, withKeyword keyword: String) -> URL{
        // start with parameters for query
        let params = [
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
        return url
    }
    
    /**
     Builds URL to be used for detailSearch()
     - Parameter ID: place_id to be used for search
     - Returns: URL for detailSearch()
     */
    static func detailURL(ID: String) -> URL{
        // start with parameters for query
        let params = [
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
        return url
    }
    
    /**
     Builds URL to search for photoSearch()
     - Parameter withReference: String identifier of photo to retrieve
     - Returns: URL for photoSearch()
     */
    static func photoURL(withReference reference: String) -> URL{
        // start with parameters for query
        let params = [
            "key": PlacesAPI.apiKey,
            "photoreference": reference,
            "maxwidth": "1600"
        ]
        // we nned to get the params into url
        var queryItems = [URLQueryItem]()
        for (key, value) in params{
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        var components = URLComponents(string: photoBaseURL)!
        components.queryItems = queryItems
        let url = components.url!
        return url
    }
    
    // MARK: - Query Functions

    /**
     Requests data from Google Places API via a Nearby Search Request, then parses it
     - Parameters:
        - withCoordinates: String containing "lat,long" to be used for search
        - withKeyword: String containing keyword to search
        - completion: Closure to execute after data is recieved
     - Returns: Optional place array from completion closure
     */
    static func placeSearch(withCoordinates coordinates:String, withKeyword keyword:String, completion: @escaping ([Place]?) -> Void){
        let url = placeSeachURL(withCoordinates: coordinates, withKeyword: keyword)
        let task = URLSession.shared.dataTask(with: url){ (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional{
                // Data recieved
                if let places: [Place] = decodePlace(fromData: data){
                    // If successfully decoded, return it in closure
                    DispatchQueue.main.async {
                        completion(places)
                    }
                    
                }
                else{
                    // If failed to decode, return nil in closure
                    DispatchQueue.main.async{
                        completion(nil)
                    }
                }
            }
            else{
                // Data retrieval failed
                if let error = errorOptional{
                    print("Error getting basic data \(error)")
                }
                DispatchQueue.main.async{
                    completion(nil)
                }
            }
        }
        // start the URLSessionTask
        task.resume()
    }
    
    /**
     Requests data from Google Places API via a Place Details Request, then parses it
     - Parameters:
        - forPlace: String containing place_id to be used for search
        - completion: Closure to execute after data is recieved
     - Returns: Optional place from completion closure
     */    static func detailSearch(forPlace place: Place, completion: @escaping (Place?) -> Void){
        let url = detailURL(ID: place.id)
        let task = URLSession.shared.dataTask(with: url){ (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional{
                // data recieved succesfully
                if let details: Place = addDetails(forPlace: place, fromData: data){
                    // data parsed successfully and returned in closure
                    DispatchQueue.main.async {
                        completion(details)
                    }
                }
                else{
                    // failed to parse data, return nil
                    DispatchQueue.main.async{
                        completion(nil)
                    }
                }
            }
            else{
                // failed to retrieve data
                if let error = errorOptional{
                    print("Error getting the details \(error)")
                    DispatchQueue.main.async{
                        completion(nil)
                    }
                }
            }
        }
        // start the URLSessionTask
        task.resume()
    }
    
    /**
     Requests data from Google Places API via a Place Photo Request
     - Parameters:
        - withReference: String containing unique photo_reference to be used for search
        - completion: Closure to execute after data is recieved
     - Returns: Optional UIImage from completion closure
     */
    static func photoSearch(withReference reference: String, completion: @escaping (UIImage?) -> Void){
        let url = photoURL(withReference: reference)
        let task = URLSession.shared.dataTask(with: url){ (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional{
                // data recieved
                if let image: UIImage = UIImage(data: data){
                    // data parsed successfully
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
                else{
                    // failed to parse data
                    DispatchQueue.main.async{
                        completion(nil)
                    }
                }
            }
            else{
                // failed to get data
                if let error = errorOptional{
                    print("Error getting the photo \(error)")
                    DispatchQueue.main.async{
                        completion(nil)
                    }
                }
            }
        }
        // start URLSessionDataTask
        task.resume()
    }
    
    //MARK: - Decoding Functions

    /**
     Converts data into JSON object, then parses into new Place object
     - Parameter fromData: data object to be converted
     - Returns: Optional Array of Place objects
     */
    static func decodePlace(fromData data: Data) -> [Place]?{
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonDictionary = jsonObject as? [String: Any], let placeArray = jsonDictionary["results"] as? [[String: Any]] else{
                // Error getting basic search results
                return nil
            }
            //successfully got basic search data
            
            var places = [Place]()
            // fill array with decoded places
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
            // failed to convert data to JSON
            print("Error converting data to JSON \(error)")
        }
        return nil
    }
    
    
    /**
     Builds a new Place object out of given JSON object
     - Parameter fromJson: JSON object to be parsed
     - Returns: Place if JSON is parsed correctly or nil otherwise
     */
    static func place(fromJson json: [String: Any]) -> Place?{
        // main parsing guard
        guard let name = json["name"] as? String, let id = json["place_id"] as? String, let vicinity = json["vicinity"] as? String, let openStatus = json["opening_hours"] as? [String: Any], let open = openStatus["open_now"] as? Bool else {
            return nil
        }
        // put data into new object
        var returnValue: Place = Place(name: name, id: id, vicinity: vicinity, rating: "N/A", photoReference: "No photo reference available", address: "No address available", review: "No reviews available", phone: "No phone num available", open: open)
        // if location has picture, add it. otherwise ignore
        if let photoInformation = json["photos"] as? [[String: Any]], let photoRef = photoInformation.first?["photo_reference"] as? String{
            returnValue.photoReference = photoRef
        }
        return returnValue
    }
    
    /**
     Parses JSON from detailSeach() and returns a new Place with more information
     - Parameters:
        - forPlace: Place object that is going to updated with details
        - fromData: Data object to be decoded into JSON
     - Returns: Place if JSON is parsed correctly or nil otherwise
     */
    static func addDetails(forPlace place: Place, fromData data:Data) -> Place?{
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            var rating = "N/A"
            var address = "No Address Available"
            var phone = "No Phone Number Available"
            var review = "No Review Available"
            if let jsonDictionary = jsonObject as? [String: Any], let detailArray = jsonDictionary["result"] as? [String: Any] {
                // Below are individual if lets because not all locations have every field
                if let ratingTest = detailArray["rating"] as? Double {
                    rating = String(ratingTest)
                }
                if let addressTest = detailArray["formatted_address"] as? String {
                    address = addressTest
                }
                if let phoneTest = detailArray["formatted_phone_number"] as? String {
                    phone = phoneTest
                }
                if let reviews = detailArray["reviews"] as? [[String:Any]], let reviewTest = reviews.first?["text"] as? String {
                    review = reviewTest
                }
                let returnval = Place(name: place.name, id: place.id, vicinity: place.vicinity, rating: rating, photoReference: place.photoReference, address: address, review: review, phone: phone, open: place.open)
                return returnval
            }
            return nil
        }
        catch{
            print("Error converting data to rating \(error)")
        }
        return nil
    }
    
}
