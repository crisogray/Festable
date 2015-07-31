
//
//  ArtistTableViewCell.swift
//  FestivalApp
//
//  Created by Ben Gray on 29/07/2015.
//  Copyright (c) 2015 YRS. All rights reserved.
//

import UIKit
import Parse

class ArtistTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var cross: UIButton!
    @IBOutlet var tick: UIButton!
    var artist: Artist!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cross.setImage(UIImage(named: "Cross Full"), forState: .Selected)
        tick.setImage(UIImage(named: "Tick Full"), forState: .Selected)
    }
    
    func setArtist(artist: Artist) {
        self.artist = artist
        nameLabel.text = artist.name
        tick.selected = false
        cross.selected = false
        if artist.liked! {
            tick.selected = true
        }
        if artist.disliked! {
            cross.selected = true
        }
    }

    @IBAction func tick(sender: AnyObject) {
        ArtistTableViewCell.updateLike(true, cross: cross, tick: tick, artist: artist)
    }
    
    @IBAction func cross(sender: AnyObject) {
        ArtistTableViewCell.updateLike(false, cross: cross, tick: tick, artist: artist)
    }
    
    class func updateLike(like: Bool, cross: UIButton, tick: UIButton, artist: Artist) {
        var keyArtists: String!
        var keyUsers: String!
        var removeLike = false
        var removeDislike = false
        if like {
            keyArtists = "likedArtists"
            keyUsers = "likeUsers"
        } else {
            keyArtists = "dislikedArtists"
            keyUsers = "dislikeUsers"
        }
        let u = PFUser.currentUser()!
        let artistObject = [PFObject(withoutDataWithClassName: "Artists", objectId: artist.parseId!)]
        if like {
            if tick.selected {
                u.removeObjectsInArray(artistObject, forKey: keyArtists)
            } else {
                if cross.selected {
                    cross.selected = false
                    u.removeObjectsInArray(artistObject, forKey: "dislikedArtists")
                    removeDislike = true
                }
                u.addUniqueObjectsFromArray(artistObject, forKey: keyArtists)
            }
        } else {
            if cross.selected {
                u.removeObjectsInArray(artistObject, forKey: keyArtists)
            } else {
                if tick.selected {
                    tick.selected = false
                    u.removeObjectsInArray(artistObject, forKey: "likedArtists")
                    removeLike = true
                }
                u.addUniqueObjectsFromArray(artistObject, forKey: keyArtists)
            }
        }
        u.saveInBackgroundWithBlock({
            (success, error) -> Void in
            if success && error == nil {
                let query = PFQuery(className: "Artists")
                query.getObjectInBackgroundWithId(artist.parseId!, block: {
                    (object: PFObject?, error) -> Void in
                    if error == nil {
                        if like {
                            if tick.selected {
                                object!.removeObjectsInArray([u], forKey: keyUsers)
                            } else {
                                object!.addUniqueObjectsFromArray([u], forKey: keyUsers)
                                if removeDislike {
                                    object!.removeObjectsInArray([u], forKey: "dislikeUsers")
                                }
                            }
                        } else {
                            if cross.selected {
                                object!.removeObjectsInArray([u], forKey: keyUsers)
                            } else {
                                object!.addUniqueObjectsFromArray([u], forKey: keyUsers)
                                if removeLike {
                                    object!.removeObjectsInArray([u], forKey: "likeUsers")
                                }
                            }
                        }
                        object!.saveInBackgroundWithBlock({
                            (success, error) -> Void in
                            if like {
                                tick.selected = !tick.selected
                                artist.liked = tick.selected
                            } else {
                                cross.selected = !cross.selected
                                artist.disliked = cross.selected
                            }
                        })
                    }
                })
            }
        })
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}