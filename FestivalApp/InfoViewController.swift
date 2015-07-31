//
//  InfoViewController.swift
//  FestivalApp
//
//  Created by Ben Gray on 28/07/2015.
//  Copyright (c) 2015 YRS. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON
import Parse

var event: Festival!

class InfoViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var dateActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var weatherActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var titleView: UIView!
    @IBOutlet var weatherView: UIView!
    @IBOutlet var travelView: UIView!
    @IBOutlet var dateView: UIView!
    @IBOutlet var weatherButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var weatherLabel: UILabel!
    @IBOutlet var map: MKMapView!
    @IBOutlet var headingBackground: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    let apiKey = "lsiqF8rhg4le3HPp"
    var festival: String!
    var manager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var showingLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.text = festival.uppercaseString
        self.navigationItem.title = festival + " Info"
        map.delegate = self
        searchForEventDetails()
        let views = [weatherView, travelView, dateView, titleView]
        for v in views {
            v.layer.borderColor = UIColor.whiteColor().CGColor
            v.layer.borderWidth = 2
        }
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.view.layoutIfNeeded()
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        manager.startUpdatingLocation()
        map.showsUserLocation = true
    }
    
    @IBAction func showDirections() {
        if currentLocation != nil && event.coordinate != nil {
            let meanLat = (event.coordinate!.latitude + currentLocation!.latitude) / 2
            let meanLng = (event.coordinate!.longitude + currentLocation!.longitude) / 2
            let coordinate = CLLocationCoordinate2DMake(meanLat, meanLng)
            let span = MKCoordinateSpanMake(0.45, 0.45)
            let region = MKCoordinateRegionMake(coordinate, span)
            map.setRegion(region, animated: true)
            let request = MKDirectionsRequest()
            request.setSource(MKMapItem.mapItemForCurrentLocation())
            request.setDestination(MKMapItem(placemark: MKPlacemark(coordinate: event.coordinate!, addressDictionary: nil)))
            request.requestsAlternateRoutes = false
            let directions = MKDirections(request: request)
            if !showingLocation {
                directions.calculateDirectionsWithCompletionHandler({
                    (response: MKDirectionsResponse!, error: NSError!) in
                    if error != nil {
                        println(error!.localizedDescription)
                    } else {
                        self.showRoute(response)
                        self.showingLocation = true
                    }
                })
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if currentLocation == nil {
            let location = locations[0] as! CLLocation
            currentLocation = location.coordinate
            PFUser.currentUser()!["lastLocation"] = PFGeoPoint(location: location)
            PFUser.currentUser()!.saveInBackground()
            findEta()
        }
    }
    
    func findEta() {
        if currentLocation != nil && event != nil {
            let mapItem = MKMapItem.mapItemForCurrentLocation()
            let request = MKDirectionsRequest()
            request.setSource(mapItem)
            request.setDestination(MKMapItem(placemark: MKPlacemark(coordinate: event.coordinate!, addressDictionary: nil)))
            request.requestsAlternateRoutes = false
            let directions = MKDirections(request: request)
            directions.calculateETAWithCompletionHandler {
                (eta, error) -> Void in
                let d = event.date!
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "h a"
                let s = dateFormatter.stringFromDate(d)
                let time = d.dateByAddingTimeInterval(-eta.expectedTravelTime)
                dateFormatter.dateFormat = "h:m a"
                let leaveDate = dateFormatter.stringFromDate(time)
                let url = "https://api.clockworksms.com/http/send.aspx"
                let k = "911fad19a7d375939102fed4b6c78032f0bb27ee"
                let n = "447552628790"
                let t = "Are you ready for \(self.festival) Festival?\nTo make the \(s) opening time you should leave at about \(leaveDate) on the same day. (If you are travelling by car)"
                let params = ["key" : k, "to" : n, "content" : t]
                //Alamofire.request(.GET, url, parameters: params)
            }
        }
    }
        
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = tint
        renderer.lineWidth = 5
        return renderer
    }
    
    func showRoute(response: MKDirectionsResponse) {
        for route in response.routes as! [MKRoute] {
            map.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
        }
    }
    
    func searchForEventDetails() {
        let url = "http://api.songkick.com/api/3.0/search/venues.json"
        var query = PFQuery(className: "Events")
        query.whereKey("name", equalTo: self.festival)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error) -> Void in
            if error == nil {
                if objects!.isEmpty || objects == nil {
                    Alamofire.request(.GET, url, parameters: ["query" : self.festival + " Festival", "apikey" : self.apiKey])
                        .responseJSON {
                            (request, response, data, error) in
                            let json = JSON(data!)
                            let resultsPage = json["resultsPage"]
                            let results = resultsPage["results"]
                            let venues = results["venue"].array!
                            var v = venues[0]
                            var done = false
                            for venue in venues {
                                if !done {
                                    let name = venue["displayName"].string!.lowercaseString
                                    let s = self.festival.lowercaseString + " festival"
                                    if name == s {
                                        v = venue
                                        done = true
                                    }
                                }
                            }
                            let id = v["id"].int!
                            let name = v["displayName"].string!
                            let latFloat = v["lat"].floatValue
                            let lat = CLLocationDegrees(latFloat)
                            let lngFloat = v["lng"].floatValue
                            let lng = CLLocationDegrees(lngFloat)
                            let coord = CLLocationCoordinate2DMake(lat, lng)
                            let postcode = v["zip"].string
                            let street = v["street"].string
                            let metroArea = v["metroArea"]
                            let metroId = metroArea["id"].int!
                            let venue = Festival(id: id, name: name, coordinate: coord, postcode: postcode, street: street, metroId: metroId)
                            event = venue
                            self.setCoord(venue.coordinate!)
                            self.searchForFurtherDetails(venue)
                    }
                } else {
                    let objs = objects! as! [PFObject]
                    let o = objs[0]
                    let id = o["songkickId"] as! Int
                    let name = o["name"] as! String
                    let location = o["location"] as! PFGeoPoint
                    let coord = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                    let date = o["date"] as! NSDate
                    let lineup = o["artists"]! as! NSArray
                    let venue = Festival(id: id, name: name, coordinate: coord, postcode: nil, street: nil, metroId: nil)
                    venue.date = date
                    venue.lineUp = [Artist]()
                    var likedArtists = [PFObject]()
                    var dislikedArtists = [PFObject]()
                    if let la = PFUser.currentUser()!["likedArtists"] as? [PFObject] {
                        likedArtists = la
                    }
                    if let da = PFUser.currentUser()!["dislikedArtists"] as? [PFObject] {
                        dislikedArtists = da
                    }
                    for a in lineup {
                        let id = (a["id"] as! String).toInt()!
                        let name = a["name"] as! String
                        let object = a["object"] as! PFObject
                        let parseId = object.objectId!
                        let artist = Artist(id: id, name: name)
                        artist.parseId = parseId
                        var liked = false
                        for ar in likedArtists {
                            let i = ar.objectId!
                            if parseId == i {
                                liked = true
                            }
                        }
                        var disliked = false
                        for ar in dislikedArtists {
                            let i = ar.objectId!
                            if parseId == i {
                                disliked = true
                            }
                        }
                        artist.liked = liked
                        artist.disliked = disliked
                        venue.lineUp!.append(artist)
                    }
                    venue.parseId = o.objectId!
                    self.setDate(date)
                    event = venue
                    self.setCoord(venue.coordinate!)
                    self.findEta()
                }
            }
        }
        
    }
    
    func searchForFurtherDetails(festival: Festival) {
        let url = "http://api.songkick.com/api/3.0/events.json"
        Alamofire.request(.GET, url, parameters: ["apikey" : apiKey, "location" : "sk:\(festival.metroId!)"])
        .responseJSON {
            (request, response, data, error) in
            let json = JSON(data!)
            let resultsPage = json["resultsPage"]
            let results = resultsPage["results"]
            let events = results["event"].array!
            var done = false
            var e = events[0]
            for event in events {
                if !done {
                    let name = event["displayName"].string!.lowercaseString
                    let s = self.festival.lowercaseString + " festival 2015"
                    if name == s {
                        e = event
                        done = true
                    }
                }
            }
            let id = e["id"].int!
            event.id = id
            let start = e["start"]
            let dateString = start["datetime"].string!
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            let date = dateFormatter.dateFromString(dateString)!
            event.date = date
            let location = e["location"]
            let latFloat = location["lat"].floatValue
            let lat = CLLocationDegrees(latFloat)
            let lngFloat = location["lng"].floatValue
            let lng = CLLocationDegrees(lngFloat)
            let coord = CLLocationCoordinate2DMake(lat, lng)
            self.setCoord(coord)
            event.coordinate = coord
            let performance = e["performance"].array!
            var artistsForParse = [[String : AnyObject]]()
            for p in performance {
                let a = p["artist"]
                let name = a["displayName"].string!
                let id = a["id"].int!
                let object = PFObject(className: "Artists")
                object["songkickId"] = id
                object["name"] = name
                object.saveInBackground()
                let obj = ["name" : name, "id" : String(id), "object" : object]
                artistsForParse.append(obj)
            }
            self.setDate(date)
            let object = PFObject(className: "Events")
            object["songkickId"] = event.id
            object["name"] = self.festival
            object["location"] = PFGeoPoint(latitude: coord.latitude, longitude: coord.longitude)
            object["date"] = date
            object.addUniqueObjectsFromArray(artistsForParse, forKey: "artists")
            object.saveInBackground()
        }
    }
    
    func setDate(date: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM\rHH:mm a"
        dateActivityIndicator.stopAnimating()
        self.dateLabel.text = dateFormatter.stringFromDate(date)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setCoord(coord: CLLocationCoordinate2D) {
        setMapCoordinate(coord)
        getWeatherForCoordinate(coord)
    }
    
    func setMapCoordinate(coord: CLLocationCoordinate2D) {
        map.removeAnnotations(map.annotations)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(coord, span)
        map.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        annotation.title = festival
        if event.date != nil {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd MMM HH:mm a"
            annotation.subtitle = dateFormatter.stringFromDate(event.date!)
        }
        map.addAnnotation(annotation)
    }
    
    func getWeatherForCoordinate(coord: CLLocationCoordinate2D) {
        let url = NSURL(string: "http://api.openweathermap.org/data/2.5/forecast")!
        Alamofire.request(.GET, url, parameters: ["lat" : coord.latitude, "lon" : coord.longitude])
        .responseJSON {
        (request, response, data, error) in
            let json = JSON(data!)
            let list = json["list"]
            let w = list[0]["weather"]
            let weather = w[0]["main"].string!
            let main = list[0]["main"]
            let t = main["temp"].floatValue
            let temp = Int(t - 273.15)
            self.weatherActivityIndicator.stopAnimating()
            self.weatherLabel.text = "\(temp)°C, \(weather)"
            switch weather.lowercaseString {
            case "clear":
                self.weatherButton.setImage(UIImage(named: "Sun"), forState: .Normal)
            case "clouds":
                self.weatherButton.setImage(UIImage(named: "Cloud"), forState: .Normal)
            case "rain":
                self.weatherButton.setImage(UIImage(named: "Rain"), forState: .Normal)
            case "snow":
                self.weatherButton.setImage(UIImage(named: "Snow"), forState: .Normal)
            default:
                println("Unknown weather type")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if currentLocation != nil {
            if segue.destinationViewController.isKindOfClass(TransportTableViewController.classForCoder()) {
                (segue.destinationViewController as! TransportTableViewController).currentLocation = currentLocation!
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
