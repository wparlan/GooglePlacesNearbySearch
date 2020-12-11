//
//  PlaceTableViewController.swift
//  pa8-wparlan
//
//  Created by Parlan, William C on 12/11/20.
//

import UIKit
import CoreLocation

class PlaceTableViewController: UITableViewController, CLLocationManagerDelegate {
    //MARK: - Private Variables
    var places = [Place]()
    var coordinates: String = ""
    let locationManager = CLLocationManager()
    
    // MARK: - Main Methods
    func fetchPlaces(withKeyword keyword: String){
        guard self.coordinates != "" else{
            print("no keyword or coordinates present")
            return
        }
        guard keyword != "" else{
            print("no kewyord")
            return
        }
        PlacesAPI.placeSearch(withCoordinates: coordinates, withKeyword: keyword, completion: { (placesOptional) in
            if let places = placesOptional{
                print("In table vs, we got the data")
                for var place in places{
                    PlacesAPI.detailSearch(forPlace: place, completion: {(updateOptional) in
                        if let updatedPlace = updateOptional{
                            place = updatedPlace
                        }
                    })
                }
                self.places = places
                self.tableView.reloadData()
                print(self.places.count)
                print(self.places[0].name,self.places[0].rating)
            }
            // MARK: - Progress bar cocoa pod goes here
            
        })
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row  = indexPath.row
        let place = places[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)

        cell.textLabel?.text = "\(place.name) (\(place.rating)⭐️)"
        cell.detailTextLabel?.text = place.vicinity
        cell.showsReorderControl = true
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return places.count
        }
        return 0
    }
    
    //MARK: - CL Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        let location = locations[locations.count-1]
        coordinates = String(location.coordinate.latitude)+","+String(location.coordinate.longitude)
        print(coordinates)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failure! \(error)")
    }
    
    
    //MARK: - IBACtion Methods
    @IBAction func refreshPressed(_ sender: Any) {
        //Do core location stuff here (grab core location and use that as curr location)
        print("refresh pressed, cl updated")
        locationManager.requestLocation()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if CLLocationManager.locationServicesEnabled(){
            print("CL enabled")
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
            print("View Did load finished")
        }
        else{
            print("CL disabled")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PlaceTableViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchText != "" {
            performSearch(searchBar: searchBar)
        }
        else{
            searchBar.resignFirstResponder()
            places.removeAll()
        }
    }
    func performSearch(searchBar: UISearchBar){
        if let text = searchBar.text{
            print(text)
            fetchPlaces(withKeyword: text)
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
}
