//
//  NoteInfosViewController.swift
//  Everchulo
//
//  Created by ATEmobile on 12/4/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

// MARK: - Controller Stuff
class NoteInfosViewController: UIViewController {
    let note: Note
    
    // MARK: - Init
    init(note: Note) {
        self.note = note
        
        /* set */
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        self.title = i18NString("NoteInfosViewController.title")
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
    }
    
    // MARK: - Outlets
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!
    @IBOutlet weak var alarmDateLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPlaceholder: UIImageView!
    
    // MARK: - User Actions

    // On Placeholder Tapped
    func onPlaceholderTapped() {
        
        /* set */
        let locationSelectorVC = LocationSelectorViewController(note: self.note)
        locationSelectorVC.delegate = self
        
        /* show */
        self.present(locationSelectorVC.wrappedInNavigation(), animated: true)
    }
    
    // On Done
    func onDone() {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    // Paint UIView
    //  - Map Model Properties with View Data
    //  - Set UIView Data
    func paintUIView() {
        let createdDate: Date? = Date(timeIntervalSince1970: note.createdTimestamp)
        let updatedDate: Date? = Date(timeIntervalSince1970: note.updatedTimestamp)
        var alarmDate: Date? = Date(timeIntervalSince1970: note.alarmTimestamp)
        var location: CLLocation? = CLLocation(latitude: note.latitude, longitude: note.longitude)
        
        /* check */
        if (note.alarmTimestamp <= 0) {
            alarmDate = nil
        }
        if ((note.latitude <= 0) && (note.longitude <= 0)) {
            location = nil
        }
        
        /* set */
        self.setUIViewData(NoteInfosViewData(
            createdDate:    createdDate,
            updatedDate:    updatedDate,
            alarmDate:      alarmDate,
            location:       location
        ))
    }
    
    // MARK: - Action Buttons
    var okButtonItem: UIBarButtonItem!
}

// MARK: - View Stuff
struct NoteInfosViewData {
    let createdDate:    Date?
    let updatedDate:    Date?
    let alarmDate:      Date?
    let location:       CLLocation?
}
extension NoteInfosViewController {
    
    // Setup UIView
    func setupUIView() {
        
        /* NAVIGATIONBAR */
        self.navigationController?.navigationBar.tintColor = Styles.activeColor
        
        self.okButtonItem = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(noteInfosDoneAction))
        self.okButtonItem.tintColor = Styles.activeColor
        self.navigationItem.leftBarButtonItem = self.okButtonItem
        
        /* MAP VIEW */
        self.mapView.isUserInteractionEnabled = true
        self.mapView.isScrollEnabled = false
        self.mapView.isZoomEnabled = false
        self.mapView.isPitchEnabled = false
        self.mapView.delegate = self
        self.mapView.isHidden = true
        
        self.mapPlaceholder.isHidden = true
        self.mapPlaceholder.isUserInteractionEnabled = true
        
        /* */
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(onPlaceholderTapGesture))
        singleTapGesture.numberOfTapsRequired = 1
        self.mapPlaceholder.addGestureRecognizer(singleTapGesture)
    }
    @objc func onPlaceholderTapGesture(tapGesture: UITapGestureRecognizer) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
            self.onPlaceholderTapped()
        })
    }
    @objc func noteInfosDoneAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.025, execute: {
            self.onDone()
        })
    }
    
    // Release UIView
    func releaseUIView() {
    }
    
    // Set UIView Data
    //  - Makes UIView Display ViewData
    func setUIViewData(_ data: NoteInfosViewData) {
        
        /* */
        print("!!! setUIViewData: Entering, data=", data)
        
        /* location */
        self.mapView.isHidden = (data.location == nil)
        self.mapPlaceholder.isHidden = (data.location != nil)
        if (data.location != nil) {
            
            /* reset */
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            /* add */
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: data.location!.coordinate.latitude, longitude: data.location!.coordinate.longitude)
            self.mapView.addAnnotation(annotation)
            
            let regionRadius: CLLocationDistance = 200
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(data.location!.coordinate,
                                                                          regionRadius * 2.0, regionRadius * 2.0)
            self.mapView.setRegion(coordinateRegion, animated: false)
        }
        
        /* */
        print("!!! setUIViewData: Done")
        return
    }
    
    // MARK: - Instance Methods
}


// Map View Delegate
extension NoteInfosViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        /* set */
        let locationSelectorVC = LocationSelectorViewController(note: self.note)
        locationSelectorVC.delegate = self
        
        /* show */
        self.present(locationSelectorVC.wrappedInNavigation(), animated: true)
    }
}

// LocationSelectorViewController Delegate
extension NoteInfosViewController: LocationSelectorViewControllerDelegate {
    func locationSelectorViewController(_ vc: LocationSelectorViewController, didSelectLocation value: CLLocation?) {
        
        /* */
        guard let location = value else {
            
            /* set */
            self.note.latitude = 0.0
            self.note.longitude = 0.0
            self.note.save()
            
            /* */
            self.paintUIView()
            return
        }
        
        /* set */
        self.note.latitude = location.coordinate.latitude
        self.note.longitude = location.coordinate.longitude
        self.note.save()
        
        /* */
        self.paintUIView()
        return
    }
}
