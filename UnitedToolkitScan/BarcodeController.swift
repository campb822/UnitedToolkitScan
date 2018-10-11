//
//  BarcodeController.swift
//  UnitedToolkitScan
//
//  Created by Team United Airlines on 10/1/18.
//  Copyright © 2018 Team United Airlines. All rights reserved.
//

import UIKit
import AVFoundation

class BarcodeScanner: UIViewController {
    
    //@IBOutlet weak var messageLabel: UILabel!
    //@IBOutlet weak var topbar: UIView!
    @IBOutlet weak var manEntry: UIButton!
    @IBOutlet weak var manEntryView: UIView!
    //@IBOutlet weak var scanToolkitHeader: UILabel!
    
    var captureSession = AVCaptureSession()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var barCodeFrameView: UIView?
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
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
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
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
            //qrCodeFrameView.frame = barCodeObject.bounds;
            view.addSubview(barCodeFrameView)
            view.bringSubviewToFront(barCodeFrameView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods
    
    func launchApp(decodedBarcode: String) {
        
        if presentedViewController != nil {
            return
        }
        
        let alertPrompt = UIAlertController(title: "Barcode Detected", message: "Kit ID:  \(decodedBarcode)", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: { (action) -> Void in
            
            // This is where we would send the captured barcode to the server
            //if let barcode = URL(string: decodedBarcode) {
           //     if UIApplication.shared.canOpenURL(barcode) {
             //       UIApplication.shared.open(barcode, options: [:], completionHandler: nil)
             //   }
           // }
            
            let storyboard = UIStoryboard(name: "CaptureToolkit", bundle: Bundle.main)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "CameraCaptureController") as? CameraCaptureController else{
                print("cannot find view controller")
                return
            }
            self.navigationController!.pushViewController(controller, animated: true)
            //self.present(controller, animated: true, completion: nil)
            
            //let viewController:UIViewController = UIStoryboard(name: "ToolkitCapture.storyboard", bundle: nil).instantiateViewController(withIdentifier: "CameraCaptureController") as UIViewController
            // .instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
            
            //self.present(viewController, animated: false, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        present(alertPrompt, animated: true, completion: nil)
    }
    
}

extension BarcodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            barCodeFrameView?.frame = CGRect.zero
            //scanToolkitHeader.text = "Scan Toolkit Barcode"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            barCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                //scanToolkitHeader.text = metadataObj.stringValue
                launchApp(decodedBarcode: metadataObj.stringValue!)
                //messageLabel.text = metadataObj.stringValue
            }
        }
    }
    
}
