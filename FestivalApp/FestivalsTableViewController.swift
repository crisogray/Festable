//
//  FestivalsTableViewController.swift
//  FestivalApp
//
//  Created by Ben Gray on 27/07/2015.
//  Copyright (c) 2015 YRS. All rights reserved.
//

import UIKit

let festivals = ["Reading", "Womad", "Glastonbury", "Wireless", "Leeds"]

class FestivalsTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet var searchBar: UISearchBar!
    var fests = festivals
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        fests = [String]()
        if searchBar.text != nil && searchBar.text != "" {
            for f in festivals {
                if f.lowercaseString.rangeOfString(searchBar.text) != nil {
                    fests.append(f)
                }
            }
        } else {
            fests = festivals
        }
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 220
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return fests.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FestivalCell", forIndexPath: indexPath) as! FestivalTableViewCell
        cell.titleLabel.text = fests[indexPath.row].uppercaseString
        cell.backgroundImageView.image = UIImage(named: fests[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FestivalTableViewCell
        let festival = fests[indexPath.row]
        let destTabController = self.storyboard?.instantiateViewControllerWithIdentifier("TabController") as! UITabBarController
        let destNavController = destTabController.viewControllers![0] as! UINavigationController
        let destViewController = destNavController.viewControllers![0] as! InfoViewController
        destViewController.festival = festival
        self.presentViewController(destTabController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }

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
