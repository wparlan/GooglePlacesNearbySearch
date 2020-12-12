//
//  PlacesAPI.swift
//  pa8-wparlan
//
//  Created by Parlan, William C on 12/9/20.
//

import Foundation
import UIKit

// TODO: find and add the photo information and the rating information
struct PlacesAPI {
    static let apiKey = "AIzaSyChyWD9EbgNopC_ecgLrA--91VDh6BCwOs"
    static let placeBaseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    static let detailBaseURL = "https://maps.googleapis.com/maps/api/place/details/json"
    static let photoBaseURL = "https://maps.googleapis.com/maps/api/place/photo?/"
    
    //MARK:- URL Buliding Functions
    // builds url to be used for init place search
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
    
    //build url to request details
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
    
    //build url to request photo
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

    // This function fetches the place's name, place_id, and vicinity
    static func placeSearch(withCoordinates coordinates:String, withKeyword keyword:String, completion: @escaping ([Place]?) -> Void){
        let url = placeSeachURL(withCoordinates: coordinates, withKeyword: keyword)
        let task = URLSession.shared.dataTask(with: url){ (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional{
                print("Data recieved holy molyeye ewe didi itt")
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
        task.resume()
    }
    
    static func detailSearch(forPlace place: Place, completion: @escaping (Place?) -> Void){
        let url = detailURL(ID: place.id)
        let task = URLSession.shared.dataTask(with: url){ (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional, let dataString = String(data: data, encoding: .utf8){
                //print("Data recieved holy molyeye ewe didi itt, but for details")
                //print(dataString)
                if let details: Place = addDetails(forPlace: place, fromData: data){
                    print("We got some details")
                    DispatchQueue.main.async {
                        completion(details)
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
                    print("error getting the details \(error)")
                    DispatchQueue.main.async{
                        completion(nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    static func photoSearch(withReference reference: String, completion: @escaping (UIImage?) -> Void){
        let url = photoURL(withReference: reference)
        let task = URLSession.shared.dataTask(with: url){ (dataOptional, urlResponseOptional, errorOptional) in
            if let data = dataOptional{
                print("Photo data rcecived")
                if let image: UIImage = UIImage(data: data){
                    print("We got an image")
                    DispatchQueue.main.async {
                        completion(image)
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
                    print("error getting the rating \(error)")
                    DispatchQueue.main.async{
                        completion(nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    //MARK: - Decoding Functions
    // this function decodes data into json (DOES NOT DECODE RATING INFO)
    static func decodePlace(fromData data: Data) -> [Place]?{
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonDictionary = jsonObject as? [String: Any], let placeArray = jsonDictionary["results"] as? [[String: Any]] else{
                print("Error getting basic search")
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
    
    
    //Function builds a new place obj out of the place search json
    static func place(fromJson json: [String: Any]) -> Place?{
        guard let name = json["name"] as? String, let id = json["place_id"] as? String, let vicinity = json["vicinity"] as? String, let openStatus = json["opening_hours"] as? [String: Any], let open = openStatus["open_now"] as? Bool else {
            return nil
        }
        var returnValue: Place = Place(name: name, id: id, vicinity: vicinity, rating: "N/A", photoReference: "No photo reference available", address: "No address available", review: "No reviews available", phone: "No phone num available", open: open)
        if let photoInformation = json["photos"] as? [[String: Any]], let photoRef = photoInformation.first?["photo_reference"] as? String{
            returnValue.photoReference = photoRef
        }
        return returnValue
    }
    
    // TODO: Fix parsing eror, seems to be error getting rating
    static func addDetails(forPlace place: Place, fromData data:Data) -> Place?{
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            var rating = "N/A"
            var address = "No Address Available"
            var phone = "No Phone Number Available"
            var review = "No Review Available"
            print("(\(place.name))")
            if let jsonDictionary = jsonObject as? [String: Any], let detailArray = jsonDictionary["result"] as? [String: Any] {
                print("details recieved")
                if let ratingTest = detailArray["rating"] as? Double {
                    print("rating get")
                    rating = String(ratingTest)
                }
                if let addressTest = detailArray["formatted_address"] as? String {
                    print("address get")
                    address = addressTest
                }
                if let phoneTest = detailArray["formatted_phone_number"] as? String {
                    print("phone num get")
                    phone = phoneTest
                }
                if let reviews = detailArray["reviews"] as? [[String:Any]], let reviewTest = reviews.first?["text"] as? String {
                    print("review get")
                    review = reviewTest
                }
                let returnval = Place(name: place.name, id: place.id, vicinity: place.vicinity, rating: rating, photoReference: place.photoReference, address: address, review: review, phone: phone, open: place.open)
                //print(returnval)
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
