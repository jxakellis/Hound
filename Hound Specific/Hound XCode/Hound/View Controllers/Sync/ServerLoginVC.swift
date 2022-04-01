//
//  ServerLoginViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/3/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit
import AuthenticationServices
import KeychainSwift

class ServerLoginViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            /*
            guard let appleIDToken = appleIDCredential.identityToken else {
                AppDelegate.generalLogger.error("ASAuthorizationController encounterd an error after didCompleteWithAuthorization: Unable to fetch identity token")
                ErrorManager.alert(forError: SignInWithAppleError.other)
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                AppDelegate.generalLogger.error("ASAuthorizationController encounterd an error after didCompleteWithAuthorization: Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
             */
            
            let keychain = KeychainSwift()
            
            let userIdentifier = appleIDCredential.user
            UserInformation.userIdentifier = userIdentifier
            keychain.set(userIdentifier, forKey: "userIdentifier")
            
            // IMPORTANT NOTES ABOUT PERSISTANCE AND KEYCHAIN
            // fullName and email are ONLY provided on the FIRST time the user uses sign in with apple
            // If they are signing in again to Hound, only userIdentifier is provided
            // Therefore we must persist these email, firstName, and lastName to the keychain until an account is successfully created.
            
            // REASONING ABOUT PERSISTANCE AND KEYCHAIN
            // If the user signs in with apple and we go to create an account on Hound's server, but the request fails. We are in a tricky spot. If the user tries to 'Sign In With Apple' again, we can't retrieve the first name, last name, or email again... we only get userIdentifier.
            // Therefore, this could create an edge case where the user could be
            // 1. try to sign up in
            // 2. the sign up fails for whatever reason (e.g. they have no internet)
            // 3. they uninstall Hound
            // 4. they reinstall Hound
            // 5. they go to 'sign in with apple', but since Apple recognizes they have already done that with Hound, we only get the userIdentifier
            // 6. the user is stuck. they have no account on the server and can't create one since we are unable to access the email, first name, and last name. The only way to fix this would be having them go into the iCloud 'Password & Security' settings and deleting Hound, giving them a fresh start.
            
            let email = appleIDCredential.email
            if email != nil {
                keychain.set(email!, forKey: "userEmail")
                UserInformation.userEmail = email
            }
            
            let fullName = appleIDCredential.fullName
            
            let firstName = fullName?.givenName
            if firstName != nil {
                keychain.set(firstName!, forKey: "userFirstName")
                UserInformation.userFirstName = firstName!
            }
            
            let lastName = fullName?.familyName
            if lastName != nil {
                keychain.set(lastName!, forKey: "userLastName")
                UserInformation.userLastName = lastName!
            }
            
            UserRequest.create { userId, responseStatus in
                switch responseStatus {
                case .successResponse:
                    // successful, continue
                    if userId != nil {
                        UserInformation.userId = userId!
                        self.dismiss(animated: true, completion: nil)
                    }
                    else {
                        // possibly already created account
                        UserRequest.get(forUserIdentifier: UserInformation.userIdentifier!) { responseBody, responseStatus in
                            switch responseStatus {
                            case .successResponse:
                                if responseBody != nil {
                                    // verify that at least one user was returned. Shouldn't be possible to have no users but always good to check
                                    if let result = responseBody!["result"] as? [[String: Any]], result.isEmpty == false {
                                        // set all local configuration equal to whats in the server
                                        UserInformation.setup(fromBody: result[0])
                                        UserConfiguration.setup(fromBody: result[0])
                                        
                                        // verify that a userId was successfully retrieved from the server
                                        if result[0]["userId"] is Int {
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                        else {
                                            ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                                        }
                                    }
                                    else {
                                        ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                                    }
                                }
                            case .failureResponse:
                                ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                            case .noResponse:
                                ErrorManager.alert(forError: GeneralResponseError.noGetResponse)
                            }
                        }
                    }
                case .failureResponse:
                    // possible already created account
                    UserRequest.get(forUserIdentifier: UserInformation.userIdentifier!) { responseBody, responseStatus in
                        switch responseStatus {
                        case .successResponse:
                            if responseBody != nil {
                                // verify that at least one user was returned. Shouldn't be possible to have no users but always good to check
                                if let result = responseBody!["result"] as? [[String: Any]], result.isEmpty == false {
                                    // set all local configuration equal to whats in the server
                                    UserInformation.setup(fromBody: result[0])
                                    UserConfiguration.setup(fromBody: result[0])
                                    
                                    // verify that a userId was successfully retrieved from the server
                                    if result[0]["userId"] is Int {
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                    else {
                                        ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                                    }
                                }
                                else {
                                    ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                                }
                            }
                        case .failureResponse:
                            ErrorManager.alert(forError: GeneralResponseError.failureGetResponse)
                        case .noResponse:
                            ErrorManager.alert(forError: GeneralResponseError.noGetResponse)
                        }
                    }
                case .noResponse:
                    ErrorManager.alert(forError: GeneralResponseError.noPostResponse)
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        guard let error = error as? ASAuthorizationError else {
            return
        }
        
        switch error.code {
        case .canceled:
            // user hit cancel on the 'Data and privacy information screen'
            ErrorManager.alert(forError: SignInWithAppleError.canceled)
        case .unknown:
            // user not signed into apple id
            ErrorManager.alert(forError: SignInWithAppleError.unknown)
        case .invalidResponse:
            ErrorManager.alert(forError: SignInWithAppleError.other)
        case .notHandled:
            ErrorManager.alert(forError: SignInWithAppleError.other)
        case .failed:
            ErrorManager.alert(forError: SignInWithAppleError.other)
        case .notInteractive:
            ErrorManager.alert(forError: SignInWithAppleError.other)
        @unknown default:
            ErrorManager.alert(forError: SignInWithAppleError.other)
        }
    }
    
    // MARK: - IB
    
    // MARK: - Properties
    
    @IBOutlet private weak var welcome: ScaledUILabel!
    
    @IBOutlet private weak var welcomeMessage: ScaledUILabel!
    
    private var signInWithApple: ASAuthorizationAppleIDButton!
    
    // MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserInformation.userIdentifier != nil {
            // we found a userIdentifier in the keychain (during recurringSetup) so we change the info to match.
            // we could technically automatically log then in but this is easier. this verifies that an account exists and creates once if needed (if old one was deleted somehow)
            welcome.text = "Welcome Back"
            welcomeMessage.text = "Sign in to your existing Hound account below. Creating or joining a family will come soon..."
        }
        else {
            // no info in keychain, assume first time setup
            welcome.text = "Welcome"
            welcomeMessage.text = "Create your Hound account below. Creating or joining a family will come soon..."
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        setupSignInWithApple()
        setupSignInWithAppleDisclaimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Called before the view is added to the windows’ view hierarchy
        super.viewWillAppear(animated)
        // Make this view the presenter if the app has to present any alert.
        AlertManager.globalPresenter = self

        // make sure the view has the correct interfaceStyle
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Setup Buttons and Labels
    
    private func setupSignInWithApple() {
        // make actual button
        if UserInformation.userIdentifier != nil {
            // pre existing data
            signInWithApple = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
        }
        else {
            // no preexisting data, new
            signInWithApple = ASAuthorizationAppleIDButton(type: .signUp, style: .whiteOutline)
        }
        
        signInWithApple.translatesAutoresizingMaskIntoConstraints = false
        signInWithApple.addTarget(self, action: #selector(signInWithAppleTapped), for: .touchUpInside)
        self.view.addSubview(signInWithApple)
        
        let constraints = [signInWithApple.topAnchor.constraint(equalTo: welcomeMessage.bottomAnchor, constant: 45),
                           signInWithApple.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                           signInWithApple.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                           signInWithApple.heightAnchor.constraint(equalTo: signInWithApple.widthAnchor, multiplier: 0.16)]
        NSLayoutConstraint.activate(constraints)
        // set to made to have fully rounded corners
        signInWithApple.cornerRadius = 99999.9
        
    }
    
    private func setupSignInWithAppleDisclaimer() {
        let signInWithAppleDisclaimer = ScaledUILabel()
        
        if UserInformation.userIdentifier != nil {
            // pre existing data
            signInWithAppleDisclaimer.text = "Currently, Hound only offers accounts through the 'Sign In With Apple' feature. This requires you have an Apple ID with two-factor authentication enabled."
        }
        else {
            // no preexisting data, new
            signInWithAppleDisclaimer.text = "Currently, Hound only offers accounts through the 'Sign Up With Apple' feature. This requires you have an Apple ID with two-factor authentication enabled."
        }
        
        signInWithAppleDisclaimer.translatesAutoresizingMaskIntoConstraints = false
        signInWithAppleDisclaimer.numberOfLines = 0
        signInWithAppleDisclaimer.font = .systemFont(ofSize: 12.5, weight: .light)
        signInWithAppleDisclaimer.textColor = .white
        
        self.view.addSubview(signInWithAppleDisclaimer)
        
        let constraints = [
            signInWithAppleDisclaimer.topAnchor.constraint(equalTo: signInWithApple.bottomAnchor, constant: 12.5),
            signInWithAppleDisclaimer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0 + (signInWithApple.frame.height/2)),
            signInWithAppleDisclaimer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10 - (signInWithApple.frame.height/2))]
        NSLayoutConstraint.activate(constraints)
        
        // self.view.setNeedsLayout()
        // self.view.layoutIfNeeded()
    }
    
    // MARK: - Sign In With Apple
    
    @objc private func signInWithAppleTapped() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
