//
//  MatchmakingHeaderView.swift
//  FestivalApp
//
//  Created by Ben Gray on 30/07/2015.
//  Copyright (c) 2015 YRS. All rights reserved.
//

import UIKit

class MatchmakingHeaderView: UIView {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!
    
    func like(t: Int) {
        if t == 0 {
            imageView.image = UIImage(named: "Tick Full")
            label.text = "Similar Likes"
        } else {
            imageView.image = UIImage(named: "Cross Full")
            label.text = "Similar Dislikes"
        }
    }

}
