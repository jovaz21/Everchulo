//
//  LocationSelectorViewController.swift
//  Everchulo
//
//  Created by ATEmobile on 12/4/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

// LocationSelectorViewController Delegate
protocol LocationSelectorViewControllerDelegate: AnyObject {
    func locationSelectorViewController(_ vc: LocationSelectorViewController, didSelectLocation location: CLLocation?)
}

// MARK: - Controller Stuff
class LocationSelectorViewController: UIViewController {
    let note: Note?
    
    var mark: MKAnnotation?
    var location: CLLocation? {
        if (note == nil) {
            return(nil)
        }
        if ((note!.latitude <= 0) && (note!.longitude <= 0)) {
            return(nil)
        }
        return(CLLocation(latitude: note!.latitude, longitude: note!.longitude))
    }
    
    // Delegate
    weak var delegate: LocationSelectorViewControllerDelegate?
    
    // MARK: - Init
    init(note: Note?) {
        self.note = note
        
        /* set */
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        self.title = i18NString("LocationSelectorViewController.title")
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // View Is Loaded:
    // Setup UIView Layer
    override func viewDidLoad() { super.viewDidLoad()
        self.setupUIView()
    }
    
    // View Will Appear:
    //  - Paint UIView
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated)
        
        // Paint UIView
        self.paintUIView()
        
        // Init Location
        self.onInitLocation()
    }
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Location Did Change
    func locationDidChange(_ value: CLLocation?) {
        if (self.delegate != nil) { // Delegate
            self.delegate!.locationSelectorViewController(self, didSelectLocation: value)
        }
    }
    
    // MARK: - User Actions
    
    // On Close
    func onClose() {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    // On Init Location
    func onInitLocation() {
        guard let location = self.location else {
            return
        }
        
        /* add */
        self.addMark(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        /* zoom */
        let regionRadius: CLLocationDistance = 200
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                      regionRadius * 2.0, regionRadius * 2.0)
        self.mapView.setRegion(coordinateRegion, animated: false)
    }
    
    // On Set Location
    func onSetLocation() {
        
        /* add */
        let centerCoords = self.mapView.centerCoordinate
        self.addMark(latitude: centerCoords.latitude, longitude: centerCoords.longitude)
        
        /* set */
        self.navigationItem.rightBarButtonItem = self.resetButtonItem
        
        /* */
        self.locationDidChange(CLLocation(latitude: centerCoords.latitude, longitude: centerCoords.longitude))
    }

    // On Reset Location
    func onResetLocation() {
        
        /* remove */
        self.removeMark()
        
        /* set */
        self.navigationItem.rightBarButtonItem = self.setButtonItem
        
        /* */
        self.locationDidChange(nil)
    }
    
    // Paint UIView
    //  - Map Model Properties with View Data
    //  - Set UIView Data
    func paintUIView() {
        var location: CLLocation? = CLLocation(latitude: (note?.latitude)!, longitude: (note?.longitude)!)
        
        /* check */
        if ((location!.coordinate.latitude <= 0) && (location!.coordinate.longitude <= 0)) {
            location = nil
        }
        
        /* set */
        self.setUIViewData(LocationSelectorViewData(
            location: location
        ))
    }
    
    // MARK: - Action Buttons
    var closeButtonItem: UIBarButtonItem!
    var setButtonItem: UIBarButtonItem!
    var resetButtonItem: UIBarButtonItem!
}

// MARK: - View Stuff
struct LocationSelectorViewData {
    let location: CLLocation?
}
extension LocationSelectorViewController {
    
    // Setup UIView
    func setupUIView() {
        
        /* NAVIGATIONBAR */
        self.navigationController?.navigationBar.tintColor = Styles.activeColor
        
        self.closeButtonItem = UIBarButtonItem(title: i18NString("es.atenet.app.Close"), style: .done, target: self, action: #selector(closeAction))
        self.closeButtonItem.tintColor = Styles.activeColor
        self.navigationItem.leftBarButtonItem = self.closeButtonItem
        
        self.setButtonItem = UIBarButtonItem(title: i18NString("LocationSelectorViewController.setLocationBtn"), style: .done, target: self, action: #selector(setLocationAction))
        self.setButtonItem.tintColor = Styles.activeColor
         self.resetButtonItem = UIBarButtonItem(title: i18NString("LocationSelectorViewController.resetLocationBtn"), style: .done, target: self, action: #selector(resetLocationAction))
        self.resetButtonItem.tintColor = Styles.activeColor
        
        /* check */
        if (self.location == nil) {
            self.navigationItem.rightBarButtonItem = self.setButtonItem
        }
        else {
            self.navigationItem.rightBarButtonItem = self.resetButtonItem
        }

        /* MAP VIEW */
        self.mapView.delegate = self
        self.mapView.isUserInteractionEnabled = true
        
 /*       UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
            initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 2.0; //user needs to press for 2 seconds
        [self.mapView addGestureRecognizer:lpgr];
        [lpgr release];
        Then in the gesture handler:
        
        - (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
        {
            if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
            return;
            
            CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
            CLLocationCoordinate2D touchMapCoordinate =
                [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
            
            YourMKAnnotationClass *annot = [[YourMKAnnotationClass alloc] init];
            annot.coordinate = touchMapCoordinate;
            [self.mapView addAnnotation:annot];
            [annot release];
        }
*/

    }
    @objc func setLocationAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
            self.onSetLocation()
        })
    }
    @objc func resetLocationAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
            self.onResetLocation()
        })
    }
    @objc func closeAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
            self.onClose()
        })
    }
    
    // Release UIView
    func releaseUIView() {
    }
    
    // Set UIView Data
    //  - Makes UIView Display ViewData
    func setUIViewData(_ data: LocationSelectorViewData) {
        
        /* */
        print("!!! setUIViewData: Entering, data=", data)
        
        /* */
        print("!!! setUIViewData: Done")
        return
    }
    
    // MARK: - Instance Methods
    func addMark(latitude: Double, longitude: Double) {
        
        /* add */
        let mark = MKPointAnnotation()
        mark.title = i18NString("LocationSelectorTableViewController.pinLabel")
        mark.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.mapView.addAnnotation(mark)
        
        /* set */
        self.mark = mark
    }
    func removeMark() {
        self.mapView.removeAnnotation(self.mark!)
    }
}


// Map View Delegate
extension LocationSelectorViewController: MKMapViewDelegate {
    
    // Annotation Dragging Stuff
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if ((newState == .ending) || (newState == .canceling)) {
            self.locationDidChange(CLLocation(latitude: view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude))
        }
    }
    
    // Custom Annotation Mark
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationIdentifier = "AnnotationIdentifier"
        
        /* check */
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        /* check */
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.isDraggable = true
            annotationView!.isEnabled = true
            annotationView!.canShowCallout = true
            annotationView!.isSelected = true
        }
            
        /* set */
        annotationView!.annotation = annotation

        /* done */
        return(annotationView)
    }
}
