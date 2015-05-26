//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Saurabh Sikka on 25/05/15.
//  Copyright (c) 2015 Saurabh Sikka. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var memes: [Meme]!
    var weHaveMemes: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        memes = appDelegate.memes
        
        // If we have no memes...
        if !weHaveMemes {
            weHaveMemes = true
            if memes.count == 0 {
                performSegueWithIdentifier("AddMeme", sender: self)
            }
        }
        
        if tableView.numberOfRowsInSection(0) != memes.count {
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableCell") as UITableViewCell
        let meme = self.memes[indexPath.row]
        
        // Set the memed image & labels
        cell.imageView?.image = meme.memedImage
        cell.textLabel?.text = meme.topText
        
        if let detailTextLabel = cell.detailTextLabel {
            detailTextLabel.text = meme.bottomText
        }
        return cell
    }
    
    // After selecting image, GOTO detail controller
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as MemeDetailViewController
        detailViewController.meme = self.memes[indexPath.row]
        self.navigationController!.pushViewController(detailViewController, animated: false)
        
    }
    
}
