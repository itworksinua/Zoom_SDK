
import NotificationBannerSwift
import UIKit

class AuthViewController: UIViewController {
    
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier:"RegistrationViewController") as! RegistrationViewController
        self.present(vc, animated: true, completion:nil)
    }
    
    @IBAction func logInButtonPressed(_ sender: Any) {
        
        if checkFields(mailField: mailTextField, passwordField: passwordTextField) {
            FirebaseApi.shared.login(mail: mailTextField.text!, pass: passwordTextField.text!) { result, error in
                if let _ = result {
                    let storyboard = UIStoryboard(name: "UsersList", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "UsersListViewController") as! UsersListViewController
                    let navController = UINavigationController(rootViewController: vc)
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated:true, completion: nil)
                } else {
                    self.displayError(title: error!)
                }
            }
        }
    }
    
    func checkFields(mailField: UITextField, passwordField: UITextField) -> Bool {
        if passwordField.text == "" || mailField.text == "" {
            self.displayError(title: "mail or password is empty")
            return false
        } else {
            return true
        }
    }
}

