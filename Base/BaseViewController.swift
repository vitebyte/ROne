//
//  BaseViewController.swift
//  DigitalEcoSystem
//
//  Created by Shafi Ahmed on 06/03/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import Foundation
import UIKit

open class BaseViewController: UIViewController {

    // to know which viewcontroller to present from settings
    var tableviewcellTapped: Bool = false

    fileprivate var tapGesture: UITapGestureRecognizer?

    // MARK: View Lifecycle
    open override func viewDidLoad() {
        super.viewDidLoad()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeTapGesture()
        dismissKeyboard()
        NotificationCenter.default.removeObserver(self)
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Helper Methods
    public func addLeftBarButton(withImageName imageName: String) {
        if navigationController != nil {
            var image = UIImage(named: imageName)
            image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(BaseViewController.leftButtonPressed(_:)))
        }
    }

    public func addRightBarButton(withImageName imageName: String) {
        if navigationController != nil {
            var image = UIImage(named: imageName)
            image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(BaseViewController.rightButtonAction(_:)))
        }
    }

    public func setNavBarTitle(_ title: String) {
        navigationController?.navigationItem.title = title
    }

    // MARK: - NavigationBar Appearance
    public func navigationBarAppearanceBlack(navController: UINavigationController) {

        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.none)

        navController.isNavigationBarHidden = false
        navController.navigationBar.barTintColor = UIColor.black

        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.gothamBook(17),
        ]

        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = false
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)

        setStatusBarLightColor(true)
    }

    public func navigationBarAppearanceWhite(navController: UINavigationController) {

        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.none)

        navController.isNavigationBarHidden = false
        navController.navigationBar.barTintColor = UIColor.white

        navController.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.black,
            NSFontAttributeName: UIFont.gothamBook(17),
        ]

        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)

        setStatusBarLightColor(false)
    }

    // MARK: - Private Methods
    fileprivate func addTapGesture() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        view.addGestureRecognizer(tapGesture!)
    }

    fileprivate func removeTapGesture() {
        if tapGesture != nil {
            view.removeGestureRecognizer(tapGesture!)
            tapGesture = nil
        }
    }

    fileprivate func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Control Actions
    func backButtonPressed() {
        _ = navigationController?.popViewController(animated: true)
    }

    func closeButtonPressed() {
        _ = dismiss(animated: true, completion: nil)
    }

    func leftButtonPressed(_: UIButton) {
        // Override in respective class
    }

    func rightButtonAction(_: UIButton) {
        // Override in respective class
        // self.moveToSettingsViewController()
    }

    // MARK: - Gesture Actions
    func handleGesture(_: UITapGestureRecognizer) {
        dismissKeyboard()
    }

    // MARK: - Keyboard Notification Observers
    func keyboardWillShow(_: Notification) {
        addTapGesture()
    }

    func keyboardWillHide(_: Notification) {
        removeTapGesture()
    }

    func tabBarIsVisible() -> Bool {
        return (tabBarController?.tabBar.frame.origin.y)! < view.frame.maxY
    }

    // MARK: - IBActions
    @IBAction func menuButtonAction(_: AnyObject) {
        // menu button action is to be defined here
        // moveToSettingsViewController()
    }
}

// MARK: - PopOver Presentation Methods

extension BaseViewController: UIPopoverPresentationControllerDelegate {

    func moveToSettingsViewController() {
        let storyboard = UIStoryboard.mainStoryboard()
        let controller = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.SettingsViewControllerIdentifier) as! SettingsViewController
        controller.modalPresentationStyle = UIModalPresentationStyle.popover
        let popoverPresentationController = controller.popoverPresentationController
        popoverPresentationController?.delegate = self
        // result is an optional (but should not be nil if modalPresentationStyle is popover)
        if let _popoverPresentationController = popoverPresentationController {
            // set the view from which to pop up
            _popoverPresentationController.sourceView = view
            controller.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            let navBar = UINavigationController(rootViewController: controller)
            navigationController?.present(navBar, animated: true, completion: nil)
        }
    }
}
