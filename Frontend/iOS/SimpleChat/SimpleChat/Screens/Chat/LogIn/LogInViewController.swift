//
// Created by Maxim Pervushin on 10/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    // MARK: LogInViewController @IB

    @IBOutlet weak var usernameTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var containerToBottomLayoutConstraint: NSLayoutConstraint?

    @IBAction func closeButtonAction(sender: AnyObject) {
        didClose?()
    }

    @IBAction func logInButtonAction(sender: AnyObject) {
        didLogIn?(username: usernameTextField?.text, password: passwordTextField?.text)
    }

    @IBAction func signUpButtonAction(sender: AnyObject) {
        signUpButtonAction?()
    }

    @IBAction func forgotPasswordButtonAction(sender: AnyObject) {
    }

    @IBAction func tapGestureRecognizerAction(sender: AnyObject) {
        if usernameTextField?.isFirstResponder() == true {
            usernameTextField?.resignFirstResponder()
        } else if passwordTextField?.isFirstResponder() == true {
            passwordTextField?.resignFirstResponder()
        }
    }

    // MARK: LogInViewController

    var didClose: (Void -> Void)?
    var didLogIn: ((username: String?, password: String?) -> Void)?
    var signUpButtonAction: (Void -> Void)?

    private func keyboardWillChangeFrameNotification(notification: NSNotification) {
        guard let
        viewHeight = view?.bounds.size.height,
        frameEnd = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue(),
        animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval else {
            return
        }

        view.layoutIfNeeded()
        UIView.animateWithDuration(animationDuration) {
            () -> Void in
            self.containerToBottomLayoutConstraint?.constant = viewHeight - frameEnd.origin.y
            self.view.layoutIfNeeded()
        }
    }

    private func subscribe() {
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillChangeFrameNotification, object: nil, queue: nil, usingBlock: keyboardWillChangeFrameNotification)
    }

    private func unsubscribe() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribe()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribe()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if traitCollection.horizontalSizeClass == .Compact {
            return [.Portrait]
        }
        return [.All]
    }
}
