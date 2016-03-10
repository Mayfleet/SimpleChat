//
// Created by Maxim Pervushin on 10/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    // MARK: LogInViewController @IB

    @IBOutlet weak var userNameTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var containerToBottomLayoutConstraint: NSLayoutConstraint?

    @IBAction func closeButtonAction(sender: AnyObject) {
        onClose?()
    }

    @IBAction func logInButtonAction(sender: AnyObject) {
    }

    @IBAction func forgotPasswordButtonAction(sender: AnyObject) {
    }

    @IBAction func tapGestureRecognizerAction(sender: AnyObject) {
        if userNameTextField?.isFirstResponder() == true {
            userNameTextField?.resignFirstResponder()
        } else if passwordTextField?.isFirstResponder() == true {
            passwordTextField?.resignFirstResponder()
        }
    }

    // MARK: LogInViewController

    var onClose: (Void -> Void)?

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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let signUpViewController = segue.destinationViewController as? SignUpViewController {
            signUpViewController.onClose = {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}
