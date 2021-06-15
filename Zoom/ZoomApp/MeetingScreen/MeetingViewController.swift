import UIKit
import MobileRTC

class MeetingViewController: UIViewController {

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // The Zoom SDK requires a UINavigationController to update the UI for us. Here we supplied the SDK with the ViewControllers navigationController.
        MobileRTC.shared().setMobileRTCRootController(self.navigationController)

        /// Notification that is used to start a meeting upon log in success.
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedIn), name: NSNotification.Name(rawValue: "userLoggedIn"), object: nil)
    }
    
    
    @IBAction func join(_ sender: Any) {
        presentJoinMeetingAlert()
    }
    
    
    @IBAction func start(_ sender: Any) {
        // Obtain the MobileRTCAuthService from the Zoom SDK, and check if the user is logged into Zoom.
        if let authorizationService = MobileRTC.shared().getAuthService(), authorizationService.isLoggedIn() {
            startMeeting()
        } else {
            presentLogInAlert()
        }
    }

    func joinMeeting(meetingNumber: String, meetingPassword: String) {
        if let meetingService = MobileRTC.shared().getMeetingService() {
            meetingService.delegate = self
            let joinMeetingParameters = MobileRTCMeetingJoinParam()
            joinMeetingParameters.meetingNumber = meetingNumber
            joinMeetingParameters.password = meetingPassword
            meetingService.joinMeeting(with: joinMeetingParameters)
        }
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

    func presentJoinMeetingAlert() {
        let alertController = UIAlertController(title: "Join meeting", message: "", preferredStyle: .alert)

        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Meeting number"
            textField.keyboardType = .phonePad
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Meeting password"
            textField.keyboardType = .asciiCapable
            textField.isSecureTextEntry = true
        }

        let joinMeetingAction = UIAlertAction(title: "Join meeting", style: .default, handler: { alert -> Void in
            let numberTextField = alertController.textFields![0] as UITextField
            let passwordTextField = alertController.textFields![1] as UITextField

            if let meetingNumber = numberTextField.text, let password = passwordTextField.text {
                self.joinMeeting(meetingNumber: meetingNumber, meetingPassword: password)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })

        alertController.addAction(joinMeetingAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    /// Creates alert for prompting the user to enter thier Zoom credentials for starting a meeting.
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

    // MARK: - Internal
    /// Selector that is used to start a meeting upon log in success.
    @objc func userLoggedIn() {
        startMeeting()
    }
}

// MARK: - MobileRTCMeetingServiceDelegate
// Conform ViewController to MobileRTCMeetingServiceDelegate.
// MobileRTCMeetingServiceDelegate listens to updates about meetings, such as meeting state changes, join attempt status, meeting errors, etc.
extension MeetingViewController: MobileRTCMeetingServiceDelegate {

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
    }
}
