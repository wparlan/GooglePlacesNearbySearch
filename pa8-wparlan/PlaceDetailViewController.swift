//
//  PlaceDetailViewController.swift
//  pa8-wparlan
//  This file holds the VC for the detailed view of a selected place and its implementation
//  CPSC 315-01, Fall 2020
//  Programming Assignment #8
//  No sources to site
//  Greeley worked on cocoaPods and main.storyboard and debugging
//  William worked on APIs and PlaceTableViewController and PlaceDetailViewController
//
//  Created by Parlan, William C and Lindberg, Greeley B on 12/11/20.
//

import UIKit
import MBProgressHUD

// This ViewController handles the detailed view of the selected place
class PlaceDetailViewController: UIViewController {
    //MARK: - Local Variables
    var placeOptional: Place? = nil
    // MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // If data is retrieved from segueway, update views with it
        if let place = placeOptional{
            nameLabel.text = "\(place.name) \n(\(place.open ? "Open" : "Closed"))"
            addressLabel.text = place.address
            reviewLabel.text = place.review
            phoneLabel.text = place.phone
            // look up image for place in question
            MBProgressHUD.showAdded(to: self.view, animated: true)
            PlacesAPI.photoSearch(withReference: place.photoReference, completion: { (photoOptional) in
                if let photo = photoOptional{
                    self.imageView.image = photo
                }
                MBProgressHUD.hide(for: self.view, animated: true)
            })
        }
    }
}
