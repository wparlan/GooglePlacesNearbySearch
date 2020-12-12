//
//  PlaceDetailViewController.swift
//  pa8-wparlan
//
//  Created by Parlan, William C on 12/11/20.
//

import UIKit

class PlaceDetailViewController: UIViewController {
    var placeOptional: Place? = nil
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let place = placeOptional{
            nameLabel.text = "\(place.name) \n(\(place.open ? "Open" : "Closed"))"
            addressLabel.text = place.address
            reviewLabel.text = place.review
            phoneLabel.text = place.phone
            PlacesAPI.photoSearch(withReference: place.photoReference, completion: { (photoOptional) in
                if let photo = photoOptional{
                    self.imageView.image = photo
                }

            })
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
