//
//  ArtistInfoViewController.swift
//  FestivalApp
//
//  Created by Ben Gray on 30/07/2015.
//  Copyright (c) 2015 YRS. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ArtistInfoViewController: UIViewController {

    @IBOutlet var artistImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var bioLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var cross: UIButton!
    @IBOutlet var tick: UIButton!
    var artist: Artist!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = artist.name
        cross.setImage(UIImage(named: "Cross Full Large"), forState: .Selected)
        tick.setImage(UIImage(named: "Tick Full Large"), forState: .Selected)
        tick.selected = false
        cross.selected = false
        if artist.liked! {
            tick.selected = true
        }
        if artist.disliked! {
            cross.selected = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
