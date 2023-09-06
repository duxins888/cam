//
//  NSImage+Extension.swift
//  CamServer
//
//  Created by Xin Du on 2023/09/06.
//

import Foundation
import AppKit

extension NSImage {
    static func fromDocuments(named imageName: String) -> NSImage? {
        let dir = URL.documentsDirectory.path()
        let imagePath = dir + imageName + ".jpg"
        return NSImage(contentsOfFile: imagePath)
    }
}
