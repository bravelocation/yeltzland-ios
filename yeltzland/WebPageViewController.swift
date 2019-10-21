//
//  ViewController.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import WebKit

class WebPageViewController: UIViewController, WKNavigationDelegate {
    
    static let UrlNotification: String = "YLZUrlNotification"
    
    var homePageUrl: URL!
    
    var homeUrl: URL! {
        set {
            self.homePageUrl = newValue
            self.loadHomePage()
        }
        get {
            return self.homePageUrl
        }
    }
    
    var pageTitle: String!
    var homeButton: UIBarButtonItem!
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    var reloadButton: UIBarButtonItem!
    var shareButton: UIBarButtonItem!
    
    let progressBar = UIProgressView(progressViewStyle: .bar)
    var spinner: UIActivityIndicatorView!
    
    lazy var webView: WKWebView = {
        // Setting configuration based on LinhT_24 comment in https://forums.developer.apple.com/thread/99674
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Use a single process pool for all web views
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.processPool = appDelegate.processPool

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        
        return webView
    }()

    // Initializers
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.loadHomePage()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Calculate position on screen of elements
        let progressBarHeight = CGFloat(2.0)
        let topPosition = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.height
        
        let webViewHeight = view.frame.height -
            (topPosition + progressBarHeight + (self.tabBarController?.tabBar.frame)!.height)

        // Add elements to view
        self.webView.frame = CGRect(x: 0, y: topPosition + progressBarHeight, width: view.frame.width, height: webViewHeight)
        self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.webView.navigationDelegate = self
        
        // Make sure web view uses default data store
        self.webView.configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        self.progressBar.frame = CGRect(x: 0, y: topPosition, width: view.frame.width, height: progressBarHeight)
        self.progressBar.alpha = 0
        self.progressBar.tintColor = UIColor(named: "yeltz-blue")
        self.progressBar.autoresizingMask = .flexibleWidth
        
        self.view.addSubview(self.progressBar)
        self.view.addSubview(self.webView)
        self.view.backgroundColor = AppColors.systemBackground
        
        // Setup navigation
        self.navigationItem.title = self.pageTitle
        
        self.reloadButton = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(WebPageViewController.reloadButtonTouchUp)
        )
        
        self.homeButton = UIBarButtonItem(
            title: "Home",
            style: .plain,
            target: self,
            action: #selector(WebPageViewController.loadHomePage)
        )
        self.homeButton.image = AppImages.home
        
        self.backButton = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(WebPageViewController.backButtonTouchUp)
        )
        self.backButton.image = AppImages.chevronLeft
        
        self.forwardButton = UIBarButtonItem(
            title: "Forward",
            style: .plain,
            target: self,
            action: #selector(WebPageViewController.forwardButtonTouchUp)
        )
        self.forwardButton.image = AppImages.chevronRight
        
        self.shareButton = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(WebPageViewController.shareButtonTouchUp)
        )

        self.backButton.isEnabled = false
        self.forwardButton.isEnabled = false
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        
        self.navigationItem.leftBarButtonItems = [self.homeButton, self.backButton, self.forwardButton, spacer]
        self.navigationItem.rightBarButtonItems = [self.shareButton, self.reloadButton, spacer]
        
        // Setup colors
        self.backButton.tintColor = UIColor.white
        self.forwardButton.tintColor = UIColor.white
        self.reloadButton.tintColor = UIColor.white
        self.homeButton.tintColor = UIColor.white
        self.shareButton.tintColor = UIColor.white
        
        // Swipe gestures automatically supported
        self.webView.allowsBackForwardNavigationGestures = true
        
        // Add pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControl.Event.valueChanged)
        self.webView.scrollView.addSubview(refreshControl)
        self.webView.scrollView.bounces = true
    }
    
    // MARK: - Pull to refresh
    @objc
    func refreshWebView(_ sender: UIRefreshControl) {
        // Give haptic feedback
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
        
        self.reloadButtonTouchUp()
        sender.endRefreshing()
    }
    
    // MARK: - Keyboard options
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: .command, action: #selector(WebPageViewController.forwardButtonTouchUp), discoverabilityTitle: "Forward"),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: .command, action: #selector(WebPageViewController.backButtonTouchUp), discoverabilityTitle: "Back"),
            UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(WebPageViewController.reloadButtonTouchUp), discoverabilityTitle: "Reload"),
            UIKeyCommand(input: "h", modifierFlags: [.command, .shift], action: #selector(WebPageViewController.loadHomePage), discoverabilityTitle: "Home")
        ]
    }
    
    // MARK: - Nav bar actions
    @objc func reloadButtonTouchUp() {
        self.progressBar.setProgress(0, animated: false)
        self.webView.reloadFromOrigin()
    }
    
    @objc func backButtonTouchUp() {
        self.webView.goBack()
    }
    
    @objc func forwardButtonTouchUp() {
        self.webView.goForward()
    }
    
    @objc func loadHomePage() {
        self.webView.stopLoading()
        progressBar.setProgress(0, animated: false)
        
        if let requestUrl = self.homeUrl {
            let req = URLRequest(url: requestUrl)
            self.webView.load(req)
            print("Loading home page:", requestUrl)
        }
    }
    
    func loadPage(_ requestUrl: URL) {
        self.webView.stopLoading()
        progressBar.setProgress(0, animated: false)
        
        let req = URLRequest(url: requestUrl)
        self.webView.load(req)

        print("Loading page:", requestUrl)
    }
    
    @objc func shareButtonTouchUp() {
        if let requestUrl = self.webView.url {
            let objectsToShare = [requestUrl]

            // Add custom activities as appropriate
            let safariActivity = SafariActivity(currentUrl: requestUrl)
            let chromeActivity = ChromeActivity(currentUrl: requestUrl)
            
            var customActivities: [UIActivity] = [safariActivity]
            if (chromeActivity.canOpenChrome()) {
                customActivities.append(chromeActivity)
            }
            
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: customActivities)
            
            if (activityViewController.popoverPresentationController != nil) {
                activityViewController.popoverPresentationController!.barButtonItem = self.shareButton
            }
            
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Spinner methods
    private func showSpinner() {
        if (self.spinner != nil) {
            self.hideSpinner()
        }
        
        let overlayPosition = CGRect(x: 0, y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        self.spinner = UIActivityIndicatorView(frame: overlayPosition)
        self.spinner.color = UIColor(named: "yeltz-blue")
        self.view.addSubview(self.spinner)
        self.spinner.startAnimating()
    }
    
    private func hideSpinner() {
        if (self.spinner != nil) {
            self.spinner.stopAnimating()
            self.spinner.removeFromSuperview()
            self.spinner = nil
        }
    }
    
    // MARK: - WKNavigationDelegate methods
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.hideSpinner()
            
            // Show brief error message
            let navigationError = error as NSError
            if (navigationError.code != NSURLErrorCancelled) {
                print("didFailProvisionalNavigation error occurred: ", error.localizedDescription, ":", navigationError.code)
                MakeToast.show(self, title: "A problem occured", message: "Couldn't connect to the website right now")
            }
        })
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.showSpinner()
            self.progressBar.setProgress(0, animated: false)
            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions(), animations: { self.progressBar.alpha = 1 }, completion: nil)
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        })
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation) {
        DispatchQueue.main.async(execute: { () -> Void in
            if (webView.estimatedProgress > 0) {
               self.hideSpinner()
            }
            
            self.progressBar.setProgress(Float(webView.estimatedProgress), animated: true)
        })
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        // Mark the progress as done
        DispatchQueue.main.async(execute: { () -> Void in
            self.hideSpinner()

            self.progressBar.setProgress(1, animated: true)
            UIView.animate(withDuration: 0.3, delay: 1, options: UIView.AnimationOptions(), animations: { self.progressBar.alpha = 0 }, completion: nil)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            self.backButton.isEnabled = webView.canGoBack
            self.forwardButton.isEnabled = webView.canGoForward
            
            // Post notification message that URL has been updated
            NotificationCenter.default.post(name: Notification.Name(rawValue: WebPageViewController.UrlNotification), object: nil)
        })
    }
    
    @objc(webView:didFailNavigation:withError:) func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        // Mark the progress as done
        DispatchQueue.main.async(execute: { () -> Void in
            self.hideSpinner()
            self.progressBar.setProgress(1, animated: true)
            UIView.animate(withDuration: 0.3, delay: 1, options: UIView.AnimationOptions(), animations: { self.progressBar.alpha = 0 }, completion: nil)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            // Show brief error message
            let navigationError = error as NSError
            if (navigationError.code != NSURLErrorCancelled) {
                print("Navigation error occurred: ", navigationError.localizedDescription)
                MakeToast.show(self, title: "A problem occurred", message: "Couldn't connect to the website right now")
            }
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        DispatchQueue.main.async(execute: { () -> Void in
            var externalUrl: URL? = nil
            
            // Open new frame redirects in Safari
            if (navigationAction.targetFrame == nil) {
                print("Redirecting link to another frame: \(navigationAction.request.url!)")
                externalUrl = navigationAction.request.url!
            }
            
            // Do we have a non-standard URL?
            if let safariUrl = externalUrl {
                if(UIApplication.shared.canOpenURL(safariUrl)) {
                    UIApplication.shared.open(safariUrl, options: [:], completionHandler: nil)
                }
                
                decisionHandler(WKNavigationActionPolicy.cancel)
            } else {
                decisionHandler(WKNavigationActionPolicy.allow)
            }
        })
    }
}
