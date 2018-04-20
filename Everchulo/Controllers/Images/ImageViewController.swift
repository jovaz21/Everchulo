//
//  ImageViewController.swift
//  Everchulo
//
//  Created by ATEmobile on 10/4/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

// ImageViewControllerDelegate {
protocol ImageViewControllerDelegate: AnyObject {
    func imageViewController(_ vc: ImageViewController, willHandleGesture imageView: UIImageView, model: Image)
    func imageViewController(_ vc: ImageViewController, didBringForeground imageView: UIImageView, model: Image)
    func imageViewController(_ vc: ImageViewController, didSelect imageView: UIImageView, model: Image)
}

// ImageView Controller
class ImageViewController: UIViewController {
    let model: Image
    
    // MARK: - Properties
    var leftImgConstraint: NSLayoutConstraint?
    var topImgConstraint: NSLayoutConstraint?
    var heightImgConstraint: NSLayoutConstraint?
    var widthImgConstraint: NSLayoutConstraint?
    
    var lastLocation:CGPoint = CGPoint(x: 0, y: 0)  // PanGesture
    
    var curScale: CGFloat = 1.0
    var newScale: CGFloat = 1.0
    
    var newRotation: CGFloat = 0.0
    
    weak var backView: UIView?
    var image: UIImage?
    var imageView: UIImageView?
    
    // Delegate
    weak var delegate: ImageViewControllerDelegate?
    
    // MARK: - Init
    init(model: Image, image: UIImage? = nil) {
        
        /* set */
        self.model = model
        self.image = image
        
        /* set */
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
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
        let rotation    = CGFloat(self.model.rotation)
        
        /* create */
        self.imageView = UIImageView(image: image)
        guard let imageView = self.imageView else {
            return
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.transform = imageView.transform.rotated(by: rotation)
        backView.addSubview(imageView)
        
        /* constraints */
        self.topImgConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: backView, attribute: .bottom, multiplier: topRatio, constant: 0)
        self.leftImgConstraint = NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: backView, attribute: .right, multiplier: leftRatio, constant: 0)
        self.heightImgConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: backView, attribute: .height, multiplier: heightRatio, constant: 0)
        self.widthImgConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: backView, attribute: .height, multiplier: (heightRatio * aspectRatio), constant: 0)
        
        var imgConstraints = [NSLayoutConstraint]()
        imgConstraints.append(contentsOf: [topImgConstraint!,heightImgConstraint!,leftImgConstraint!,widthImgConstraint!])
        
        /* set */
        backView.addConstraints(imgConstraints)
        
        // PAN GESTURE => DRAG IMAGE
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler))
        panGesture.delegate = self
        imageView.addGestureRecognizer(panGesture)
        
        // PINCH => SCALE IMAGE
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaleImage))
        pinchGesture.delegate = self
        imageView.addGestureRecognizer(pinchGesture)
        
        // LONG PRESS => SELECT IMAGE
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(longPressGesture)
        
        // ROTATION => IMAGE ROTATION
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateImage))
        imageView.addGestureRecognizer(rotationGesture)
        
        /* done */
        return
    }
    
    // Long Press Gesture
    @objc func selectImage(gesture: UILongPressGestureRecognizer) {
        switch (gesture.state) {
        case .began:
            
            /* */
            if (delegate != nil) { // Delegate
                delegate!.imageViewController(self, willHandleGesture: self.imageView!, model: self.model)
            }
            
            /* set */
            self.setSelected(true)
            
            /* foreground */
            self.backView!.bringSubview(toFront: self.imageView!)
            if (delegate != nil) { // Delegate
                delegate!.imageViewController(self, didBringForeground: self.imageView!, model: self.model)
            }
            break
        case .ended, .cancelled:
            
            /* select */
            if (delegate != nil) { // Delegate
                delegate!.imageViewController(self, didSelect: self.imageView!, model: self.model)
            }
            break
        case .changed:
            break
        default:
            break
        }
    }
    
    // Rotate Gesture
    @objc func rotateImage(gesture: UIRotationGestureRecognizer) {
        switch (gesture.state) {
        case .began:
            
            /* */
            if (delegate != nil) { // Delegate
                delegate!.imageViewController(self, willHandleGesture: self.imageView!, model: self.model)
            }
            
            /* set */
            self.newRotation = CGFloat(self.model.rotation)
            
            /* foreground */
            self.backView!.bringSubview(toFront: self.imageView!)
            if (delegate != nil) { // Delegate
                delegate!.imageViewController(self, didBringForeground: self.imageView!, model: self.model)
            }
            break
        case .ended, .cancelled:
            
            /* set */
            self.model.rotation = Float(self.newRotation)
            print("<ImageViewController> rotateImage: rotation=", self.model.rotation)
            
            /* Save Model State */
            self.model.save()
            break
        case .changed:
            doRotateImageView(gesture.rotation)
            break
        default:
            break
        }
    }
    func doRotateImageView(_ rotation: CGFloat) {
        guard let imageView = self.imageView else {
            return
        }
        
        /* set */
        self.newRotation = CGFloat(self.model.rotation) + rotation
        
        /* rotate */
        imageView.transform = CGAffineTransform.init(rotationAngle: self.newRotation)
        
        /* done */
        return
    }
    
    // Pinch Gesture
    @objc func scaleImage(gesture: UIPinchGestureRecognizer) {
        switch (gesture.state) {
        case .began:
            
            /* */
            if (delegate != nil) { // Delegate
                delegate!.imageViewController(self, willHandleGesture: self.imageView!, model: self.model)
            }
            
            /* */
            self.imageView!.transform = CGAffineTransform.identity
            
            /* set */
            self.curScale = self.imageView!.frame.width / self.image!.size.width
            self.newScale = self.curScale
            
            /* foreground */
            self.backView!.bringSubview(toFront: self.imageView!)
            if (delegate != nil) { // Delegate
                delegate!.imageViewController(self, didBringForeground: self.imageView!, model: self.model)
            }
            break
        case .ended, .cancelled:
            
            /* set */
            self.curScale = self.newScale
            
            /* Save Model State */
            self.saveState()
            
            /* rotate */
            self.imageView!.transform = CGAffineTransform.init(rotationAngle: CGFloat(self.model.rotation))
            break
        case .changed:
            doScaleImageView(gesture.scale)
            break
        default:
            break
        }
    }
    func doScaleImageView(_ scale: CGFloat) {
        guard let imageView = self.imageView else {
            return
        }
        
        /* set */
        let size        = self.image!.size
        let width       = size.width
        let height      = size.height
        let aspectRatio = width / height
        let curWidth    = imageView.frame.width
        let curHeight   = imageView.frame.height
        
        /* set */
        let newScale = self.curScale * scale
        
        /* set */
        let newHeight   = height * newScale
        let newWidth    = newHeight * aspectRatio
        
        let dHeight = newHeight - curHeight
        let dWidth  = newWidth - curWidth
        
        /* set */
        let newHeightRatio = newHeight / self.backView!.frame.height
        
        /* check */
        if (newHeightRatio <= 0.2) {
            return
        }
        
        /* set */
        self.imageView!.frame.origin.x = self.imageView!.frame.origin.x - dWidth/2
        self.imageView!.frame.origin.y = self.imageView!.frame.origin.y - dHeight/2
        self.imageView!.frame.size.width = newWidth
        self.imageView!.frame.size.height = newHeight
        
        /* set */
        self.newScale = newScale
        self.model.heightRatio = Float(newHeightRatio)
        
        /* done */
        return
    }
    
    // Pan Gesture
    @objc func panGestureHandler(recognizer: UIPanGestureRecognizer) {
        
        // BEGAN
        if (recognizer.state == .began) {
            
            /* */
            if (delegate != nil) { // Delegate
                delegate!.imageViewController(self, willHandleGesture: self.imageView!, model: self.model)
            }
            
            /* */
            self.imageView!.transform = CGAffineTransform.identity
            
            /* foreground */
            self.backView!.bringSubview(toFront: self.imageView!)
            if (delegate != nil) { // Delegate
                delegate!.imageViewController(self, didBringForeground: self.imageView!, model: self.model)
            }
            
            /* set */
            self.lastLocation = CGPoint(x: self.imageView!.frame.origin.x, y: self.imageView!.frame.origin.y)
            return
        }
        
        // MOVING
        let delta = recognizer.translation(in: self.backView)
        self.doMoveImageTo(x: self.lastLocation.x + delta.x, y: self.lastLocation.y + delta.y)
        
        // ENDED
        if (recognizer.state == .ended) {
            
            /* Adjust */
            self.adjustImagePositionIfNeeded() {
                
                /* set */
                self.lastLocation = CGPoint(x: self.imageView!.frame.origin.x, y: self.imageView!.frame.origin.y)
            
                /* Save Model State */
                self.saveState()
                
                /* rotate */
                self.imageView!.transform = CGAffineTransform.init(rotationAngle: CGFloat(self.model.rotation))
            }
        }
    }
    
    // Move Image
    func doMoveImageTo(x: CGFloat, y: CGFloat) {
        self.imageView!.frame.origin.x = x
        self.imageView!.frame.origin.y = y
    }
    
    // Adjust Position If Needed
    func adjustImagePositionIfNeeded(completionHandler: @escaping () -> Void) {
        let screenWidth     = self.backView!.frame.width
        let screenHeight    = self.backView!.frame.height

        /* set */
        var x       = self.imageView!.frame.origin.x
        var y       = self.imageView!.frame.origin.y
        let width   = self.imageView!.frame.width
        let height  = self.imageView!.frame.height
        
        /* check */
        if ((width < screenWidth + 10+10) && (height < screenHeight + 80+40) && (self.model.rotation.isZero)) {
            if (x - 10 < 0) {
                x = 10
            }
            if (x + width + 10 > screenWidth) {
                x = screenWidth - width - 10
            }
            if (y - 80 < 0) {
                y = 80
            }
            if (y + height + 40 > screenHeight) {
                y = screenHeight - height - 40
            }
        }
        
        /* set */
        self.imageView!.frame.origin.x = x
        self.imageView!.frame.origin.y = y
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
            completionHandler()
        }
    }
    
    // Save Model State
    func saveState() {
        guard let backView = self.backView, let imageView = self.imageView else {
            return
        }
        
        /* set */
        let size        = self.image!.size
        let aspectRatio = size.width / size.height
        let topRatio    = imageView.frame.origin.y / backView.frame.height
        let leftRatio   = imageView.frame.origin.x / backView.frame.width
        let heightRatio = CGFloat(self.model.heightRatio)
        print("<ImageViewController> saveState: top=", topRatio, ", left=", leftRatio, ", height=", heightRatio)
        
        /* remove */
        backView.removeConstraints([self.topImgConstraint!, self.leftImgConstraint!, self.heightImgConstraint!, self.widthImgConstraint!])
        
        /* constraints */
        self.topImgConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: backView, attribute: .bottom, multiplier: topRatio, constant: 0)
        self.leftImgConstraint = NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: backView, attribute: .right, multiplier: leftRatio, constant: 0)
        self.heightImgConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: backView, attribute: .height, multiplier: heightRatio, constant: 0)
        self.widthImgConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: backView, attribute: .height, multiplier: (heightRatio * aspectRatio), constant: 0)
        
        var imgConstraints = [NSLayoutConstraint]()
        imgConstraints.append(contentsOf: [self.topImgConstraint!,self.leftImgConstraint!,self.heightImgConstraint!,self.widthImgConstraint!])
        
        /* set */
        backView.addConstraints(imgConstraints)
        
        /* set */
        self.model.topRatio = Float(topRatio)
        self.model.leftRatio = Float(leftRatio)
        self.model.save()
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
    
    // Set Selected
    func setSelected(_ value: Bool) {
        if (value) {
            self.imageView!.alpha = 0.7
        }
        else {
            self.imageView!.alpha = 1.0
        }
    }
}

// UIGestureRecognizer Delegate
extension ImageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return(false)
    }
}
