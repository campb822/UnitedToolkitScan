//
//  BarcodeController.swift
//  UnitedToolkitScan
//
//  Created by Team United Airlines on 10/1/18.
//  Copyright © 2018 Team United Airlines. All rights reserved.
//

import UIKit
import AVFoundation
import KeychainAccess

class BarcodeScanner: UIViewController {
    

    @IBOutlet weak var manEntry: UIButton!
    @IBOutlet weak var manEntryView: UIView!
    

    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var barCodeFrameView: UIView?
    
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
    
    func BarcodeDetected(decodedBarcode: String) {
        let barcode = decodedBarcode
        if presentedViewController != nil {
            return
        }
        
        let alertPrompt = UIAlertController(title: "Barcode Detected", message: "Kit ID:  \(decodedBarcode)", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: { (action) -> Void in
            
            // This is where we would send the captured barcode to the server
            let barcodeStatus = self.SendBarcodeToServer(decodedBarcode: barcode)
            
            //if barcodeStatus is false... (will be changed)
            if barcodeStatus == true{
                print("found barcode")
            }
            if decodedBarcode == "ABC-abc-1234" {
                let alert = UIAlertController(title: "ERROR", message: "Toolkit not found in database. Try again.", preferredStyle: .actionSheet)
                let manEntryOption = UIAlertAction(title: "Manual Entry", style:UIAlertAction.Style.default, handler:{(action) -> Void in
                    self.manEntry.sendActions(for: .touchUpInside)
                })
                let cancel = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler:nil)
                alert.addAction(manEntryOption)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
            
            let storyboard = UIStoryboard(name: "ToolkitCapture", bundle: Bundle.main)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "CaptureToolkitStoryboard") as? CameraCaptureController else{
                print("cannot find view controller")
                return
            }
            self.navigationController!.pushViewController(controller, animated: true)

        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        present(alertPrompt, animated: true, completion: nil)
    }
    
    
    func SendBarcodeToServer(decodedBarcode: String) -> Bool{
        let keychain = Keychain(service: "com.UnitedAirlinesCapstone.UnitedToolkitScan")
        let token = try? keychain.get("auth_token")
        print(token!!)
        
        return true
    }
}

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
