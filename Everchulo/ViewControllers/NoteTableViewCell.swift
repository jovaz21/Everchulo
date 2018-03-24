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

    // Awake from NIB
    override func awakeFromNib() { super.awakeFromNib()
        //firstImage.isHidden = true
    }

    // Set Selected
    override func setSelected(_ selected: Bool, animated: Bool) { super.setSelected(selected, animated: animated)
    }
}
