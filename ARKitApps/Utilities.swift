//
//  Utilities.swift
//  RealText
//
//  Created by Mykyta Popov on 27/08/2023.
//

import UIKit

func randomColor() -> UIColor {
    let red = CGFloat.random(in: 0...1)
    let green = CGFloat.random(in: 0...1)
    let blue = CGFloat.random(in: 0...1)
    
    let randomColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    return randomColor
}
