import UIKit

open class FullSwipeNavigationController: UINavigationController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupFullWidthBackGesture()
    }
    
    private lazy var fullWidthBackGestureRecognizer = UIPanGestureRecognizer()

    private func setupFullWidthBackGesture() {
        guard
            let interactivePopGestureRecognizer = interactivePopGestureRecognizer,
            let targets = interactivePopGestureRecognizer.value(forKey: "targets")
        else {
            return
        }

        fullWidthBackGestureRecognizer.setValue(targets, forKey: "targets")
        fullWidthBackGestureRecognizer.delegate = self
        view.addGestureRecognizer(fullWidthBackGestureRecognizer)
    }
    
    func pushChild(_ childViewController: ChildFullSwipeViewController, isNeedToHideBars: Bool) {
        let vc = childViewController
        vc.fakeNavigationBarView.image = navigationController?.navigationBar.screenshot()
        vc.hidesBottomBarWhenPushed = isNeedToHideBars
        vc.isNeedToShowNavigationBar = !isNeedToHideBars
        pushViewController(vc, animated: true)
    }
}

open class ChildFullSwipeViewController: UIViewController {
    fileprivate let fakeNavigationBarView = UIImageView()
    
    open var isNeedToShowNavigationBar = true
    
    private var navigationBar: UINavigationBar! {
        navigationController?.navigationBar
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        addFakeNavigationBarView()
    }
    
    open func push(viewController: ChildFullSwipeViewController, isNeedToHideBars: Bool) {
        if isNeedToHideBars {
            fakeNavigationBarView.image = navigationController?.navigationBar.screenshot()
            navigationController?.navigationBar.alpha = 0
            fakeNavigationBarView.isHidden = false
        }
        
        (navigationController as? FullSwipeNavigationController)?.pushChild(viewController, isNeedToHideBars: isNeedToHideBars)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isNeedToShowNavigationBar {
            navigationController?.navigationBar.alpha = 0
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isNeedToShowNavigationBar {
            fakeNavigationBarView.isHidden = true
            navigationController?.navigationBar.alpha = 1
        }
    }
    
    private func addFakeNavigationBarView() {
        fakeNavigationBarView.contentMode = .scaleAspectFill
        fakeNavigationBarView.isHidden = true
        view.addSubview(fakeNavigationBarView)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        fakeNavigationBarView.frame = navigationBar.frame
        view.bringSubviewToFront(fakeNavigationBarView)
    }
}

extension UIView {
  func screenshot() -> UIImage {
    return UIGraphicsImageRenderer(size: bounds.size).image { _ in
      drawHierarchy(in: CGRect(origin: .zero, size: bounds.size), afterScreenUpdates: true)
    }
  }

}

extension FullSwipeNavigationController: UIGestureRecognizerDelegate {
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let isSystemSwipeToBackEnabled = interactivePopGestureRecognizer?.isEnabled == true
        let isThereStackedViewControllers = viewControllers.count > 1
        return isSystemSwipeToBackEnabled && isThereStackedViewControllers
    }
}

