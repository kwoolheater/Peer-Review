//
//  CommentsTableViewCell.swift
//  Peer Review
//
//  Created by Kiyoshi Woolheater on 1/4/19.
//  Copyright © 2019 Kiyoshi Woolheater. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet var starNumberLabel: UILabel!
    @IBOutlet var ratingDescriptionLabel: UITextView!
    @IBOutlet var dividerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // in case these were not set in IB
        ratingDescriptionLabel.delegate = self
        ratingDescriptionLabel.isScrollEnabled = false
    }
    
}
