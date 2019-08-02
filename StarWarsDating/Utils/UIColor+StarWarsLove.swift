//
//  UIColor+StarWarsLove.swift
//  StarWarsDating
//
//  Created by Devin Pitcher on 8/2/19.
//  Copyright © 2019 FreshProduce LLC. All rights reserved.
//

import UIKit

extension UIColor {
    
    func asPixel() -> UIImage {
        let imgRenderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let img = imgRenderer.image { cxt in
            self.setFill()
            let bez = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 1, height: 1))
            bez.fill()
        }
        return img
    }
    
}

