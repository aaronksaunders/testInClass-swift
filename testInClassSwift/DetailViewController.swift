//
//  DetailViewController.swift
//  testInClassSwift
//
//  Created by Aaron saunders on 3/14/15.
//  Copyright (c) 2015 Clearly Innovative Inc. All rights reserved.
//

import UIKit
import Haneke

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var largeImageView: UIImageView!

    var detailItem: MasterViewController.PhotoInfo? {
        didSet {
            // Update the view.
            //self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: MasterViewController.PhotoInfo = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = " \(detail.location)  \(detail._id)"
            }
            
            let cache = Shared.imageCache
            let fetcher = NetworkFetcher<UIImage>(URL: NSURL(string:detail.originalURL)!)
            cache.fetch(fetcher: fetcher).onSuccess { image in
                // Do something with image
                
                //cell.thumbView?.bounds = CGRectMake(8,2, 74, 74)
                self.largeImageView?.clipsToBounds = true
                self.largeImageView?.contentMode = .ScaleAspectFit
                self.largeImageView?.image = image
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showMap" {
            let destinationController = segue.destinationViewController as MapViewController
            destinationController.detailItem = detailItem
        }
    }
}

