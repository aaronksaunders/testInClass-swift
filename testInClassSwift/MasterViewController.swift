//
//  MasterViewController.swift
//  testInClassSwift
//
//  Created by Aaron saunders on 3/14/15.
//  Copyright (c) 2015 Clearly Innovative Inc. All rights reserved.
//

import UIKit
import Alamofire
import Haneke
import MapKit
import MobileCoreServices


class MasterViewController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var ACS_API_KEY = "HzglgNio7nxobLpXOi9tLmUg1MSF2hN2"
    var ACS_BASE_URL = "https://api.cloud.appcelerator.com/v1/"
    var SESSION_ID = ""
    
    struct PhotoInfo {
        var _id:String
        var location: String
        var filename:String
        var thumbURL:String
        var originalURL:String
        var coordinates : CLLocationCoordinate2D?
    }
    
    // Array of Photo Objects
    var objects = [PhotoInfo]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        // login the user
        loginUser()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func simpleAlert(_message:String?) {
        var alert = UIAlertController(title: "Error Message", message: _message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func loginUser() {
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = .Indeterminate
        loadingNotification.labelText = "Loading"
        
        Alamofire.request(.POST, ACS_BASE_URL+"users/login.json?key="+ACS_API_KEY,
            parameters: [
                "login" : "myadminuser",
                "password" : "password123"
            ]).response { (request, response, JSONResponse, error) in
                
                
                var json = JSON(data:JSONResponse as NSData)
                
                
                if let e:NSError = error {
                    self.simpleAlert(e.localizedDescription)
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                } else if ( json["response"] ) {
                    var user = (json["response"]["users"])[0];
                    
                    
                    self.SESSION_ID = json["meta"]["session_id"].stringValue!
                    println(self.SESSION_ID)
                    
                    // Successful login, now get the photos - Queue API calls
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        self.getPhotos({ (_photos:[PhotoInfo], _error:String?) -> Void in
                            println(_photos)
                            
                            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                            
                            if (_photos.count != 0 ) {
                                self.objects = _photos
                                
                                // got photos, reload the table
                                // UIKit operations must be done on the main queue.
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.tableView!.reloadData()
                                }
                            }
                            if ( _error != nil) {
                                self.simpleAlert(_error as String!)
                            }
                            
                        })
                    }
                } else {
                    var errorMessage:String = json["meta"]["message"].stringValue!
                    self.simpleAlert(errorMessage)
                }
        }
    }
    
    func getPhotos(_callback : ([PhotoInfo], String?) ->Void) {
        Alamofire.request(.GET, ACS_BASE_URL+"photos/search.json?key="+ACS_API_KEY,
            parameters: [
                "page" : 1,
                "per_page" : 100
            ]).response {
                (request, response, JSONResponse, error) in
                
                //var response = JSON!.valueForKey("response") as? NSDictionary
                var photoInfos = [PhotoInfo]()
                
                var json = JSON(data:JSONResponse as NSData)
                
                if ( json["response"] ) {
                    
                    
                    if let items = json["response"]["photos"].arrayValue {
                        for item in items {
                            
                            if let idValue = item["id"].stringValue {
                                
                                
                                var location = item["custom_fields"]["location_string"].stringValue
                                var coordinates:CLLocationCoordinate2D?
                                
                                if  (location == nil) {
                                    location = "Missing Location"
                                } else {
                                    var lat = item["custom_fields"]["coordinates"].arrayValue?[0][1].doubleValue
                                    var lng = item["custom_fields"]["coordinates"].arrayValue?[0][0].doubleValue
                                    coordinates = CLLocationCoordinate2DMake(lat!, lng!)
                                }
                                
                                var filename = item["filename"].stringValue
                                var thumbURL =  item["urls"]["small_240"].stringValue ?? item["urls"]["preview"].stringValue
                                var originalURL =  item["urls"]["original"].stringValue
                                
                                println(thumbURL)
                                
                                photoInfos.append(PhotoInfo(_id:idValue, location : location!, filename : filename!, thumbURL : thumbURL!, originalURL : originalURL!,coordinates:coordinates))
                            }
                        }
                    }
                    
                    _callback(photoInfos,nil)
                } else {
                    var errorMessage:String = json["meta"]["message"].stringValue!
                    _callback([],errorMessage)
                }
                
                
        }
    }
    // MARK: - Camera
    func cameraSupportsMedia(mediaType: String, sourceType: UIImagePickerControllerSourceType) -> Bool{
        
        let availableMediaTypes = UIImagePickerController.availableMediaTypesForSourceType(sourceType) as [String]?
        
        if let types = availableMediaTypes{
            for type in types{
                if type == mediaType{
                    return true
                }
            }
        }
        
        return false
    }
    
    func doesCameraSupportShootingVideos() -> Bool{
        return cameraSupportsMedia(kUTTypeMovie as NSString, sourceType: .Camera)
    }
    
    func doesCameraSupportTakingPhotos() -> Bool{
        return cameraSupportsMedia(kUTTypeImage as NSString, sourceType: .Camera)
        //return true
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
            
            println("Picker returned successfully")
            
            let mediaType:AnyObject? = info[UIImagePickerControllerMediaType]
            
            if let type:AnyObject = mediaType{
                
                if type is String{
                    let stringType = type as String
                    
                    if stringType == kUTTypeMovie as String{
                        let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL
                        if let url = urlOfVideo{
                            println("Video URL = \(url)")
                        }
                    }
                        
                    else if stringType == kUTTypeImage as String{
                        /* Let's get the metadata. This is only for images. Not videos */
                        let metadata = info[UIImagePickerControllerMediaMetadata]
                            as? NSDictionary
                        if let theMetaData = metadata{
                            let image = info[UIImagePickerControllerOriginalImage]
                                as? UIImage
                            
                            uploadImage(image!);
                            
                            if let theImage = image{
                                println("Image Metadata = \(theMetaData)")
                                println("Image = \(theImage)")
                            }
                        }
                    }
                    
                }
            }
            
            picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //
    //
    //
    func uploadImage(image:UIImage ) {
        // set some basic params for photo creation
        var parameters = [
            "photo_sizes[preview]": "100x100#"
        ]
        
        // we are compressing the image abit to increase upload efficienst
        let imageData = UIImageJPEGRepresentation(image,50.0)
        let urlRequest = urlRequestWithComponents(ACS_BASE_URL+"photos/create.json?key="+ACS_API_KEY+"&_session_id=" + SESSION_ID, parameters: parameters, imageData: imageData)
        //let urlRequest = urlRequestWithComponents(ACS_BASE_URL+"photos/create.json", parameters: parameters, imageData: imageData)
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = .Determinate
        loadingNotification.labelText = "Uploading Image"
        
        Alamofire.upload(urlRequest.0, urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                println("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
                let p = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
                loadingNotification.progress = p
            }
            .responseJSON { (request, response, JSON, error) in
                println("REQUEST \(request)")
                println("RESPONSE \(response)")
                println("JSON \(JSON)")
                println("ERROR \(error)")
                
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }
    }
    
    //
    // this function creates the required URLRequestConvertible and NSData we need to use Alamofire.upload
    //
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        
        
        let boundaryConstant = "acs-post-boundary-\(arc4random())-\(arc4random())"
        let contentType = "multipart/form-data; boundary="+boundaryConstant
        
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"photo\"; filename=\"file\(arc4random()).png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add additional post parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        
        // return URLRequestConvertible and NSData
        var urlParams:[String: String] = Dictionary()
        urlParams.updateValue(ACS_API_KEY, forKey: "key")
        urlParams.updateValue(SESSION_ID, forKey: "_session_id")
    
        
        // cannot figure out how to set params on URL, so will hard code for now @TODO
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
    //
    //
    //
    func insertNewObject(sender: AnyObject) {
        
        var imagePickerCtrl: UIImagePickerController?
        
        //objects.insertObject(NSDate(), atIndex: 0)
        //let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        //self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        
        if  doesCameraSupportTakingPhotos(){
            
            imagePickerCtrl = UIImagePickerController()
            
            if let theController = imagePickerCtrl {
                theController.sourceType = .Camera
                
                theController.mediaTypes = [kUTTypeImage as NSString]
                
                theController.allowsEditing = true
                theController.delegate = self
                
                presentViewController(theController, animated: true, completion: nil)
            }
            
        } else {
            simpleAlert("Camera is not available")
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        println("Picker was cancelled")
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func isCameraAvailable() -> Bool{
        return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = objects[indexPath.row] as PhotoInfo
                (segue.destinationViewController as DetailViewController).detailItem = object
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> PhotoTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CCell", forIndexPath: indexPath) as PhotoTableViewCell
        
        let object = objects[indexPath.row] as PhotoInfo
        cell.mainTitle!.text = object.filename
        cell.subTitle!.text = object.location
        
        let URL = NSURL(string:object.thumbURL)!
        
        
        
        let cache = Shared.imageCache
        let fetcher = NetworkFetcher<UIImage>(URL: URL)
        cache.fetch(fetcher: fetcher).onSuccess { image in
            // Do something with image
            
            cell.thumbView?.bounds = CGRectMake(8,2, 74, 74)
            cell.thumbView?.clipsToBounds = true
            cell.thumbView?.contentMode = .ScaleAspectFit
            cell.thumbView?.image = image
            print()
        }
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //objects.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
}

