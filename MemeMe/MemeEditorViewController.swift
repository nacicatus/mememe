//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Saurabh Sikka on 25/05/15.
//  Copyright (c) 2015 Saurabh Sikka. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // Outlets and Global Variables
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    var memedImage: UIImage!
    var topTextFieldFinishedEditing: Bool!
    var bottomTextFieldFinishedEditing: Bool!
    
    override func viewWillAppear(animated: Bool) {
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        self.subscribeToKeyboardNotifications()
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
        self.tabBarController?.tabBar.hidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set meme text attributes
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -2
        ]
        
        // Prepare text fields for future editing
        self.topTextField.delegate = self;
        self.bottomTextField.delegate = self;
        topTextFieldFinishedEditing = false
        bottomTextFieldFinishedEditing = false
        
        topTextField.text = "TOP"
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = NSTextAlignment.Center
        
        bottomTextField.text = "BOTTOM"
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = NSTextAlignment.Center
        
        if imageView.image == nil {
            shareButton.enabled = false
        }
    }

    // Clear text fields and Autocapitalize Text
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 0 {
            if !topTextFieldFinishedEditing {
                textField.text = ""
                topTextField?.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
                topTextFieldFinishedEditing = true
            }
        }
        else if textField.tag == 1 {
            if !bottomTextFieldFinishedEditing {
                textField.text = ""
                bottomTextField?.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
                bottomTextFieldFinishedEditing = true
            }
        }
    }
    
    // Hide the keyboard on return key
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Move the view up
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    // Move the view down
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    // Get the keyboard height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue
        return keyboardSize.CGRectValue().height
    }
    
    // Subscribe to keyboard show/hide notification.
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // Unsubscribe to keyboard notifications.
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    // Prepare Image for Meme generation
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
            topTextFieldFinishedEditing = false
            bottomTextFieldFinishedEditing = false
            shareButton.enabled = true
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // Cancel Meme generation
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Create the Meme!
    func generateMemedImage() -> UIImage {
        
        navigationController?.navigationBar.hidden = true
        toolbar.hidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        navigationController?.navigationBar.hidden = false
        toolbar.hidden = false
        
        return memedImage
    }

    
    // Append the Meme to the memes array in the AppDelegate
    func saveMeme() {
        var meme = Meme(topText: topTextField.text, bottomText: bottomTextField.text, originalImage: imageView.image!, memedImage: self.memedImage)
        (UIApplication.sharedApplication().delegate as AppDelegate).memes.append(meme)
    }
    
    // Prepare to share
    func prepareToShare(activity: String!, completed: Bool, items: [AnyObject]!, error: NSError!) {
        if completed {
            self.saveMeme()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // Share
    @IBAction func shareMeme(sender: AnyObject) {
        self.memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [self.memedImage], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = prepareToShare
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // Cancel
    @IBAction func cancelPickAnImage(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // Camera
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    // Album
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(pickerController, animated: true, completion: nil)
    }



}

