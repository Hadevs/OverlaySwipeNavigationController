import UIKit

public class FullSwipeNavigationController: UINavigationController {
    public override func viewDidLoad() {
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

public class ChildFullSwipeViewController: UIViewController {
    fileprivate let fakeNavigationBarView = UIImageView()
    
    public var isNeedToShowNavigationBar = true
    
    private var navigationBar: UINavigationBar! {
        navigationController?.navigationBar
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addFakeNavigationBarView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isNeedToShowNavigationBar {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isNeedToShowNavigationBar {
            fakeNavigationBarView.isHidden = true
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    private func addFakeNavigationBarView() {
        fakeNavigationBarView.contentMode = .scaleAspectFill
        fakeNavigationBarView.isHidden = true
        view.addSubview(fakeNavigationBarView)
    }
    
    public override func viewDidLayoutSubviews() {
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
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let isSystemSwipeToBackEnabled = interactivePopGestureRecognizer?.isEnabled == true
        let isThereStackedViewControllers = viewControllers.count > 1
        return isSystemSwipeToBackEnabled && isThereStackedViewControllers
    }
}

