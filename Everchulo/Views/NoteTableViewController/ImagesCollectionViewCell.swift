//
//  ImagesCollectionViewCell.swift
//  Everchulo
//
//  Created by ATEmobile on 24/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

class ImagesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var imageName:String?
    
    // CustomCell
    class var CustomCell : ImagesCollectionViewCell {
        let cell = Bundle.main.loadNibNamed("ImagesCollectionViewCell", owner: self, options: nil)?.last
        return(cell as! ImagesCollectionViewCell)
    }
    
    // Awake from NIB
    override func awakeFromNib() { super.awakeFromNib()
    }    
}
