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

    @IBAction func ScanNewToolkitButton(_ sender: UIButton) {
        //let viewController = CheckInCheckOutViewController()
        //navigationController?.popToViewController(viewController, animated: true)
        //navigationController?.popToRootViewController(animated: true)
        navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var imgFromServ: UIImageView!
    var imgData : Data!
    var img: UIImage!
    
    //@IBOutlet weak var imageFromServer: UIImageView!
    //var img : UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.isNavigationBarHidden = false;
        img = UIImage(data: imgData)!
        imgFromServ.image = img
    }
}
