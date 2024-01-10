//
//  File.swift
//  
//
//  Created by Vladislav Soroka on 10.01.2024.
//

import Foundation
import UIKit

extension UIApplication {

    var openURL: CommandWith<URL> {
        CommandWith { url in
            self.open(url, options: [:], completionHandler: nil)
        }
    }
    
}
