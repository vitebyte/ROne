//
//  BaseWebViewController.swift
//  DigitalEcoSystem
//
//  Created by Shafi Ahmed on 06/03/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit

class BaseWebViewController: BaseViewController, UIWebViewDelegate {

    var backArrow: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webView: UIWebView!

    // MARK: View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.backgroundColor = UIColor.clear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupScreenUI()
        activityIndicator.startAnimating()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        activityIndicator.stopAnimating()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    // MARK: Helper Methods
    public func setupScreenUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "sGroup"), style: .plain, target: self, action: #selector(backButtonPressed))
        webView.backgroundColor = UIColor.clear
    }

    func setupWebViewWithUrl(url: String) {
        let URL: NSURL = NSURL(string: url)!
        let request: NSURLRequest = NSURLRequest(url: URL as URL)
        self.webView.delegate = self
        self.webView.scrollView.showsVerticalScrollIndicator = false
        self.webView.scrollView.showsHorizontalScrollIndicator = false
        self.webView.loadRequest(request as URLRequest)
        activityIndicator.isHidden = true
        UIApplication.shared.beginIgnoringInteractionEvents()
    }

    // MARK: UIWebViewDelegate
    @objc(webViewDidStartLoad:) func webViewDidStartLoad(_: UIWebView) {
        UIApplication.shared.endIgnoringInteractionEvents()
        Helper.showLoader()
    }

    func webViewDidFinishLoad(_: UIWebView) {
        Helper.hideLoader()
    }

    func webView(_: UIWebView, didFailLoadWithError _: Error) {
        activityIndicator.stopAnimating()
        
        showAlertViewWithMessage(LocalizedString.shared.ERROR_TITLE, message: LocalizedString.shared.LOADING_ERROR,true)
    }
}
