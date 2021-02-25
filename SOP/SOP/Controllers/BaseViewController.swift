//
//  BaseViewController.swift
//  SOP
//
//  Created by Shivam Saini on 06/10/18.
//  Copyright © 2018 StarTrack. All rights reserved.
//

import UIKit

typealias Dictionary = [String:Any]

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    //MARK:- Supporting Functions
    
    func show(alertWithTitle title:String,message:String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok",
                                      style: .default,
                                      handler: nil))
        self.present(alert,
                     animated: true,
                     completion: nil)
    }
    
    enum indicatorSwitch {
        case start
        case stop
    }

}
