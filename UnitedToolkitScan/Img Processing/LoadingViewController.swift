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
//        let checkInCheckOutView = UIStoryboard(name: "CheckInCheckOut", bundle: Bundle.main)
//        guard let controller = checkInCheckOutView.instantiateViewController(withIdentifier: "CheckInCheckOutStoryboard") as? CheckInCheckOutViewController else{
//            print("cannot find view controller")
//            return
//        }
//
        //Pop to checkInCheckOutViewController
        self.navigationController!.popToViewController(navigationController!.viewControllers[1], animated: true)
    }
    
    @IBOutlet weak var imgFromServ: UIImageView!
    var imgData : Data!
    var img: UIImage!
    var expected_tool_count : Int!
    var result_id: Int!
    var tool_count: Int!
    var toolkit_name: String!
    var toolkit_barcode: String!
    var check_type: String!
    @IBOutlet weak var toolkitNameLabel: UILabel!
    @IBOutlet weak var detectedToolsLabel: UILabel!
    @IBOutlet weak var expectedToolsLabel: UILabel!
    @IBOutlet weak var barcodeLabel: UILabel!

    
    
    @IBAction func retakeToolkitButton(_ sender: UIButton) {
        let toolkitCaptureView = UIStoryboard(name: "ToolkitCapture", bundle: Bundle.main)
        guard let controller = toolkitCaptureView.instantiateViewController(withIdentifier: "CaptureToolkitStoryboard") as? CameraCaptureController else{
            print("cannot find view controller")
            return
        }
        controller.barcodeFromServ = toolkit_barcode
        controller.check_type = check_type
        self.navigationController!.popToViewController(controller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.isNavigationBarHidden = false;
        self.navigationItem.title = "Result ID: \(result_id!)";
        img = UIImage(data: imgData)!
        imgFromServ.image = img
        
        toolkitNameLabel.text = "Toolkit Name: \(toolkit_name!)"
        detectedToolsLabel.text = "Tools Detected: \(tool_count!)"
        expectedToolsLabel.text = "Tools Expected: \(expected_tool_count!)"
        barcodeLabel.text = "Barcode: \(toolkit_barcode!)"
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is CameraCaptureController
        {
            let loadView = segue.destination as? CameraCaptureController
            loadView?.barcodeFromServ = self.toolkit_barcode
            loadView?.check_type = self.check_type
        }
        
    }
}
