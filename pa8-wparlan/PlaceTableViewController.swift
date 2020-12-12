//
//  PlaceTableViewController.swift
//  pa8-wparlan
//  This file holds the TableViewController that displays the results from a placeSearch
//  CPSC 315-01, Fall 2020
//  Programming Assignment #8
//  No sources to site
//  Greeley worked on cocoaPods and main.storyboard and debugging
//  William worked on APIs and PlaceTableViewController and PlaceDetailViewController
//
//  Created by Parlan, William C and Lindberg, Greeley B on 12/11/20.
//

import UIKit
import CoreLocation
import MBProgressHUD

// Table View Controller for Search Results Display
class PlaceTableViewController: UITableViewController, CLLocationManagerDelegate {
    //MARK: - Private Variables
    var places = [Place]()
    var coordinates: String = ""
    let locationManager = CLLocationManager()
    
    // MARK: - API Methods
    
    /**
     This function updates local places array with data from Google Places API
     - Parameter withKeyword: Keyword for search
     - Returns: Void
     */
    func fetchPlaces(withKeyword keyword: String){
        guard self.coordinates != "" else{
            print("No coordinates provided")
            return
        }
        guard keyword != "" else{
            print("No kewyord provided")
            return
        }
        places.removeAll()
        MBProgressHUD.showAdded(to: self.view, animated: true)
        PlacesAPI.placeSearch(withCoordinates: coordinates, withKeyword: keyword, completion: { (placesOptional) in
            if let placeArray = placesOptional{
                for place in placeArray{
                    PlacesAPI.detailSearch(forPlace: place, completion: {(updateOptional) in
                        if let updatedPlace = updateOptional{
                            self.places.append(updatedPlace)
                        }
                        self.tableView.reloadData()
                    })
                }
            }
            MBProgressHUD.hide(for: self.view, animated: true)
        })

    }
    // MARK: - Table View Methods
    
    // This methods updates the table view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row  = indexPath.row
        let place = places[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)

        if (place.rating == "N/A"){
            cell.textLabel?.text = "\(place.name) (No Rating)"
        }
        else{
            cell.textLabel?.text = "\(place.name) (\(place.rating)⭐️)"
        }
        cell.detailTextLabel?.text = place.vicinity
        cell.showsReorderControl = true
        return cell
    }
    
    // this method returns section number
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return places.count
        }
        return 0
    }
    
    //MARK: - CL Methods
    
    //Use this method to update Coordinates whenever location changes
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        coordinates = String(location.coordinate.latitude)+","+String(location.coordinate.longitude)
    }
    
    //Use this method to print error value
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failure! \(error)")
    }
    
    
    
    // MARK: - Segue Methods
    // transfers the current selected place to the detailVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier{
            if identifier == "DetailSegue"{
                if let destinationVC = segue.destination as? PlaceDetailViewController{
                    if let indexPath = tableView.indexPathForSelectedRow{
                        let place = places[indexPath.row]
                        destinationVC.placeOptional = place
                    }
                }
            }
        }
    }
    //MARK: - IBACtion Methods
    
    /**
     Updates location when the user presses button
     - Parameter sender: The UIButton that sent the signal
     - Returns Void
     */
    @IBAction func refreshPressed(_ sender: Any) {
        locationManager.requestLocation()
    }
    
    // MARK: - viewDidLoad
    // added CL permissions and init location fetch
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if CLLocationManager.locationServicesEnabled(){
            print("CoreLocation enabled")
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
        }
        else{
            print("CoreLocation disabled")
        }
    }
}

// MARK: - Search Bar Extension
extension PlaceTableViewController: UISearchBarDelegate{
    // When user presses search, fetch places with keyword in search field
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text{
            if searchText != "" {
                fetchPlaces(withKeyword: searchText)
            }
            else{
                places.removeAll()
                tableView.reloadData()
            }
        }
    }
    
    // Clear search, drop keyboard, clear places array, refresh
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        places.removeAll()
        tableView.reloadData()
    }
    
    // If the user hits the x button, it clears the text. If text is cleared, resign and empty table
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            searchBar.text = nil
            searchBar.resignFirstResponder()
            places.removeAll()
            tableView.reloadData()
        }
    }
}
