//
//  LoadingViewController.swift
//  UnitedToolkitScan
//
//  Created by Team United Airlines on 10/18/18.
//  Copyright © 2018 Team United Airlines. All rights reserved.
//

import UIKit
import AVFoundation

class LoadingViewController: UIViewController {

    @IBOutlet weak var imgFromServ: UIImageView!
    var imgData : Data!
    var img: UIImage!
    
    //@IBOutlet weak var imageFromServer: UIImageView!
    //var img : UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        img = UIImage(data: imgData)!
        imgFromServ.image = img
    }
}
