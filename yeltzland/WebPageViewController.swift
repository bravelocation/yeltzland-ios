//
//  ViewController.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import WebKit
import Font_Awesome_Swift

class WebPageViewController: UIViewController, WKNavigationDelegate {
    
    static let UrlNotification:String = "YLZUrlNotification"
    
    var homePageUrl: NSURL!
    
    var homeUrl: NSURL! {
        set {
            self.homePageUrl = newValue;
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
    
    // reference to WebView control we will instantiate
    let webView = WKWebView()
    let progressBar = UIProgressView(progressViewStyle: .Bar)
    var spinner: UIActivityIndicatorView!

    // Initializers
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setupNotificationWatchers()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.loadHomePage()
        self.setupNotificationWatchers()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("Removed notification handler for fixture updates in today view")
    }
    
    private func setupNotificationWatchers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WebPageViewController.enterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)

    }
    
    @objc private func enterForeground(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.reloadButtonTouchUp()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Calculate position on screen of elements
        let progressBarHeight = CGFloat(2.0)
        let topPosition = (self.navigationController?.navigationBar.frame.size.height)! + CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame)
        
        let webViewHeight = CGRectGetHeight(view.frame) -
            (topPosition + progressBarHeight + CGRectGetHeight((self.tabBarController?.tabBar.frame)!));

        // Add elements to view
        self.webView.frame = CGRect(x: 0, y: topPosition + progressBarHeight, width: view.frame.width, height: webViewHeight)
        self.webView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.webView.navigationDelegate = self
        
        self.progressBar.frame = CGRect(x: 0, y: topPosition, width: view.frame.width, height: progressBarHeight)
        self.progressBar.alpha = 0
        self.progressBar.tintColor = AppColors.ProgressBar
        self.progressBar.autoresizingMask = .FlexibleWidth
        
        self.view.addSubview(self.progressBar)
        self.view.addSubview(self.webView)
        self.view.backgroundColor = AppColors.WebBackground
        
        // Setup navigation
        self.navigationItem.title = self.pageTitle
        
        self.reloadButton = UIBarButtonItem(
            barButtonSystemItem:.Refresh,
            target: self,
            action: #selector(WebPageViewController.reloadButtonTouchUp)
        )
        
        self.homeButton = UIBarButtonItem(
            title: "Home",
            style: .Plain,
            target: self,
            action: #selector(WebPageViewController.loadHomePage)
        )
        self.homeButton.FAIcon = FAType.FAHome
        
        self.backButton = UIBarButtonItem(
            title: "Back",
            style: .Plain,
            target: self,
            action: #selector(WebPageViewController.backButtonTouchUp)
        )
        self.backButton.FAIcon = FAType.FAAngleLeft
        
        self.forwardButton = UIBarButtonItem(
            title: "Forward",
            style: .Plain,
            target: self,
            action: #selector(WebPageViewController.forwardButtonTouchUp)
        )
        self.forwardButton.FAIcon = FAType.FAAngleRight
        
        self.shareButton = UIBarButtonItem(
            barButtonSystemItem:.Action,
            target: self,
            action: #selector(WebPageViewController.shareButtonTouchUp)
        )

        self.backButton.enabled = false
        self.forwardButton.enabled = false
        
        self.navigationItem.leftBarButtonItems = [self.homeButton, self.backButton, self.forwardButton]
        self.navigationItem.rightBarButtonItems = [self.shareButton, self.reloadButton]
        
        // Setup colors
        self.backButton.tintColor = AppColors.NavBarTintColor
        self.forwardButton.tintColor = AppColors.NavBarTintColor
        self.reloadButton.tintColor = AppColors.NavBarTintColor
        self.homeButton.tintColor = AppColors.NavBarTintColor
        self.shareButton.tintColor = AppColors.NavBarTintColor
        
        // Swipe gestures automatically supported
        self.webView.allowsBackForwardNavigationGestures = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadButtonTouchUp()
    }
    
    // MARK: - Nav bar actions
    func reloadButtonTouchUp() {
        progressBar.setProgress(0, animated: false)
        self.webView.reloadFromOrigin()
    }
    
    func backButtonTouchUp() {
        self.webView.goBack()
    }
    
    func forwardButtonTouchUp() {
        self.webView.goForward()
    }
    
    func loadHomePage() {
        self.webView.stopLoading()
        progressBar.setProgress(0, animated: false)
        
        if let requestUrl = self.homeUrl {
            let req = NSURLRequest(URL: requestUrl)
            self.webView.loadRequest(req)
            print("Loading page: %@", self.homeUrl)
        }
    }
    
    func loadPage(requestUrl: NSURL) {
        self.webView.stopLoading()
        progressBar.setProgress(0, animated: false)
        
        let req = NSURLRequest(URL: requestUrl)
        self.webView.loadRequest(req)
        print("Loading page: %@", requestUrl)
    }
    
    func shareButtonTouchUp() {
        if let requestUrl = self.webView.URL {
            let objectsToShare = [requestUrl]

            // Add custom activities as appropriate
            let safariActivity = SafariActivity(currentUrl: requestUrl)
            let chromeActivity = ChromeActivity(currentUrl: requestUrl)
            
            var customActivities:[UIActivity] = [safariActivity]
            if (chromeActivity.canOpenChrome()) {
                customActivities.append(chromeActivity);
            }
            
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: customActivities)
            
            if (activityViewController.popoverPresentationController != nil) {
                activityViewController.popoverPresentationController!.barButtonItem = self.shareButton;
            }
            
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    func showSpinner() {
        if (self.spinner != nil) {
            self.hideSpinner()
        }
        
        let overlayPosition = CGRectMake(0, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height)
        self.spinner = UIActivityIndicatorView(frame:overlayPosition)
        self.spinner.color = AppColors.SpinnerColor
        self.view.addSubview(self.spinner)
        self.spinner.startAnimating()
    }
    
    func hideSpinner() {
        if (self.spinner != nil) {
            self.spinner.stopAnimating()
            self.spinner.removeFromSuperview()
            self.spinner = nil;
        }
    }
    
    // MARK: - WKNavigationDelegate methods
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        // Show brief error message
        if (error.code != NSURLErrorCancelled) {
            print("didFailProvisionalNavigation error occurred: ", error.localizedDescription, ":", error.code)
            MakeToast.Show(self.view, message: "Couldn't connect to the website right now")
            self.hideSpinner()
        }
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        self.showSpinner()
        self.progressBar.setProgress(0, animated: false)
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 1 }, completion: nil)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation){
        if (webView.estimatedProgress > 0) {
           self.hideSpinner()
        }
        progressBar.setProgress(Float(webView.estimatedProgress), animated: true)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation) {
        // Mark the progress as done
        self.hideSpinner()

        progressBar.setProgress(1, animated: true)
        UIView.animateWithDuration(0.3, delay: 1, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 0 }, completion: nil)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        self.backButton.enabled = webView.canGoBack
        self.forwardButton.enabled = webView.canGoForward
        
        // Post notification message that URL has been updated
        NSNotificationCenter.defaultCenter().postNotificationName(WebPageViewController.UrlNotification, object: nil)

    }
    
    func webView(webView: WKWebView, navigation: WKNavigation, withError error: NSError) {
        // Mark the progress as done
        self.hideSpinner()
        progressBar.setProgress(1, animated: true)
        UIView.animateWithDuration(0.3, delay: 1, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 0 }, completion: nil)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        // Show brief error message
        if (error.code != NSURLErrorCancelled) {
            print("Navigation error occurred: ", error.localizedDescription)
            MakeToast.Show(self.view, message: "Couldn't connect to the website right now")
            self.hideSpinner()
        }
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.targetFrame == nil) {
            print("Redirecting link to another frame: \(navigationAction.request.URL!)")
            webView.loadRequest(navigationAction.request)
        }
        
        decisionHandler(WKNavigationActionPolicy.Allow)
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        
        // This is supposed to flush the cookies to storage!
        NSUserDefaults.standardUserDefaults().synchronize()
            
        decisionHandler(.Allow)
    }
}

