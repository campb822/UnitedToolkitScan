//
//  PreviewCameraViewController.swift
//  UnitedToolkitScan
//
//  Created by Scott Campbell on 10/10/18.
//  Copyright © 2018 Team United Airlines. All rights reserved.
//

import UIKit

class PreviewCameraViewController: UIViewController {

    var img: UIImage!
    @IBOutlet weak var photo: UIImageView!
    @IBAction func retakePhoto(_ sender: Any) {
        dismiss(animated:true, completion:nil)
    }
    @IBAction func submitPhoto(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.img

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
