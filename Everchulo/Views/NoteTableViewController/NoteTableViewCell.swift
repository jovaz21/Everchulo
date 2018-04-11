//
//  NoteTableViewCell.swift
//  Everchulo
//
//  Created by ATEmobile on 23/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

// Notes TableView Custom Cell
class NoteTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var imagesStackView: UIStackView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!

    // Images CollectionView
    static let IMAGES_SIZE      = CGSize(width: 100, height: 140)
    static let IMAGES_CELLID    = "ImagesCollectionViewCell"
    
    weak var cellDelegate: ImagesCollectionCellDelegate?
    var images: [UIImage]? = [UIImage]()
    
    class var newLoadedCell: NoteTableViewCell {
        let cell = Bundle.main.loadNibNamed("NoteTableViewCell", owner: self, options: nil)?.last
        return(cell as! NoteTableViewCell)
    }
    
    // Awake from NIB
    override func awakeFromNib() { super.awakeFromNib()
        
        /* init */
        imagesCollectionInit()
    }

    // Set Selected
    override func setSelected(_ selected: Bool, animated: Bool) { super.setSelected(selected, animated: animated)
    }
}

// Images CollectionView Management
protocol ImagesCollectionCellDelegate:class {
    func collectionView(imageCell: ImagesCollectionViewCell?, didTappedInTableView tableCell: NoteTableViewCell)
}
extension NoteTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    // Init
    func imagesCollectionInit() {
        
        /* init */
        imagesStackView.isHidden = true
        
        /* Register Custom Cell */
        imagesCollectionView.register(UINib.init(nibName: "ImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: NoteTableViewCell.IMAGES_CELLID)
        
        /* Layout Images Size */
        let flowLayout = self.imagesCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = NoteTableViewCell.IMAGES_SIZE
        
        /* set */
        self.imagesCollectionView.dataSource    = self
        self.imagesCollectionView.delegate      = self
    }
    
    //MARK: Instance Methods
    func setImages(images: [UIImage]) {
        self.images = images
        self.imagesStackView.isHidden = (self.images!.count <= 0)
    }
    
    //MARK: CollectionView Datasource+Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? ImagesCollectionViewCell
        self.cellDelegate?.collectionView(imageCell: cell, didTappedInTableView: self)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int { return(1) }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return(images!.count)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        /* set */
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteTableViewCell.IMAGES_CELLID, for: indexPath) as! ImagesCollectionViewCell
        
        /* set */
        cell.imageView.image = images![indexPath.item]
        
        /* donde */
        return(cell)
    }
}
