//
//  ManualEntryViewController.swift
//  UnitedToolkitScan
//
//  Created by Team United Airlines on 10/18/18.
//  Copyright © 2018 Team United Airlines. All rights reserved.
//

import UIKit

class ManualEntryViewController: UIViewController {

    @IBOutlet weak var manEntryField: UITextField!
    @IBAction func manEntryConfirm(_ sender: UIButton) {
        if (manEntryField.text == "") {
            let alert = UIAlertController(title: "ERROR", message: "Barcode Field Empty. Try Again.", preferredStyle: .actionSheet)
            let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
        else{
            confirmBarcodeInDatabase()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func confirmBarcodeInDatabase(){
        //send barcode to DB as PK
        
        //if in DB
            //push toolkit capture storyboard
        //else
            //alert to show that the barcode is not in the db
        
        if (manEntryField.text == "1234"){
            
        }
        else{
            let alert = UIAlertController(title: "ERROR", message: "Toolkit Barcode not found in database. Contact Administrator.", preferredStyle: .actionSheet)
            let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }


}
