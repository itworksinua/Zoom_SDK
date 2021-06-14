
import MobileRTC
import UIKit

class UsersListViewController: UIViewController {
    
    
    @IBOutlet weak var userTableView: UITableView! {
        didSet {
            userTableView.delegate = self
            userTableView.dataSource = self
        }
    }
    
    var usersArray = [User]()
    let cellId = "nameCell"
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUsers()
        
    }
    
    func configureNavBar() {
        navigationItem.title = "Active Users"
        let cleanBtn = UIButton(type: .custom)
        cleanBtn.frame = CGRect(x: 0.0, y: 0.0, width: 24, height: 24)
        cleanBtn.setImage(UIImage(named:"add_icon"), for: .normal)
        cleanBtn.addTarget(self, action: #selector(addNote(_:)), for: .touchUpInside)
        let rightItem = UIBarButtonItem(customView: cleanBtn)
        let currWidth = rightItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = rightItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = rightItem
        
    }
    
    @objc func addNote(_ sender: Any?) {
        
        let storyboard = UIStoryboard(name: "Meeting", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MeetingViewController") as! MeetingViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func getUsers() {
        FirebaseDatabase.shared.getUsers() { result in
            self.usersArray = result
            self.userTableView.reloadData()
        }
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
        return 100
    }
}

extension UsersListViewController: MobileRTCMeetingServiceDelegate{
    func onMeetingStateChange(_ state: MobileRTCMeetingState) {
       print("\(state)")
    }
}
