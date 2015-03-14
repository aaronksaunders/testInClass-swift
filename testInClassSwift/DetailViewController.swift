//
//  DetailViewController.swift
//  testInClassSwift
//
//  Created by Aaron saunders on 3/14/15.
//  Copyright (c) 2015 Clearly Innovative Inc. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    var detailItem: MasterViewController.PhotoInfo? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: MasterViewController.PhotoInfo = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = " \(detail.location)  \(detail._id)"
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


}

