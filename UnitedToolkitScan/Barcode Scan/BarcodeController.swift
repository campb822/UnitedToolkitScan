//
//  BarcodeController.swift
//  UnitedToolkitScan
//
//  Created by Team United Airlines on 10/1/18.
//  Copyright © 2018 Team United Airlines. All rights reserved.
//
//  Barcode scanner to capture associated code with toolkit. Sends to server for confirmation that toolkit exists in system
//  Will not allow user to continue if kit does not exist in admin portal.
//  Manual entry option will push a new vc for user to input and serve same functionality.

import UIKit
import AVFoundation
import KeychainAccess
import Alamofire

class BarcodeScanner: UIViewController {
    

    @IBOutlet weak var manEntry: UIButton!
    @IBOutlet weak var manEntryView: UIView!
    
    let sessionManager = loadSession()
    var barcodeFromServ: String!
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var barCodeFrameView: UIView?
    var check_type: String!
    //Decodable JSON for authentication token from Django server
    struct BarcodeJSONResponse: Decodable{
        let toolkit_name: String
        let toolkit_barcode: String
        let expected_tool_count: Int
    }
    
    //United Toolkit barcodes only use code128, so it is the only barcode type detected
    private let supportedCodeType = [AVMetadataObject.ObjectType.code128]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Use rear facing camera to capture barcode
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        //If camera is unavailable, do not load
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeType
            
        } catch {
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()

        view.bringSubviewToFront(manEntryView)

        barCodeFrameView = UIView()
        
        if let barCodeFrameView = barCodeFrameView {
            barCodeFrameView.layer.borderColor = UIColor.red.cgColor
            barCodeFrameView.layer.borderWidth = 10
            view.addSubview(barCodeFrameView)
            view.bringSubviewToFront(barCodeFrameView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Run when a barcode is detected. Prompts user to confirm they have scanned the desired barcode.
    func BarcodeDetected(decodedBarcode: String) {
        let barcode = decodedBarcode
        if presentedViewController != nil {
            return
        }
        
        if (decodedBarcode.count == 7){
            print(UI_USER_INTERFACE_IDIOM())
            let alertPrompt = UIAlertController(title: "Barcode Detected", message: "Kit ID:  \(decodedBarcode)", preferredStyle: .actionSheet)
            let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: { (action) -> Void in

                self.SendBarcodeToServer(decodedBarcode: barcode)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
            
            alertPrompt.addAction(confirmAction)
            alertPrompt.addAction(cancelAction)
            
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad )
            {
                if let currentPopoverpresentioncontroller = alertPrompt.popoverPresentationController{
                    currentPopoverpresentioncontroller.sourceView = self.view
                    currentPopoverpresentioncontroller.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    currentPopoverpresentioncontroller.permittedArrowDirections = []
                    self.present(alertPrompt, animated: true, completion: nil)
                }
            }else{
                present(alertPrompt, animated: true, completion: nil)
                //self.presentViewController(optionMenu, animated: true, completion: nil)
            }
            
        }
    }
    
    //Sends captured barcode to server encoded as "barcode_text" as the parameter. If not in DB, alert user and allow for manual entry or to try again.
    func SendBarcodeToServer(decodedBarcode: String){
        let keychain = Keychain(service: "com.UnitedAirlinesCapstone.UnitedToolkitScan")
        let token = try? keychain.get("auth_token")
        print(token!!)

        let parameters: Parameters = [
            "barcode_text": decodedBarcode
        ]
        
        let headers: HTTPHeaders = [
            "Authorization" : "Token " + token!!
        ]
        //Alamofire passes credentials to url to verify the existence of the barcode in the system
        let url = "https://35.9.22.103/image_verifier/api/barcode_validate/"
        _ = sessionManager.getManager().request(url, method:.post, parameters: parameters, encoding: URLEncoding(destination: .methodDependent), headers: headers).responseString { response in
            switch response.result {
            case .success:
                let jsonData = response.data
                print(response)
                let decoder = JSONDecoder()
                guard let decodedResponse = try? decoder.decode(BarcodeJSONResponse.self, from: jsonData!) else{
                    print("barcode not in DB")
                    let alert = UIAlertController(title: "ERROR", message: "Toolkit not found in database. Try again.", preferredStyle: .actionSheet)
                    let manEntryOption = UIAlertAction(title: "Manual Entry", style:UIAlertAction.Style.default, handler:{(action) -> Void in
                        
                        self.manEntry.sendActions(for: .touchUpInside)
                    })
                    let cancel = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler:nil)
                    alert.addAction(manEntryOption)
                    alert.addAction(cancel)
                    
                    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad )
                    {
                        if let currentPopoverpresentioncontroller = alert.popoverPresentationController{
                            currentPopoverpresentioncontroller.sourceView = self.view
                            currentPopoverpresentioncontroller.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                            currentPopoverpresentioncontroller.permittedArrowDirections = []
                            self.present(alert, animated: true, completion: nil)
                        }
                    }else{
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    return
                }
                print(decodedResponse.expected_tool_count)
                let storyboard = UIStoryboard(name: "ToolkitCapture", bundle: Bundle.main)
                guard let controller = storyboard.instantiateViewController(withIdentifier: "CaptureToolkitStoryboard") as? CameraCaptureController else{
                    print("cannot find view controller")
                    return
                }
                self.barcodeFromServ = decodedBarcode
                controller.barcodeFromServ = self.barcodeFromServ
                controller.check_type = self.check_type
                self.navigationController!.pushViewController(controller, animated: true)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //Allows data to be passed between controllers when a segue is performed (transition between storyboards)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is LoadingViewController
        {
            let loadView = segue.destination as? CameraCaptureController
            loadView?.barcodeFromServ = barcodeFromServ
            loadView?.check_type = check_type
        }
        
        if segue.destination is ManualEntryViewController
        {
            let loadView = segue.destination as? ManualEntryViewController
            loadView?.check_type = check_type
        }
    }
}

//Extends avcapturemetadataoutputobjectsdelegate to display bounds around barcode and runs barcodedetected() if encoded barcode is detected.
extension BarcodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not empty and it contains at least one object.
        if metadataObjects.count == 0 {
            barCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeType.contains(metadataObj.type) {
            
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            barCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                BarcodeDetected(decodedBarcode: metadataObj.stringValue!)
            }
        }
    }
    
}
