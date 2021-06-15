import UIKit
import Foundation
import NotificationBannerSwift

extension UIViewController {
    
    func displayError(title: String) {
        let banner = NotificationBanner(title: title, style: .danger, colors: CustomBannerColors())
        banner.show()
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
