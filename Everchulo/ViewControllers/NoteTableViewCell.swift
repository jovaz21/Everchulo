//
//  NoteTableViewCell.swift
//  Everchulo
//
//  Created by ATEmobile on 23/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    
    // Awake from NIB
    override func awakeFromNib() { super.awakeFromNib()
        imageStackView.isHidden = true
        imageView1.isHidden = true
        imageView2.isHidden = true
        imageView3.isHidden = true
    }

    // Set Selected
    override func setSelected(_ selected: Bool, animated: Bool) { super.setSelected(selected, animated: animated)
    }
}
