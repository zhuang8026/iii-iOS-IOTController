import UIKit

class AlertHelper {
    static func showAlert(title: String, message: String, confirmHandler: (() -> Void)? = nil) {
        guard let topVC = topViewController() else {
            print("❌ 無法找到畫面上的 UIViewController")
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "確定", style: .default) { _ in
            confirmHandler?()
        }
        alert.addAction(confirmAction)
        
        topVC.present(alert, animated: true)
    }

    private static func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseVC: UIViewController?

        if let base = base {
            baseVC = base
        } else {
            baseVC = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })?
                .rootViewController
        }

        if let nav = baseVC as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        } else if let tab = baseVC as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        } else if let presented = baseVC?.presentedViewController {
            return topViewController(base: presented)
        }

        return baseVC
    }
}
