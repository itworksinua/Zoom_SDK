//
//  RegistrationViewController.swift
//  ZoomApp
//
//  Created by 2020 on 11.06.2021.
//
import Firebase
import UIKit

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        if checkFields(mailField: emailTextField, passwordField: passwordTextField, nameField: nameTextField) {
            FirebaseApi.shared.registerUser(mail: emailTextField.text!, pass: passwordTextField.text!) { result, error in
                if let _ = result {
                } else {
                    self.displayError(title: error!)
                }
            }
            guard let userID = Auth.auth().currentUser?.uid else {
                self.displayError(title: "Error save user name")
                return}
            FirebaseDatabase.shared.uploadUser(userID: userID, name: nameTextField.text!)
                    let storyboard = UIStoryboard(name: "UsersList", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "UsersListViewController") as! UsersListViewController
                    let navController = UINavigationController(rootViewController: vc)
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated:true, completion: nil)
        }
    }
    
    func checkFields(mailField: UITextField, passwordField: UITextField, nameField: UITextField) -> Bool {
        if passwordField.text == "" || mailField.text == "" || nameField.text == "" {
            self.displayError(title: "one or more fields is empty")
            return false
        } else {
            return true
        }
    }
}
