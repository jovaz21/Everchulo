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

    weak var cellDelegate: ImagesCollectionCellDelegate?
    
    var images: [UIImage]? = [UIImage]()
    
    // Awake from NIB
    override func awakeFromNib() { super.awakeFromNib()
        
        /* init */
        imagesCollectionInit()
    }

    // Set Selected
    override func setSelected(_ selected: Bool, animated: Bool) { super.setSelected(selected, animated: animated)
    }
}

// Images CollectionView Stuff
protocol ImagesCollectionCellDelegate:class {
    func collectionView(collectioncell: ImagesCollectionViewCell?, didTappedInTableView tableCell: NoteTableViewCell)
}
extension NoteTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    // Init
    func imagesCollectionInit() {
        
        /* init */
        imagesStackView.isHidden = true
        
        /* register */
        imagesCollectionView.register(UINib.init(nibName: "ImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImagesCollectionViewCell")
        
        /* layout */
        /*
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 100, height: 140)
        flowLayout.minimumLineSpacing = 2.0
        flowLayout.minimumInteritemSpacing = 5.0
        self.imagesCollectionView.collectionViewLayout = flowLayout
 */
        let flowLayout = self.imagesCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: 100, height: 140)
        
        /* set */
        self.imagesCollectionView.dataSource    = self
        self.imagesCollectionView.delegate      = self
    }
    
    //MARK: Instance Methods
    func setImages(images: [UIImage]) {
        self.images = images
        self.imagesStackView.isHidden = false
    }
    
    //MARK: CollectionView Datasource+Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? ImagesCollectionViewCell
        self.cellDelegate?.collectionView(collectioncell: cell, didTappedInTableView: self)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int { return(1) }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return(images!.count)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        /* set */
        let cellId  = "ImagesCollectionViewCell"
        let cell    = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImagesCollectionViewCell

        /* set */
        let image = images![indexPath.item]
        
        /* set */
        cell.imageView.image = image
        
        /* donde */
        return(cell)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 5, 0, 5)
    }
}
