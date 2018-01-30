//
//  MainVC.swift
//  Connect With Matlab
//
//  Created by osama on 27/01/2018.
//  Copyright © 2018 osama. All rights reserved.
//

import UIKit
import Firebase

class MainVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageShowingView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var realOrFakeImage: UIImageView!
    
    let OUTPUT_REFERENCE = "output"
    
    var imagePicker: UIImagePickerController!
    var currentFileName: String!
    
    var first: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let database = Database.database()
        let databaseRef = database.reference().child(OUTPUT_REFERENCE)
        
        UIView.animate(withDuration: 1.5, animations: {
            self.realOrFakeImage.alpha = 1.0
        })
        
        databaseRef.observe(DataEventType.value, with: {
            (snapshot) in
            
                let output = snapshot.childSnapshot(forPath: "processing_output").value as? String
            
                if let output = output{
                    if output != "" && self.first != 0 {
                        let alertController = UIAlertController(title: "The product is ", message: "\(output)", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                        
                        alertController.addAction(action)
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                        print("Output received: \(output)")
                    }
                }
            
            self.first = 1
            
            })
    }

    @IBAction func btnCapturePicPressed(_ sender: AnyObject) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        imagePicker.cameraCaptureMode = .photo
        imagePicker.modalPresentationStyle = .fullScreen
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func btnPickPicturePressed(_ sender: AnyObject) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnUploadPressed(_ sender: AnyObject) {
        let spinner = UIViewController.displaySpinner(onView: self.view)
        
        // Get a reference to the storage service using the default Firebase App
        let database = Database.database()
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        let databaseRef = database.reference()
        
        var data = NSData()
        data = UIImageJPEGRepresentation(imageView.image!, 0.8)! as NSData
        
        // set upload path
        
        print("File Path: \(currentFileName)")
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.child("matlab_image.jpeg").putData(data as Data, metadata: metaData) { (metaData, error) in
            
            if error != nil {
                debugPrint(error as Any)
            }else{
                let downloadURL = metaData!.downloadURL()!.absoluteString
                
                print("Download URL: \(downloadURL)")
                
                let alertController = UIAlertController(title: "Sent", message: "The picture has been sent", preferredStyle: UIAlertControllerStyle.actionSheet)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                alertController.addAction(action)
                
                self.present(alertController, animated: true, completion: nil)
                
                databaseRef.updateChildValues(["fileURL": downloadURL])
            }
          
            UIViewController.removeSpinner(spinner: spinner)
            
            self.imageShowingView.isHidden = true
        }
    }
    
    
    @IBAction func btnBackPressed(_ sender: AnyObject) {
        imageShowingView.isHidden = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        //imageView.image = info["UIImagePickerControllerOriginalImage"] as? UIImage
        
        imageView.image = info["UIImagePickerControllerEditedImage"] as? UIImage
        
        /*let imageUrl = info[UIImagePickerControllerReferenceURL] as! NSURL
        // here you got file path that you select from camera roll
        
        let imageFileName = String(describing: imageUrl)
        currentFileName = imageFileName.components(separatedBy: "?")[1]
        
        print("File name: \(currentFileName!)")*/
        
        imageShowingView.isHidden = false
    }
}

