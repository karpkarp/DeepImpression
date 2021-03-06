//
//  ViewController.swift
//  FaceDetection
//
//  Created by Vishal on 25/09/16.
//  Copyright © 2016 vishalvirodhia. All rights reserved.
//

import UIKit
import CoreImage


class ViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var pickedImge: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openGalleryAction(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    //MARK: Image picker delegate
    func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismiss(animated: true, completion: { () -> Void in })
        pickedImge.image = image
        
        checkImage(image: image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: { () -> Void in })
    }
    

    func  checkImage(image:UIImage) {
        
        guard let detectedImage = CIImage(image: image) else {
            return
        }
        
        let detectionAccuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: detectionAccuracy)
        let foundFaces = faceDetector?.features(in: detectedImage, options: [CIDetectorImageOrientation: 5])
        
        
        // For converting the Core Image Coordinates to UIView Coordinates
        let detectedImageSize = detectedImage.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -detectedImageSize.height)
        
        print(foundFaces)
        for face in foundFaces as! [CIFaceFeature] {
            
            print("Found bounds are \(face.bounds)")
            

            var newBounds = face.bounds.applying(transform)
            
            // Calculate the actual position of indicator
            let viewSize = pickedImge.bounds.size
            let scale = min(viewSize.width / detectedImageSize.width,
                            viewSize.height / detectedImageSize.height)
            let offsetX = (viewSize.width - detectedImageSize.width * scale) / 2
            let offsetY = (viewSize.height - detectedImageSize.height * scale) / 2
            
            newBounds = newBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            newBounds.origin.x += offsetX
            newBounds.origin.y += offsetY

            let indicator = UIView(frame: newBounds)
            indicator.backgroundColor = UIColor.clear
            indicator.layer.borderWidth = 2
            indicator.layer.borderColor = UIColor.red.cgColor
            pickedImge.addSubview(indicator)
            
            
            let cgImage = image.cgImage
//            let rect = CGRect(x: face.bounds.minX, y: face.bounds.maxY, width: face.bounds.width, height: face.bounds.height)
            let croppedCGImage: CGImage = cgImage!.cropping(to: face.bounds)!
            
            let uiImage = UIImage(cgImage: croppedCGImage)
//
//        
            pickedImge.image = uiImage;
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

        }
    }
    
    func cropBottomImage(image: UIImage) -> UIImage {
        let height = CGFloat(image.size.height / 3)
        let rect = CGRect(x: 0, y: image.size.height - height, width: image.size.width, height: height)
        return cropImage(image: image, toRect: rect)
    }
    
    func cropImage(image:UIImage, toRect rect:CGRect) -> UIImage{
        let imageRef:CGImage = image.cgImage!.cropping(to: rect)!
        let croppedImage:UIImage = UIImage(cgImage:imageRef)
        return croppedImage
    }
    
    
}

