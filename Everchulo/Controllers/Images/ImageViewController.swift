//
//  ImageViewController.swift
//  Everchulo
//
//  Created by ATEmobile on 10/4/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

// ImageView Controller
class ImageViewController {
    let model: Image
    
    var backView: UIView?
    var image: UIImage?
    var imageView: UIImageView?
    
    // MARK: - Init
    init(model: Image, image: UIImage? = nil) {
        self.model = model
        self.image = image
    }
    
    // Hide
    func hide() {
        guard let imageView = self.imageView else {
            return
        }
        imageView.removeFromSuperview()
    }
    
    // Show
    func show(in backView: UIView) { self.backView = backView
        guard let image = self.getImage() else { return }
        
        /* set */
        let size        = image.size
        let aspectRatio = size.width / size.height
        let topRatio    = CGFloat(self.model.topRatio)
        let leftRatio   = CGFloat(self.model.leftRatio)
        let heightRatio = CGFloat(self.model.heightRatio)
        
        /* create */
        self.imageView = UIImageView(image: image)
        guard let imageView = self.imageView else {
            return
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        backView.addSubview(imageView)
        
        /* constraints */
        let topImgConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: backView, attribute: .bottom, multiplier: topRatio, constant: 0)
        let heightImgConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: backView, attribute: .height, multiplier: heightRatio, constant: 0)
        let leftImgConstraint = NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: backView, attribute: .right, multiplier: leftRatio, constant: 0)
        let widthImgConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: backView, attribute: .height, multiplier: (heightRatio * aspectRatio), constant: 0)
        
        var imgConstraints = [NSLayoutConstraint]()
        imgConstraints.append(contentsOf: [topImgConstraint,heightImgConstraint,leftImgConstraint,widthImgConstraint])
        
        /* set */
        backView.addConstraints(imgConstraints)
        
        /* done */
        return
    }
    
    // Get Image
    private func getImage() -> UIImage? {
        
        /* check */
        if (self.image == nil) {
            self.image = UIImage(data: self.model.data! as Data)
        }
        
        /* done */
        return(self.image)
    }
}
