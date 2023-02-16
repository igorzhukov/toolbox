//
//  File.swift
//
//
//  Created  on 7/27/19.
//  Copyright ©. All rights reserved.
//

import UIKit
import Kingfisher

public class ImagePicker {

    private var completion: CommandWith<UIImage> = .nop
    
    public static func present(on viewController: UIViewController,
                               processor: ImageProcessor? = nil,
                               allowsEditing: Bool = false,
                               completion: CommandWith<UIImage>) {

        PhotoPicker.shared.pick(allowsEditing: allowsEditing, pickerSourceType: .CameraAndPhotoLibrary, controller: viewController) { [weak container = viewController] (originalPhoto, editedPhoto) in
            
            let photo = editedPhoto ??  originalPhoto!
            
            if let p = processor {
                container?.view.indicateProgress = true
                DispatchQueue.global().async {
                    let res = p.process(item: .image(photo),
                                        options: .init(nil))!
                    let x = KingfisherWrapper(res).normalized
                    
                    DispatchQueue.main.async {
                        completion(with: x)
                        container?.view.indicateProgress = false
                    }
                }
                
            } else {
                completion(with: photo)
            }
            
        }

    }
    
}

public class PhotoPicker: NSObject {
    
    public static var shared = PhotoPicker()
    
    public enum PickerSourceType: Int {
        case Camera = 0,
        PhotoLibrary,
        CameraAndPhotoLibrary
    }
    

    var successBlock:((_ originalPhoto:UIImage?, _ editedPhoto: UIImage?) -> ())!
    
    public func pick(allowsEditing:Bool = false,
              pickerSourceType: PickerSourceType = .PhotoLibrary,
              controller: UIViewController,
              successBlock success: @escaping ((_ originalPhoto:UIImage?, _ editedPhoto: UIImage?) -> ()))
    {
        
        if pickerSourceType == .CameraAndPhotoLibrary {
            
            let alertController = UIAlertController(title: "Select", message: "Source Type", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                print("User pressed Cancel")
            }))
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                alertController.addAction(UIAlertAction(title: "Take photo", style: .default, handler: { action in
                    self.pick(allowsEditing: allowsEditing, pickerSourceType: .Camera, controller: controller, successBlock: success)
                }))
            }
            
            alertController.addAction(UIAlertAction(title: "Choose photo", style: .default, handler: { action in
                self.pick(allowsEditing: allowsEditing, pickerSourceType: .PhotoLibrary, controller: controller, successBlock: success)
            }))
            
            controller.present(alertController, animated: true, completion: nil)
            
            return
            
        }
        
        //Now show the Image Picker Controller
        
        var sourceType:UIImagePickerController.SourceType!
        
        switch pickerSourceType {
        case .Camera:
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                sourceType = .camera
            } else {
                sourceType = .savedPhotosAlbum
            }
            
        case .PhotoLibrary:
            sourceType = .photoLibrary
        default:
            sourceType = .savedPhotosAlbum
            
        }
        
        let picker = UIImagePickerController()
        
        picker.sourceType = sourceType
        picker.allowsEditing = allowsEditing
        picker.delegate = self
        
        self.successBlock = success
        
        controller.present(picker, animated: true, completion: nil)
        
    }
    
}

extension PhotoPicker: UINavigationControllerDelegate {

}

extension PhotoPicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let originalPhoto = info[.originalImage] as? UIImage
        let editedPhoto = info[.editedImage] as? UIImage
        
        successBlock(originalPhoto, editedPhoto)
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}
