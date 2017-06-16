//
//  ViewController.swift
//  Example
//
//  Created by 解 磊 on 2017/6/15.
//  Copyright © 2017年 AppLeg Corp. All rights reserved.
//

import UIKit
import RingLabel

class ViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var ringLabel: RingLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tableViewController = segue.destination as? TableViewController {
            tableViewController.ringLabel = self.ringLabel
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if size.width > size.height {
            self.stackView.axis = .horizontal
        } else {
            self.stackView.axis = .vertical
        }
    }
}

class TableViewController: UITableViewController {
    @IBOutlet weak var textSizeSlider: UISlider!
    @IBOutlet weak var minScaleSlider: UISlider!
    @IBOutlet weak var positionSlider: UISlider!
    @IBOutlet weak var marginSlider: UISlider!
    @IBOutlet weak var spaceSlider: UISlider!
    @IBOutlet weak var directionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var alignmentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var breakModeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var arrangementSegmentedControl: UISegmentedControl!
    
    weak var ringLabel: RingLabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func actionFromSlider(_ sender: UISlider) {
        switch sender {
        case self.textSizeSlider:
            self.ringLabel?.textHeightFactor = CGFloat(sender.value)
        case self.minScaleSlider:
            self.ringLabel?.minimumScaleFactor = CGFloat(sender.value)
        case self.positionSlider:
            self.ringLabel?.positionFactor = CGFloat(sender.value)
        case self.marginSlider:
            self.ringLabel?.marginFactor = CGFloat(sender.value)
        case self.spaceSlider:
            self.ringLabel?.spaceFactor = CGFloat(sender.value)
        default: break
        }
        
        self.ringLabel?.updateLayout()
    }
    
    @IBAction func actionFromSegmentedControl(_ sender: UISegmentedControl) {
        switch (sender, sender.selectedSegmentIndex) {
        case (self.directionSegmentedControl, let value):
            self.ringLabel?.clockwise = value == 0
        case (self.alignmentSegmentedControl, 0):
            self.ringLabel?.textAlignment = .left
        case (self.alignmentSegmentedControl, 1):
            self.ringLabel?.textAlignment = .center
        case (self.alignmentSegmentedControl, 2):
            self.ringLabel?.textAlignment = .right
        case (self.breakModeSegmentedControl, 0):
            self.ringLabel?.lineBreakMode = .byTruncatingHead
        case (self.breakModeSegmentedControl, 1):
            self.ringLabel?.lineBreakMode = .byTruncatingMiddle
        case (self.breakModeSegmentedControl, 2):
            self.ringLabel?.lineBreakMode = .byTruncatingTail
        case (self.breakModeSegmentedControl, 3):
            self.ringLabel?.lineBreakMode = .byClipping
        case (self.arrangementSegmentedControl, 0):
            self.ringLabel?.lineMode = false
        case (self.arrangementSegmentedControl, 1):
            self.ringLabel?.lineMode = true
        default: break
        }
        self.ringLabel?.updateLayout()
    }
    
    @IBAction func actionFromStepper(_ sender: UIStepper) {
        var positionValue = self.positionSlider.value
        if sender.value == 0 {
            positionValue = ((positionValue / 0.25).rounded(.up) - 1) * 0.25
        } else {
            positionValue = ((positionValue / 0.25).rounded(.down) + 1) * 0.25
        }
        positionValue = (positionValue + 1).truncatingRemainder(dividingBy: 1)
        self.positionSlider.value = positionValue
        self.actionFromSlider(self.positionSlider)
        sender.value = 1
    }
}

