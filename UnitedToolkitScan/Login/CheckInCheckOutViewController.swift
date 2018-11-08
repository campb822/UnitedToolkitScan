//
//  CheckInCheckOutViewController.swift
//  UnitedToolkitScan
//
//  Created by Team United Airlines on 10/15/18.
//  Copyright © 2018 Team United Airlines. All rights reserved.
//

import UIKit

class CheckInCheckOutViewController: UIViewController {

    var check_type: String!
    //check_type = "in" or "out"
    
    @IBAction func checkInButtonPush(_ sender: UIButton) {
        self.check_type = "in"
        loadNextStoryboard()
    }
    
    @IBAction func checkOutButtonPush(_ sender: UIButton) {
        self.check_type = "out"
        loadNextStoryboard()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    func loadNextStoryboard(){
        let storyboard = UIStoryboard(name: "BarcodeCapture", bundle: Bundle.main)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "BarcodeScanner") as? BarcodeScanner else{
            print("cannot find view controller")
            return
        }
        controller.check_type = self.check_type
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is BarcodeScanner
        {
            let loadView = segue.destination as? BarcodeScanner
            loadView?.check_type = self.check_type
        }
    }
}
