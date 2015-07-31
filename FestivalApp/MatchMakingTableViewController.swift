//
//  MatchMakingTableViewController.swift
//  FestivalApp
//
//  Created by Ben Gray on 30/07/2015.
//  Copyright (c) 2015 YRS. All rights reserved.
//

import UIKit
import Parse

class MatchMakingTableViewController: UITableViewController {
    
    var likes = [[PFUser : Artist]]()
    var dislikes = [[PFUser : Artist]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //findSimilar(false)
        //findSimilar(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        likes = [[PFUser : Artist]]()
        dislikes = [[PFUser : Artist]]()
        findSimilar(false)
        findSimilar(true)
    }

    func findSimilar(like: Bool) {
        var artists = PFUser.currentUser()!["likedArtists"] as! [PFObject]
        if !like {
            artists = PFUser.currentUser()!["dislikedArtists"] as! [PFObject]
        }
        for artist in artists {
            let id = artist.objectId!
            let query = PFQuery(className: "Artists")
            query.getObjectInBackgroundWithId(id, block: {
                (object: PFObject?, error) -> Void in
                if error == nil && object != nil {
                    let id = object!["songkickId"] as! Int
                    let name = object!["name"] as! String
                    let art = Artist(id: id, name: name)
                    art.parseId = object!.objectId!
                    var users = [PFUser]()
                    if !like {
                        users = object!["dislikeUsers"] as! [PFUser]
                    } else {
                        users = object!["likeUsers"] as! [PFUser]
                    }
                    for u in users {
                        if u.objectId! != PFUser.currentUser()!.objectId! {
                            let query = PFQuery(className: "_User")
                            query.getObjectInBackgroundWithId(u.objectId!, block: {
                                (object: PFObject?, error) -> Void in
                                if error == nil && object != nil {
                                    let user = object as! PFUser
                                    if like {
                                        self.likes.append([user : art])
                                    } else {
                                        self.dislikes.append([user : art])
                                    }
                                    self.tableView.reloadData()
                                }
                            })
                        }
                    }
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = NSBundle.mainBundle().loadNibNamed("MatchmakingHeaderView", owner: self, options: nil)[0] as! MatchmakingHeaderView
        view.like(section)
        return view
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0 {
            return likes.count
        } else {
            return dislikes.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UITableViewCell
        var user: PFUser!
        var artist: Artist!
        if indexPath.section == 0 {
            user = likes[indexPath.row].keys.array[0]
            artist = likes[indexPath.row][user]
        } else {
            user = dislikes[indexPath.row].keys.array[0]
            artist = dislikes[indexPath.row][user]
        }
        cell.textLabel!.text = user.username
        cell.detailTextLabel!.text = artist.name
        // Configure the cell...

        return cell
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
