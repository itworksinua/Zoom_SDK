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
    
    func sendPushNotification(payloadDict: [String: Any]) {
       let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
       var request = URLRequest(url: url)
       request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       request.setValue("key=AAAAozdofj8:APA91bHei2aI8eWjy88GiYKOiO-nGKM4e7Tree2TB2cy0ebXMOcX8m_rR0IodGhsKL5_6dz0LYpjdyV4w7AD5mFtzTGrktz208N7jMo8cHTHaTMhjk4-Augt8dYqdcbMHWee3NPJlEug", forHTTPHeaderField: "Authorization")
       request.httpMethod = "POST"
       request.httpBody = try? JSONSerialization.data(withJSONObject: payloadDict, options: [])
       let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data, error == nil else {
            print(error ?? "")
            return
          }
          if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
            print("statusCode should be 200, but is \(httpStatus.statusCode)")
            print(response ?? "")
          }
          print("Notfication sent successfully.")
          let responseString = String(data: data, encoding: .utf8)
          print(responseString ?? "")
       }
       task.resume()
    }
}
