import UIKit
import Foundation
import FirebaseAuth

class FirebaseApi {
    static let shared: FirebaseApi = {
        let instance = FirebaseApi()
        return instance
    }()
    
    func login(mail: String, pass: String, complition: @escaping (Bool?, String?) -> Void) {
        Auth.auth().signIn(withEmail: mail, password: pass) { authResult, error in
            if error == nil {
                if authResult != nil {
                   complition(true, nil)
                }
            } else {
                complition(nil, String(describing: error))
            }
        }
    }
    
    func registerUser(mail: String, pass: String, complition: @escaping (Bool?, String?) -> Void) {
        Auth.auth().createUser(withEmail: mail, password: pass) { user, error in
            if error == nil && user != nil {
              complition(true, nil)
            } else  {
                complition(nil, String(describing: error))
            }
        }
    }
}
