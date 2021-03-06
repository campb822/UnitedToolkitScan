//
//  CameraCaptureController.swift
//  UnitedToolkitScan
//
//  Created by Team United Airlines on 10/1/18.
//  Copyright © 2018 Team United Airlines. All rights reserved.
//
//  View to allow user to capture toolkit. Pushes image to PreviewCameraViewController for submission to server for OpenCV processing

import AVFoundation
import UIKit

class CameraCaptureController: UIViewController{
    var barcodeFromServ: String!
    var backCam: AVCaptureDevice?
    var captureSession = AVCaptureSession()
    var capturedPhoto: AVCapturePhotoOutput?
    
    var cameraPrevLayer: AVCaptureVideoPreviewLayer?
    var img: UIImage?
    var check_type: String!


    //run fcns to get camera capture running
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false;
        setupCameraCaptureSession()
        setupDevice()
        setupIO()
        setupPreview()
        startCapture()
    }
    
    
    func setupCameraCaptureSession(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice(){
        let devDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let accepted_devices = devDiscoverySession.devices
        
        for device in accepted_devices{
            if device.position == AVCaptureDevice.Position.back{
                backCam = device
            }
        }
    }
    
    func setupIO(){
        do{
            let captureDevInput = try AVCaptureDeviceInput(device: backCam!)
            captureSession.addInput(captureDevInput)
            capturedPhoto = AVCapturePhotoOutput()
            capturedPhoto?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format:[AVVideoCodecKey:AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(capturedPhoto!)
        }
        catch{
            print(error)
        }
        
    }
    
    func setupPreview(){
        cameraPrevLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPrevLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPrevLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPrevLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPrevLayer!, at: 0 )
    }
    
    func startCapture(){
        captureSession.startRunning()
    }
    
    @IBAction func buttoncap(_ sender: Any) {
        let setting = AVCapturePhotoSettings()
        capturedPhoto?.capturePhoto(with: setting, delegate: self)
    }
    @IBAction func captureImage(_ sender: Any) {
        let setting = AVCapturePhotoSettings()
        capturedPhoto?.capturePhoto(with: setting, delegate: self)
        //performSegue(withIdentifier: "showPhotoSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "showPhotoSegue"{
            let prevViewController = segue.destination as! PreviewCameraViewController
            prevViewController.img = self.img
            prevViewController.check_type = self.check_type
            prevViewController.barcodeFromServ = self.barcodeFromServ
        }
    }
    
}

extension CameraCaptureController: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imgData = photo.fileDataRepresentation(){
            img = UIImage(data:imgData)
            performSegue(withIdentifier: "showPhotoSegue",sender:nil)
        }
    }
}
