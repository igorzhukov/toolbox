//  SmartImageView.swift
//  Created  on 29.10.2022.

import UIKit
import RxSwift

public class SmartImageView: UIImageView {

    public struct Props {
        
        public enum Image {
            case url(String?)
            case value(UIImage)
        };
        public let image: Image
        public var placeholder: UIImage? = nil
        
        public init(image: SmartImageView.Props.Image, placeholder: UIImage? = nil) {
            self.image = image
            self.placeholder = placeholder
        }
        
        public static var initial: Props { .init(image: .url(nil)) }
        
    }; public var props: Props = .initial {
        didSet {
            render()
        }
    }
    
    func render() {
        
        image = props.placeholder
        
        switch props.image {
        case .value(let i):
            image = i
            
        case .url(let u):
            rx.download(url: u, placeholder: props.placeholder)
                .subscribe()
                .disposed(by: bag)
            
        }
        
    }
    
    var bag = DisposeBag()
    
    public func prepareForReuse() {
        bag = DisposeBag()
    }
    
}
