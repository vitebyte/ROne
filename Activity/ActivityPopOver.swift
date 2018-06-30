//
//  ActivityPopOver.swift
//  BenefitWellness
//
//  Created by Gaurav Garg on 10/03/17.
//  Copyright © 2017 Appster. All rights reserved.
//

import Foundation
class ActivityPopOver: UIViewController
{
    @IBOutlet weak var valueLabel: UILabel!
    var valueFitStr:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.valueLabel.text = self.valueFitStr
    }
    
}
