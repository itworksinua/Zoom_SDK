import UIKit
import Firebase
import CallKit
import MobileRTC

class UsersListViewController: UIViewController {
    
    @IBOutlet weak var userTableView: UITableView! {
        didSet {
            userTableView.delegate = self
            userTableView.dataSource = self
        }
    }
    
    var usersArray = [User]()
    let cellId = "nameCell"
    var currentUser: User?
    var selecteUUID = ""
    var password = "" {
        didSet {
            let notifPayload: [String: Any] = [
                "to": selecteUUID,
                "content_available": true,
                "apns-priority": 5,
                "mutable-content": true,
                "data": [
                  "roomID": roomID,
                    "pass": password
                ]
              ]
            FirebaseApi.shared.sendPushNotification(payloadDict: notifPayload)
        }
    }
    var roomID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsers()
        configureNavBar()
        
        
        // The Zoom SDK requires a UINavigationController to update the UI for us. Here we supplied the SDK with the ViewControllers navigationController.
        MobileRTC.shared().setMobileRTCRootController(self.navigationController)

        /// Notification that is used to start a meeting upon log in success.
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedIn), name: NSNotification.Name(rawValue: "userLoggedIn"), object: nil)
    }
    
    func configureNavBar() {
        navigationItem.title = "Active Users"
        let cleanBtn = UIButton(type: .custom)
        cleanBtn.frame = CGRect(x: 0.0, y: 0.0, width: 24, height: 24)
        cleanBtn.setImage(UIImage(named:"zoom_icon"), for: .normal)
        cleanBtn.addTarget(self, action: #selector(goToZoom(_:)), for: .touchUpInside)
        let rightItem = UIBarButtonItem(customView: cleanBtn)
        let currWidth = rightItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = rightItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = rightItem
        
        let callButton = UIButton(type: .custom)
        callButton.frame = CGRect(x: 0.0, y: 0.0, width: 24, height: 24)
        callButton.setImage(UIImage(named:"phone_icon"), for: .normal)
        callButton.addTarget(self, action: #selector(call(_:)), for: .touchUpInside)
        let leftItem = UIBarButtonItem(customView: callButton)
        let width = leftItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        width?.isActive = true
        let height = leftItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        height?.isActive = true
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    @objc func goToZoom(_ sender: Any?) {
        
        let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MeetingViewController") as! MeetingViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func call(_ sender: Any?) {
        
        
        let storyboard = UIStoryboard(name: "Call", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func getUsers() {
        FirebaseDatabase.shared.getUsers() { result in
            self.usersArray = result
            guard let userID = Auth.auth().currentUser?.uid else {
                return
            }
            for (index, element) in self.usersArray.enumerated() {
                if element.uid == userID {
                    print(element)
                    self.usersArray.remove(at: index)
                }
            }
            self.userTableView.reloadData()
        }
    }
    
    func presentLogInAlert() {
        let alertController = UIAlertController(title: "Enter your Zoom credentials", message: "", preferredStyle: .alert)

        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Password"
            textField.keyboardType = .asciiCapable
            textField.isSecureTextEntry = true
        }

        let logInAction = UIAlertAction(title: "Log in", style: .default, handler: { alert -> Void in
            let emailTextField = alertController.textFields![0] as UITextField
            let passwordTextField = alertController.textFields![1] as UITextField

            if let email = emailTextField.text, let password = passwordTextField.text {
                self.logIn(email: email, password: password)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })

        alertController.addAction(logInAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
    
    func logIn(email: String, password: String) {
        // Obtain the MobileRTCAuthService from the Zoom SDK, this service can log in a Zoom user, log out a Zoom user, authorize the Zoom SDK etc.
        if let authorizationService = MobileRTC.shared().getAuthService() {
            // Call the login function in MobileRTCAuthService. This will attempt to log in the user.
            authorizationService.login(withEmail: email, password: password, rememberMe: false)
        }
    }
    
    func startMeeting() {
        if let meetingService = MobileRTC.shared().getMeetingService() {
            // Set the ViewContoller to be the MobileRTCMeetingServiceDelegate
            meetingService.delegate = self
            let startMeetingParameters = MobileRTCMeetingStartParam4LoginlUser()
            meetingService.startMeeting(with: startMeetingParameters)
          
        }
    }
    
    @objc func userLoggedIn() {
        startMeeting()
    }
}

extension UsersListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! UserListTableViewCell
        let item = usersArray[indexPath.row]
        cell.configure(name: item.name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let authorizationService = MobileRTC.shared().getAuthService(), authorizationService.isLoggedIn() {
            startMeeting()
        } else {
            presentLogInAlert()
        }
        selecteUUID = usersArray[indexPath.row].UUID
    }
}

extension UsersListViewController: MobileRTCMeetingServiceDelegate {

    // Is called upon in-meeting errors, join meeting errors, start meeting errors, meeting connection errors, etc.
    func onMeetingError(_ error: MobileRTCMeetError, message: String?) {
        switch error {
        case .passwordError:
            print("Could not join or start meeting because the meeting password was incorrect.")
        default:
            print("Could not join or start meeting with MobileRTCMeetError: \(error) \(message ?? "")")
        }
    }

    // Is called when the user joins a meeting.
    func onJoinMeetingConfirmed() {
        print("Join meeting confirmed.")
    }

    // Is called upon meeting state changes.
    func onMeetingStateChange(_ state: MobileRTCMeetingState) {
        print("Current meeting state: \(state)")
        let id =  MobileRTCInviteHelper.sharedInstance().ongoingMeetingNumber
        let pass = MobileRTCInviteHelper.sharedInstance().rawMeetingPassword
        if id != "" && pass != "" {
            roomID = id
            password = pass
        }
    }
}
