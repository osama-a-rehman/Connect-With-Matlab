//
//  BorderedButton.swift
//  Swoosh
//
//  Created by Osama Mac on 11/8/17.
//  Copyright © 2017 Osama Mac. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedButton: UIButton {

    override func prepareForInterfaceBuilder() {
        addBorder()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addBorder()
    }
    
    func addBorder(){
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2.0
    }
}
