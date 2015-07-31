//
//  LoginViewController.swift
//  FestivalApp
//
//  Created by Ben Gray on 27/07/2015.
//  Copyright (c) 2015 YRS. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var usernameLabel: UITextField!
    @IBOutlet var passwordLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameLabel.attributedPlaceholder = NSAttributedString(string: "Username...", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        usernameLabel.tintColor = UIColor.whiteColor()
        passwordLabel.attributedPlaceholder = NSAttributedString(string: "Password...", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        passwordLabel.tintColor = UIColor.whiteColor()
        passwordLabel.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            go()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        login()
        return true
    }
    
    @IBAction func login() {
        if usernameLabel.text != nil && passwordLabel.text != nil {
            var user = PFUser()
            user.username = usernameLabel.text
            user.password = passwordLabel.text
            user.signUpInBackgroundWithBlock({
            (success, error) -> Void in
                if success && error == nil {
                    self.go()
                } else {
                    if error!.code == 202 {
                        PFUser.logInWithUsernameInBackground(self.usernameLabel.text, password: self.passwordLabel.text, block: {
                            (user, error) -> Void in
                            if user != nil && error == nil {
                                self.go()
                            } else {
                                let alert = UIAlertView(title: "Error", message: error!.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                                alert.show()
                            }
                        })
                    } else {
                        let alert = UIAlertView(title: "Error", message: error!.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                }
            })
        }
    }
    
    func go() {
        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("ChooseFestival") as! UIViewController
        self.presentViewController(viewController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
