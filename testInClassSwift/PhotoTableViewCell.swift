//
//  PhotoTableViewCell.swift
//  testInClassSwift
//
//  Created by Aaron saunders on 3/14/15.
//  Copyright (c) 2015 Clearly Innovative Inc. All rights reserved.
//

import UIKit
import Haneke

class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var thumbView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        thumbView?.hnk_cancelSetImage()
        thumbView?.image = nil
    }


}
