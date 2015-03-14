//
//  MasterViewController.swift
//  testInClassSwift
//
//  Created by Aaron saunders on 3/14/15.
//  Copyright (c) 2015 Clearly Innovative Inc. All rights reserved.
//

import UIKit
import Alamofire
//import SwiftyJSON

class MasterViewController: UITableViewController {
    
    var ACS_API_KEY = "HzglgNio7nxobLpXOi9tLmUg1MSF2hN2"
    var ACS_BASE_URL = "https://api.cloud.appcelerator.com/v1/"
    
    struct PhotoInfo {
        var _id:String
        var location: String
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
    
    func simpleAlert(_message:String) {
        var alert = UIAlertController(title: "Error Message", message: _message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func loginUser() {
        
        Alamofire.request(.POST, ACS_BASE_URL+"users/login.json?key="+ACS_API_KEY,
            parameters: [
                "login" : "myadminuser",
                "password" : "password123"
            ]).response { request, response, JSONResponse, error in
                
                
                var json = JSON(data:JSONResponse as NSData)

                
                if ( json["response"] ) {
                    var user = (json["response"]["users"])[0];
                    
                    // Successful login, now get the photos - Queue API calls
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        self.getPhotos({ (_photos:[PhotoInfo], _error:String?) -> Void in
                            println(_photos)
                            
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
                                println(idValue)
                                
                                var location = item["custom_fields"]["location_string"].stringValue
                                if  (location == nil) {
                                    location = "Missing Location"
                                }
                                photoInfos.append(PhotoInfo(_id:idValue, location : location!))
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
    
    func insertNewObject(sender: AnyObject) {
        //objects.insertObject(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
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
        println(objects.count)
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let object = objects[indexPath.row] as PhotoInfo
        cell.textLabel!.text = object.location
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
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

