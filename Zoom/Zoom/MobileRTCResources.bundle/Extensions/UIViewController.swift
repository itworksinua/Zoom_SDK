import UIKit
import Foundation
import NotificationBannerSwift

extension UIViewController {
    
    func displayError(title: String) {
        let banner = NotificationBanner(title: title, style: .danger, colors: CustomBannerColors())
        banner.show()
    }
}
