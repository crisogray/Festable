//
//  TransportTableViewController.swift
//  FestivalApp
//
//  Created by Ben Gray on 31/07/2015.
//  Copyright (c) 2015 YRS. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class TransportTableViewController: UITableViewController {

    var routes: [RoutePart]!
    var currentLocation: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let k = "39753251becb85d78feb3c362d1679b2"
        let startLon = currentLocation.longitude
        let startLat = currentLocation.latitude
        let destLon = event.coordinate!.longitude
        let destLat = event.coordinate!.latitude
        let url = "http://transportapi.com/v3/uk/public/journey/from/lonlat:\(startLon),\(startLat)/to/lonlat:\(destLon),\(destLat).json"
        let params = ["api_key" : k, "app_id" : "56b1755b"]
        Alamofire.request(.GET, url, parameters: params)
        .responseJSON {
            (request, response, data, error) in
            let json = JSON(data!)
            let routes = json["routes"].arrayValue
            let route = routes[0]
            let routeParts = route["route_parts"].arrayValue
            for r in routeParts {
                let toName = r["to_point_name"].stringValue
                let mode = r["mode"].stringValue
                let departureTime = r["departure_time"]
                println(r)
                //RoutePart(toName: toName, mode: mode, departureTime: departureTime, arrivalTime: <#String#>, duration: <#String#>, coordinates: <#[CLLocationCoordinate2D]?#>)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
