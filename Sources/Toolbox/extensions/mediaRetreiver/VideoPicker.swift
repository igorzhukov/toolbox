//
//  VideoPicker.swift
//  
//
//  Created by Vladislav Soroka on 07.01.2023.
//

import UIKit
import AVFoundation

public struct LocalVideo {
    
    public let url: URL
    public let aspectRatio: CGFloat
    public let duration: TimeInterval
    
}

public class VideoPicker {

    private var completion: CommandWith<LocalVideo> = .nop
    
    public static func present(on viewController: UIViewController,
                               completion: CommandWith<LocalVideo>) {

        VideoSharedPicker.shared.pick(controller: viewController) { (video) in
            
            DispatchQueue.main.async {
                completion(with: video)
            }
            
        }

    }
    
}

public class VideoSharedPicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public static var shared = VideoSharedPicker()
    
    var successBlock: ((LocalVideo) -> ())!
    
    public func pick(
              controller: UIViewController,
              successBlock success: @escaping ((LocalVideo) -> ()))
    {
        
        let x = UIImagePickerController()
        x.sourceType = .photoLibrary
        x.delegate = self
        x.mediaTypes = ["public.movie"]
        x.videoQuality = .typeHigh
        
        self.successBlock = success
        
        controller.present(x, animated: true, completion: nil)
        
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let videoURL = info[.mediaURL] as? URL,
              let track = AVURLAsset(url: videoURL).tracks(withMediaType: AVMediaType.video).first else {
            return
        }
        
        let size = track.naturalSize.applying(track.preferredTransform)
        let aspectRaio: CGFloat = size.width / size.height

        let duration = AVURLAsset(url: videoURL).duration.seconds
        
        successBlock( .init(url: videoURL, aspectRatio: aspectRaio, duration: duration) )
    }
    
}
