//
//  RegistrationViewModel.swift
//  Tinder
//
//  Created by Bekzod Rakhmatov on 27/01/2019.
//  Copyright © 2019 BekzodRakhmatov. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewModel {
    
    var bindableImage         = Bindable<UIImage>()
    var bindableIsFormValid   = Bindable<Bool>()
    var bindableIsRegistering = Bindable<Bool>()
    
    var fullName: String? { didSet { checkForValidity() } }
    var email: String?    { didSet { checkForValidity() } }
    var password: String? { didSet { checkForValidity() } }
    
    func perfromRegistration(completion: @escaping (Error?) -> ()) {
        
        guard let email = email, let password = password else { return }
        
        bindableIsRegistering.value = true
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            if let error = error {
                
                completion(error)
                return
            }
            
            // You can only upload
            let fileName = UUID().uuidString
            let reference = Storage.storage().reference(withPath: "/images/\(fileName).jpg")
            let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
            reference.putData(imageData, metadata: nil, completion: { (_, err) in
                
                if let err = err {
                    completion(err)
                    return
                }
                
                reference.downloadURL(completion: { (url, error) in
                    
                    if let error = error {
                        completion(error)
                        return
                    }
                    
                    self.bindableIsRegistering.value = false
                })
            })
        }
    }
    
    fileprivate func checkForValidity() {
        
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false
        bindableIsFormValid.value = isFormValid
    }
}
