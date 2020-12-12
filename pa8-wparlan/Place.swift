//
//  Place.swift
//  pa8-wparlan
//  This file holds the struct for the Place type
//  CPSC 315-01, Fall 2020
//  Programming Assignment #8
//  No sources to site
//  Greeley worked on cocoaPods and main.storyboard and debugging
//  William worked on APIs and PlaceTableViewController and PlaceDetailViewController
//
//  Created by Parlan, William C and Lindberg, Greeley B on 12/11/20.
//

import Foundation

struct Place{
    // required by project
    var name: String
    var id: String
    var vicinity: String
    var rating: String
    var photoReference: String
    
    //additional
    var address: String
    var review: String
    var phone: String
    var open: Bool
}
