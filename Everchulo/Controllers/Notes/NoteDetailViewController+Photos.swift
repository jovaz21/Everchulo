//
//  NoteDetailViewController+Photos.swift
//  Everchulo
//
//  Created by ATEmobile on 10/4/18.
//  Copyright © 2018 ATEmobile. All rights reserved.
//

import AVFoundation
import UIKit

// MARK: - View Stuff
extension NoteDetailViewController {
    
    // Paint ImageViews
    func paintImageViews(_ data: NoteViewData) {
        guard let note = self.note else {
            return
        }
        if (self.imageViewControllers.count > 0) {
            return
        }
        
        /* scan */
        note.sortedImages.forEach() { (image) in
            
            /* ImageView Controller */
            let imageVC = ImageViewController(model: image)
            imageVC.delegate = self
            imageVC.show(in: self.view!)
            
            /* add */
            self.imageViewControllers.append(imageVC)
        }
    }
    
    // Release
    func releaseImageViews() {
        self.imageViewControllers.forEach() { $0.hide() }
        self.imageViewControllers = [ImageViewController]()
    }
    
    // Image Action Menu
    @objc func displayImageMenuAction() {
        var imagePicker: UIImagePickerController?
        
        /* */
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.075, execute: {
            imagePicker = UIImagePickerController()
            imagePicker!.navigationBar.tintColor = Styles.activeColor
            imagePicker!.delegate = self
        })
        
        /* menu */
        let actionSheetMenu = makeActionSheetMenu(from: self.cameraButtonItem!, title: nil, message: nil, items:
            (
                title:      i18NString("NoteDetailsViewController.photo.fromCameraMsg"),
                style:      .default,
                image:      nil,
                hidden:     false,
                handler:    { (alertAction) in
                    if (imagePicker == nil) {
                        return
                    }
                    if (self.isCameraAuthorized(for: imagePicker!)) {
                        imagePicker!.sourceType = .camera
                        self.present(imagePicker!, animated: true, completion: nil)
                    }
            }
            ),
            (
                title:      i18NString("NoteDetailsViewController.photo.fromLibraryMsg"),
                style:      .default,
                image:      nil,
                hidden:     false,
                handler:    { (alertAction) in
                    if (imagePicker == nil) {
                        return
                    }
                    imagePicker!.sourceType = .photoLibrary
                    self.present(imagePicker!, animated: true, completion: nil)
                }
            ),
            (
                title:      i18NString("es.atenet.app.Cancel"),
                style:      .cancel,
                image:      nil,
                hidden:     false,
                handler:    nil
            )
        )
        
        /* present */
        self.present(actionSheetMenu, animated: true, completion: nil)
        
    }
    func isCameraAuthorized(for imagePicker: UIImagePickerController) -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if (status == .notDetermined) {
            self.askForUserPermission(for: imagePicker)
            return(false)
        }
        if ((status == .restricted) || (status == .denied)) {
            self.goToAppSettings()
            return(false)
        }
        return(true)
    }
    func askForUserPermission(for imagePicker: UIImagePickerController) {
        
        /* confirm */
        let confirmDialog = makeConfirmDialog(title: i18NString("NoteDetailsViewController.photo.askForUserAuthTitle"), message: i18NString("NoteDetailsViewController.photo.askForUserAuthMsg"), okAction:
            (
                title:      i18NString("es.atenet.app.Accept"),
                style:      .default,
                handler:    { (action) in
                    imagePicker.sourceType = .camera
                    self.present(imagePicker, animated: true, completion: nil)
                }
            ), cancelAction: (
                title:      i18NString("es.atenet.app.NotNow"),
                style:      .default,
                handler:    { (action) in
                }
            )
        )
        
        /* present */
        self.present(confirmDialog, animated: true, completion: nil)
    }
    func goToAppSettings() {
        
        /* confirm */
        let confirmDialog = makeConfirmDialog(title: i18NString("NoteDetailsViewController.photo.authConfirmDialogTitle"), message: i18NString("NoteDetailsViewController.photo.authConfirmDialogMsg"), okAction: (
                title:      i18NString("NoteDetailsViewController.photo.gotoAppSettingsBtn"),
                style:      .default,
                handler:    { (action) in
                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
                }
            ), cancelAction: (
                title:      i18NString("es.atenet.app.Cancel"),
                style:      .default,
                handler:    { (action) in
                }
            )
        )
        
        /* present */
        self.present(confirmDialog, animated: true, completion: nil)
    }
}

// Image Picker Delegate
extension NoteDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Did Finish Picking Image:
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        /* check */
        guard let jpeg = UIImageJPEGRepresentation(image, 1.0) else {
            
            /* dismiss */
            picker.dismiss(animated: true, completion: nil)
            
            // Try again, lowering image quality
            guard let jpeg2 = UIImageJPEGRepresentation(image, 0.5) else {
                showAlertDialog(sender: self, title: i18NString("NoteDetailsViewController.photo.jpegErrorTitle"), message: i18NString("NoteDetailsViewController.photo.jpegErrorMsg"))
                return
            }
            
            /* add */
            addImage(image, data: NSData(data: jpeg2))
            
            /* done */
            return
        }
        
        /* add */
        addImage(image, data: NSData(data: jpeg))
        
        /* */
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Add Image
    func addImage(_ uiImage: UIImage, data imageData: NSData) {
        let topRatio    = CGFloat(0.25)
        var leftRatio   = CGFloat(0.25)
        var heightRatio = CGFloat(0.5) // Okay for HEIGHT > WIDTH
        let rotation    = CGFloat(0.0)
        
        /* check */
        if (uiImage.size.width > uiImage.size.height) {
            let size        = uiImage.size
            let aspectRatio = size.height / size.width
            let widthRatio  = CGFloat(0.75)
            
            /* set */
            leftRatio   = CGFloat(0.125)
            heightRatio = self.view!.frame.width * (widthRatio * aspectRatio) / self.view!.frame.height
        }
        
        /* Add CoreData Image */
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.075, execute: {
            guard let cdImage = Image.create(for: self.note!, data: imageData, topRatio: topRatio, leftRatio: leftRatio, heightRatio: heightRatio, rotation: rotation, commit: true) else {
                showAlertDialog(sender: self, title: i18NString("NoteDetailsViewController.photo.jpegErrorTitle"), message: i18NString("NoteDetailsViewController.photo.jpegErrorMsg"))
                return
            }
            
            /* ImageView Controller */
            let imageVC = ImageViewController(model: cdImage, image: uiImage)
            imageVC.delegate = self
            imageVC.show(in: self.view!)
            
            /* add */
            self.imageViewControllers.append(imageVC)
            
            /* set */
            self.note!.updatedTimestamp = Date().timeIntervalSince1970
        })
    }
}

// MARK: - ImageViewControllerDelegate
extension NoteDetailViewController: ImageViewControllerDelegate {
    
    // Gesture
    func imageViewController(_ vc: ImageViewController, willHandleGesture imageView: UIImageView, model: Image) {
        self.closeKeyboard()
    }
    
    // Foreground
    func imageViewController(_ vc: ImageViewController, didBringForeground imageView: UIImageView, model: Image) {
        self.note!.bringImageForegound(model)
    }
    
    // Select
    func imageViewController(_ vc: ImageViewController, didSelect imageView: UIImageView, model: Image) {
        
        /* confirm */
        let actionSheetMenu = makeActionSheetMenu(from: self.view!, title: nil, message: nil, items:
            (
                title:      i18NString(i18NString("NoteDetailsViewController.photo.deletePhoto")),
                style:      .destructive,
                image:      nil,
                hidden:     false,
                handler:    { (action) in DispatchQueue.main.async {
                    vc.hide(); vc.model.delete(commit: true)
                    self.imageViewControllers.remove(at: self.imageViewControllers.index(of: vc)!)
                }}
            ),
            (
                title:      i18NString("es.atenet.app.Cancel"),
                style:      .cancel,
                image:      nil,
                hidden:     false,
                handler:    { (action) in DispatchQueue.main.async {
                    vc.setSelected(false)
                }}
            )
        )
        
        /* present */
        self.present(actionSheetMenu, animated: true, completion: nil)
    }
}
