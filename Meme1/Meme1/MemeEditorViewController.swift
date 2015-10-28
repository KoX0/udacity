//
//  ViewController.swift
//  Meme1
//
//  Created by Kosta Sush on 2015-09-23.
//  Copyright © 2015 Kosta Sush. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var photoBarButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var topTextField: UITextField! {
        didSet {
            setupTextFields(topTextField)
        }
    }
    @IBOutlet weak var bottomTextField: UITextField! {
        didSet {
            setupTextFields(bottomTextField)
        }
    }
    
    let textFieldAttributes = [
        NSStrokeWidthAttributeName: NSNumber(double:-3.0),
        NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!]
    let topTextDefault = NSLocalizedString("TOP", comment: "TextField placeholder")
    let bottomTextDeafult = NSLocalizedString("BOTTOM", comment: "TextField placeholder")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFieldsDefaults()
        shareButton.enabled = false
        cancelButton.enabled = false
        topTextField.userInteractionEnabled = false
        bottomTextField.userInteractionEnabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        photoBarButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    @IBAction func chooseImage(sender: UIBarButtonItem) {
        showImagePicker(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    @IBAction func takePhoto(sender: UIBarButtonItem) {
        showImagePicker(UIImagePickerControllerSourceType.Camera)
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        setupTextFieldsDefaults()
        imageView.image = nil
    }
    
    func setupTextFields(textField: UITextField) {
        textField.defaultTextAttributes = textFieldAttributes
        textField.textAlignment = .Center
        textField.delegate = self
    }
    
    func setupTextFieldsDefaults() {
        topTextField.text = topTextDefault
        bottomTextField.text = bottomTextDeafult
    }
    
    // MARK: Keyboard
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillShow:", name:UIKeyboardWillShowNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillHide:", name:UIKeyboardWillHideNotification, object:nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // MARK: Image Picker
    
    func showImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print(info)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            
            shareButton.enabled = true
            cancelButton.enabled = true
            topTextField.userInteractionEnabled = true
            bottomTextField.userInteractionEnabled = true
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: TextFields Delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text?.isEmpty == true {
            if textField == topTextField {
                topTextField.text = topTextDefault
            } else  {
                bottomTextField.text = bottomTextDeafult
            }
        } else {
            cancelButton.enabled = true
        }
    }
    
    // MARK: Save Meme
    
    func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imageView.image!, memedImage: generateMemedImage())
        print(meme)
    }
    
    func generateMemedImage() -> UIImage {
        navigationController?.setNavigationBarHidden(true, animated: false)
        toolBar.hidden = true
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        toolBar.hidden = false
        
        return memedImage
    }
    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        let image = generateMemedImage()
        
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        presentViewController(activityVC, animated: true, completion: nil)
        activityVC.completionWithItemsHandler = {
            (s: String?, ok: Bool, items: [AnyObject]?, err:NSError?) -> Void in
            if (ok) {
                self.save()
            }
            activityVC.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
}

