# United Toolkit Content Verification System
## Introduction
The United Toolkit Content Verification System iOS application allows United technicians to check in and check out toolkits by scanning associated barcodes and capturing an image of the toolkit. This image is sent for OpenCV Template Matching processing and the result is returned to the user. The technician then uses that information to make an informed decision on the status of the toolkit. The Toolkit Content Verification application is written in Swift 4.2, and is designed for iOS 12+. It uses Alamofire https://github.com/Alamofire/Alamofire to handle RESTful requests and KeychainAccess https://github.com/kishikawakatsumi/KeychainAccess to retain authentication tokens throughout a user's session.

## Installation
  Clone this repo to your local machine.
  
  Install cocoapods using 
```sudo gem install cocoapods``` in terminal or download the Mac App here: https://github.com/CocoaPods/CocoaPods-app/releases/download/1.5.2/CocoaPods.app-1.5.2.tar.bz2/
  
  Locate the pod file within the project, and install pods. Without these, you will not be able to build the project.
  
  Once these pods are installed, you should be able to open the new project and build.
 
## Application Information
### Login
#### UserLoginController
User login is handled using a session manager within the Alamofire pod. A user must have been created within the admin portal for login to be possible. Session manager is located under Support Files -> AlamofireSessionManager
#### CheckInCheckOut
Check In and Check Out sets a flag for whether a user is checking in or checking out a toolkit. This flag is eventually passed to the database when image capture is sent. Alamofire handles the network request using the session manager. User is able to logout of the application in this view controller which sends the auth token to the server and releases the session.

### Barcode Scan
#### BarcodeController
Barcode controller uses the device camera to scan for United toolkit barcodes. When detected, it prompts the user to confirm that code. Then, the encoded barcode data is sent to the server to confirm its existence in the database. If it is unable to confirm, the user is alerted with the opportunity to input the barcode manually or try again. If the barcode is found within the database, the application moves forward to camera capture.
#### ManualEntryViewController
If a barcode is damaged or user is having problems caputuring the barcode, they may input the code manually here.

### Toolkit Capture
#### CameraCaptureController
When barcode is successfully found in database, they will capture the toolkit from this view controller. After capture, PreviewCameraViewController is pushed to stack for user to confirm the image is taken correctly.
#### PreviewCameraViewController
Once user captures toolkit, they confirm image for processing. This image is sent to the server which applies OpenCV Template Matching to determine which tools are present in the toolkit and if any are missing. Once that processing occurs and receives a response with the result id encoded, that id is passed back to the server to obtain the image data, the expected tool count, the toolkit barcode, and the toolkit name.

### Img Processing
#### ImgProcessingLoadingViewController
Loading screen after user has hit "submit" within app.
#### LoadingViewController
This view controller is the screen the user sees after they have sent their image off to the server for processing and have received a response from the server. It will have the image data, the expected tool count, the toolkit barcode, and the toolkit name displayed along with the option to retake the toolkit if there is an error with the processing or to capture a new toolkit. This will pop from the view controller stack back to the check in/check out vc. In addition, the user may choose to view an example image to ensure they have captured the toolkit correctly.

### Support Files
#### AlamofireSessionManager
This is called for each network request to handle SSL certification. The timeout interval is set for 20 seconds.
#### AppDelegate
Under AppDelegate, the network activity indicator is turned on within Alamofire to allow for the built-in iOS activity wheel to function.
#### ViewController
ViewController has an extension to UIButton to allow for rounded edges on buttons.
