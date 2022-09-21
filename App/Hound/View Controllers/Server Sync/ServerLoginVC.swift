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

final class ServerLoginViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = self.view.window else {
            return ASPresentationAnchor()
        }
        
        return window
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            /*
             guard let appleIDToken = appleIDCredential.identityToken else {
             AppDelegate.generalLogger.error("ASAuthorizationController encounterd an error after didCompleteWithAuthorization: Unable to fetch identity token")
             ErrorConstant.SignInWithAppleError.other.alert()
             return
             }
             
             guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
             AppDelegate.generalLogger.error("ASAuthorizationController encounterd an error after didCompleteWithAuthorization: Unable to serialize token string from data: \(appleIDToken.debugDescription)")
             return
             }
             */
            
            let keychain = KeychainSwift()
            
            let userIdentifier = Hash.sha256Hash(forString: appleIDCredential.user)
            
            UserInformation.userIdentifier = userIdentifier
            
            keychain.set(userIdentifier, forKey: KeyConstant.userIdentifier.rawValue)
            
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
            if let email = email {
                keychain.set(email, forKey: KeyConstant.userEmail.rawValue)
                UserInformation.userEmail = email
            }
            
            let fullName = appleIDCredential.fullName
            
            let firstName = fullName?.givenName
            if let firstName = firstName {
                keychain.set(firstName, forKey: KeyConstant.userFirstName.rawValue)
                UserInformation.userFirstName = firstName
            }
            
            let lastName = fullName?.familyName
            if let lastName = lastName {
                keychain.set(lastName, forKey: KeyConstant.userLastName.rawValue)
                UserInformation.userLastName = lastName
            }
            
            self.signUpUser()
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
            ErrorConstant.SignInWithAppleError.canceled.alert()
        case .unknown:
            // user not signed into apple id
            ErrorConstant.SignInWithAppleError.notSignedIn.alert()
        default:
            ErrorConstant.SignInWithAppleError.other.alert()
        }
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var welcome: ScaledUILabel!
    
    @IBOutlet private weak var welcomeMessage: ScaledUILabel!
    
    // MARK: - Properties
    
    private var signInWithApple: ASAuthorizationAppleIDButton!
    
    // MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oneTimeSetup()
    }
    
    override func viewWillLayoutSubviews() {
        repeatableSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Called before the view is added to the windows’ view hierarchy
        super.viewWillAppear(animated)
        
        // make sure the view has the correct interfaceStyle
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    // MARK: Setup
    
    private func oneTimeSetup() {
        // we want the user to have a fresh login experience, so we reset the introduction pages
        LocalConfiguration.hasLoadedHoundIntroductionViewControllerBefore = false
        LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore = false
        
        // all other information tracks something important and shouldn't be modified, we simply do this so the user is greeted
        
        if UserInformation.userIdentifier != nil {
            // we found a userIdentifier in the keychain (during recurringSetup) so we change the info to match.
            // we could technically automatically log then in but this is easier. this verifies that an account exists and creates once if needed (if old one was deleted somehow)
            welcome.text = "Welcome Back"
            welcomeMessage.text = "Sign in to your existing Hound account below. If you don't have one, creating or joining a family will come soon..."
        }
        else {
            // no info in keychain, assume first time setup
            welcome.text = "Welcome"
            welcomeMessage.text = "Create your Hound account below. Creating or joining a family will come soon..."
        }
    }
    
    private func repeatableSetup() {
        setupSignInWithApple()
        setupSignInWithAppleDisclaimer()
        func setupSignInWithApple() {
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
        
        func setupSignInWithAppleDisclaimer() {
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
                signInWithAppleDisclaimer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0 + (signInWithApple.frame.height / 2)),
                signInWithAppleDisclaimer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10 - (signInWithApple.frame.height / 2))]
            NSLayoutConstraint.activate(constraints)
        }
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
    
    private func signUpUser() {
        // start query indictator, if there is already one present then its fine as alertmanager will throw away the duplicate. we remove the query indicator when we finish interpreting our response (EXCEPT when we go to sign in a user, as that will also use query indictator so we want it to stay up)
        RequestUtils.beginRequestIndictator()
        // we have do a failure response doesn't necessarily mean a failure message, so we msut do the messages ourself
        UserRequest.create(invokeErrorManager: false) { userId, responseStatus in
            switch responseStatus {
            case .successResponse:
                // successful, continue
                if let userId = userId {
                    RequestUtils.endRequestIndictator {
                        UserInformation.userId = userId
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    // create new account failed, possibly already created account
                    self.signInUser()
                }
            case .failureResponse:
                // create new account failed, possibly already created account
                self.signInUser()
            case .noResponse:
                RequestUtils.endRequestIndictator {
                    ErrorConstant.GeneralResponseError.postNoResponse.alert()
                }
            }
        }
    }
    
    private func signInUser() {
        // Don't begin RequestUtils.beginRequestIndictator() as we already have one from signUpUser
        _ = UserRequest.get(invokeErrorManager: true) { userId, _, _ in
            // the user config is already automatically setup with this function
            RequestUtils.endRequestIndictator {
                if userId != nil {
                    // user was successfully retrieved from the server
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
