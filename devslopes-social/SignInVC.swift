//
//  ViewController.swift
//  devslopes-social
//
//  Created by Premier Data on 1/8/17.
//  Copyright © 2017 Premier Data. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passwordField: FancyField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("AK: ID found in Keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
    }
        
    }

    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("AK: Unable to authenticate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                print("AK: User cancelled Facebook authentication")
            } else {
                print("AK: Successfully authenticated with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
        
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("AK: Unable to authenticate with Firebase - \(error)")
            } else {
                print("AK: Successfully authenticated with Firebase")
                if let user =  user {
                    self.completeSignIn(id: user.uid)
                    }
                }
        })
    }
    @IBAction func signInBtnTapped(_ sender: Any) {
        if let email = emailField.text, let pwd = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("AK: Email User authenticated with Firebase")
                    if let user =  user {
                        self.completeSignIn(id: user.uid)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error == nil {
                            print("AK: Authenticated with Firebase using Email")
                            if let user =  user {
                                self.completeSignIn(id: user.uid)
                            }
                        } else {
                            print("AK: Unable to authenticate with Firebase using Email")
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(id: String){
        let keychainResult: Bool = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("AK: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
}

