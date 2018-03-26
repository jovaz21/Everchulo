//
//  ImageDetailViewController.swift
//  Everchulo
//
//  Created by ATEmobile on 25/3/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit

// MARK: - Controller Stuff
class ImageDetailViewController: UIViewController {
    let image: UIImage
    
    // MARK: - Properties
    var loaded: Bool = false
    var isZoomed: Bool = false
    var curScale: CGFloat = 1.0
    var newScale: CGFloat = 1.0
    var curPosition: CGPoint!                       // LongPressGesture
    var lastLocation:CGPoint = CGPoint(x: 0, y: 0)  // PanGesture
    
    // MARK: - Init
    init(image: UIImage) {
        
        /* set */
        self.image = image
        
        /* set */
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        self.title = ""
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // View Is Loaded:
    // Setup UIView Layer
    override func viewDidLoad() { super.viewDidLoad()
        
        // Setup UIView
        self.setupUIView()
    }
    
    // View Will Appear:
    //  - Paint UIView
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated)
        
        // Paint UIView
        self.paintUIView()
    }

    // MARK: - Outlets for View Stuff
    @IBOutlet weak var topStackConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftStackConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightStackConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomStackConstraint: NSLayoutConstraint!

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    
    // Paint UIView
    //  - Map Model Properties with View Data
    //  - Set UIView Data
    func paintUIView() {
        self.setUIViewData(ImageDetailViewData(image: self.image))
        
        /* set */
        self.loaded = true
        self.setNeedsStatusBarAppearanceUpdate()
    }
}

// MARK: - View Stuff
struct ImageDetailViewData {
    let image: UIImage
}
extension ImageDetailViewController {
    
    // Setup UIView
    func setupUIView() {
        
        /* Black */
        self.view.backgroundColor = .black
        self.imageView.backgroundColor = .black
        
        /* Enable Interactions with ImageView */
        imageView.isUserInteractionEnabled = true
        
        // DOUBLE TAP => ZOOM IN/OUT
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(zoomInOutImage))
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesture)
        
        // PINCH => SCALE IMAGE
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaleImage))
        pinchGesture.delegate = self
        imageView.addGestureRecognizer(pinchGesture)
        
        // LONG PRESS => DRAG IMAGE
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(dragImage))
        imageView.addGestureRecognizer(longPressGesture)
        
        // PAN GESTURE => DRAG IMAGE
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler))
        panGesture.delegate = self
        imageView.addGestureRecognizer(panGesture)
    }
    @objc func zoomInOutImage() {
        if ((self.leftStackConstraint.constant != 0) || (self.rightStackConstraint.constant != 0) || (self.topStackConstraint.constant != 0) || (self.bottomStackConstraint.constant != 0)) {
            
            /* reset */
            self.doScaleImageView(1.0, andMoveToX: 0, y: 0)
            self.curScale = 1.0
            self.isZoomed = false
            
            /* done */
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            return
        }
        if (isZoomed) {
            self.doScaleImageView(1.0)
            self.curScale = 1.0
            self.isZoomed = false
        }
        else {
            self.doScaleImageView(2.0)
            self.curScale = 2.0
            self.isZoomed = true
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    @objc func scaleImage(gesture: UIPinchGestureRecognizer) {
        switch (gesture.state) {
        case .began:
            self.newScale = self.curScale
            break
        case .ended, .cancelled:
            
            /* adjust */
            self.adjustImagePositionIfNeeded()
            
            /* set */
            self.curScale = self.newScale
            if (self.curScale == 1.0) {
                self.isZoomed = false
            }
            else {
                self.isZoomed = true
            }
            break
        case .changed:
            var scale = gesture.scale * self.curScale
            if (scale <= 1.0) {
                scale = 1.0
            }
            else if (scale >= 6.0) {
                scale = 6.0
            }
            doScaleImageView(scale)
            break
        default:
            break
        }
    }
    func adjustImagePositionIfNeeded() {
        
        /* set */
        var leftConstant    = self.leftStackConstraint.constant
        var topConstant     = self.topStackConstraint.constant
        var rightConstant   = self.rightStackConstraint.constant
        var bottomConstant  = self.bottomStackConstraint.constant
        
        /* check */
        print("Pinch Ended: ", leftConstant, topConstant, rightConstant, bottomConstant)
        if (leftConstant > 0) {
            rightConstant = rightConstant + leftConstant
            leftConstant = 0
        }
        if (topConstant > 0) {
            bottomConstant = bottomConstant + topConstant
            topConstant = 0
        }
        if (rightConstant > 0) {
            leftConstant = leftConstant + rightConstant
            rightConstant = 0
        }
        if (bottomConstant > 0) {
            topConstant = topConstant + bottomConstant
            bottomConstant = 0
        }
        print("Adjusted: ", leftConstant, topConstant, rightConstant, bottomConstant)
        self.leftStackConstraint.constant   = leftConstant
        self.topStackConstraint.constant    = topConstant
        self.rightStackConstraint.constant  = rightConstant
        self.bottomStackConstraint.constant = bottomConstant
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    func doScaleImageView(_ scale: CGFloat, andMoveToX x: CGFloat? = nil, y: CGFloat? = nil) {
        print("Scale Image: ", scale)
        
        /* */
        print("Current Position", self.leftStackConstraint.constant, self.topStackConstraint.constant, self.rightStackConstraint.constant, self.bottomStackConstraint.constant)
        
        /* set */
        let curWidth    = self.stackView.bounds.width
        let curHeight   = self.stackView.bounds.height
        print("Current Dimensions", curWidth, curHeight)

        /* set */
        let newWidth    = self.view.bounds.width * scale
        let ratio       = self.view.bounds.height / self.view.bounds.width
        let newHeight   = newWidth * ratio
        print("New Dimensions", newWidth, newHeight)
        
        /* set */
        let diffConstantX = (curWidth - newWidth) / 2
        let diffConstantY = (curHeight - newHeight) / 2
        
        /* set */
        var leftConstant    = self.leftStackConstraint.constant + diffConstantX
        var topConstant     = self.topStackConstraint.constant + diffConstantY
        if ((x != nil) && (y != nil)) {
            leftConstant    = x!
            topConstant     = y!
        }
        
        /* set */
        var rightConstant   = self.view.bounds.width - newWidth - leftConstant
        var bottomConstant  = self.view.bounds.height - newHeight - topConstant
    
        /* round */
        leftConstant    = leftConstant.rounded(.toNearestOrAwayFromZero)
        topConstant     = topConstant.rounded(.toNearestOrAwayFromZero)
        rightConstant   = rightConstant.rounded(.toNearestOrAwayFromZero)
        bottomConstant  = bottomConstant.rounded(.toNearestOrAwayFromZero)
        
        /* set */
        print(leftConstant, topConstant, rightConstant, bottomConstant)
        self.leftStackConstraint.constant = leftConstant
        self.topStackConstraint.constant = topConstant
        self.rightStackConstraint.constant = rightConstant
        self.bottomStackConstraint.constant = bottomConstant
        
        /* set */
        self.newScale = scale
        if (self.newScale <= 1.0) {
            self.newScale = 1.0
        }
        else if (self.newScale >= 6.0) {
            self.newScale = 6.0
        }
        
        /* done */
        return
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        lastLocation = CGPoint(x: self.leftStackConstraint.constant, y: self.topStackConstraint.constant)
    }
    @objc func panGestureHandler_IntentandoContinuarElMovimientoDelUser(recognizer: UIPanGestureRecognizer) {
        let delta = recognizer.translation(in: self.view)
        
        /* */
        print("PAN VELOCITY: ", recognizer.velocity(in: self.view))
        
        /* check */
        if (recognizer.state == .ended) {
            var deltaX = delta.x
            var deltaY = delta.y
            
            /* check */
            if ((recognizer.velocity(in: self.view).x >= 150) || (recognizer.velocity(in: self.view).x <= -150)) {
                deltaX = deltaX + recognizer.velocity(in: self.view).x
            }
            if ((recognizer.velocity(in: self.view).y >= 150) || (recognizer.velocity(in: self.view).y <= -150)) {
                deltaY = deltaY + recognizer.velocity(in: self.view).y
            }
            
            /* move */
            self.doMoveImageTo(x: self.lastLocation.x + deltaX, y: self.lastLocation.y + deltaY)
            
            /* done */
            UIView.animate(withDuration: 1.0) {
                self.view.layoutIfNeeded()
                if (recognizer.state == .ended) {
                    self.adjustImagePositionIfNeeded()
                }
            }
            return
        }
        
        /* move */
        self.doMoveImageTo(x: self.lastLocation.x + delta.x, y: self.lastLocation.y + delta.y)
        if (recognizer.state == .ended) {
            self.adjustImagePositionIfNeeded()
        }
    }
    @objc func panGestureHandler(recognizer: UIPanGestureRecognizer) {
        let delta = recognizer.translation(in: self.view)
        self.doMoveImageTo(x: self.lastLocation.x + delta.x, y: self.lastLocation.y + delta.y)
        if (recognizer.state == .ended) {
            self.adjustImagePositionIfNeeded()
        }
    }
    @objc func dragImage(gesture: UILongPressGestureRecognizer) {
        switch (gesture.state) {
        case .began:
            self.curPosition = gesture.location(in: gesture.view)
            break
        case .ended, .cancelled:
            self.adjustImagePositionIfNeeded()
            break
        case .changed:
            let location = gesture.location(in: self.view)
            self.doMoveImageTo(x: location.x - self.curPosition.x, y: location.y - self.curPosition.y)
            break
        default:
            break
        }
    }
    func doMoveImageTo(x: CGFloat, y: CGFloat) {
        let leftConstant    = x
        let topConstant     = y
        
        /* set */
        let rightConstant   = self.view.bounds.width - self.stackView.bounds.width - leftConstant
        let bottomConstant  = self.view.bounds.height - self.stackView.bounds.height - topConstant
        
        /* check */
        //if (leftConstant > 0) { return }
        //if (topConstant > 0) { return }
        //if (rightConstant > 0) { return }
        //if (bottomConstant > 0) { return }
        
        /* set */
        print(leftConstant, topConstant, rightConstant, bottomConstant)
        self.leftStackConstraint.constant = leftConstant
        self.topStackConstraint.constant = topConstant
        self.rightStackConstraint.constant = rightConstant
        self.bottomStackConstraint.constant = bottomConstant
    }
    
    // Set UIView Data
    func setUIViewData(_ data: ImageDetailViewData) {
        imageView.image = data.image
    }
    
    override var prefersStatusBarHidden: Bool {
        return(self.loaded)
    }
}

extension ImageDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return(false)
    }
}
