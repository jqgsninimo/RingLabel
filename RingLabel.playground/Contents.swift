//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
import RingLabel

let label = RingLabel()
label.text = "AB\tCD\nEF\rGHIJKLMNOPQRSTUVWXYZ"
label.backgroundColor = UIColor.red
label.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
PlaygroundPage.current.liveView = label
