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
    var expected_tool_count : Int!
    var result_id: Int!
    var tool_count: Int!
    var toolkit_name: String!
    var toolkit_barcode: String!
    
    
    @IBOutlet weak var toolkitNameLabel: UILabel!
    @IBOutlet weak var detectedToolsLabel: UILabel!
    @IBOutlet weak var expectedToolsLabel: UILabel!
    @IBOutlet weak var barcodeLabel: UILabel!
    //@IBOutlet weak var imageFromServer: UIImageView!
    //var img : UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.isNavigationBarHidden = false;
        self.navigationItem.title = "Result ID: \(result_id!)";
        img = UIImage(data: imgData)!
        imgFromServ.image = img
        
        toolkitNameLabel.text = "Toolkit Name: \(toolkit_name!)"
        detectedToolsLabel.text = "Toolkit Detected: \(tool_count!)"
        expectedToolsLabel.text = "Toolkit Expected: \(expected_tool_count!)"
        barcodeLabel.text = "Barcode: \(toolkit_barcode!)"
        
    }
}
