import Firebase
import Foundation
import FirebaseFirestore

class FirebaseDatabase {
    
    static let shared: FirebaseDatabase = {
        let instance = FirebaseDatabase()
        return instance
        
    }()
    
   private let db = Firestore.firestore()
    
    func  uploadUser(userID: String, name: String, UUID: String) {
        db.collection("users").document(userID).setData(["name": name, "UUID": UUID])
    }
    
    func getUsers(onCompletion: @escaping ([User]) -> Void) {
        db.collection("users").getDocuments { (snapshot, error) in
            var users = [User]()
            
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    let id = document.documentID
                    let name = document.get("name") as! String
                    let UUID = document.get("UUID") as! String
                    let user = User(name: name, uid: id, UUID: UUID)
                    users.append(user)
                }
                onCompletion(users)
            }
        }
    }
}
