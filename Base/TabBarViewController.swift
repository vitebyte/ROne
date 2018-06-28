//
//  TabBarViewController.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 22/03/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    //MARK: Variables
    var moreButton: UIBarButtonItem = UIBarButtonItem()

    //MARK : - View life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Status bar 
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
