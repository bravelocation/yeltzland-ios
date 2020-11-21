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
    
    private var homePageUrl: URL!
    
    var homeUrl: URL! {
        get {
            return self.homePageUrl
        }
    }
    
    private var _navElement: NavigationElement?
    var navigationElement: NavigationElement? {
        get {
            return self._navElement
        }
        set {
            self._navElement = newValue
            
            switch self._navElement?.type {
            case .link(let url):
                self.homePageUrl = url
                self.pageTitle = self._navElement?.title
            default:
                break
            }
        }
    }
    
    private var pageTitle: String!
    
    var homeButton: UIBarButtonItem!
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    var reloadButton: UIBarButtonItem!
    var shareButton: UIBarButtonItem!
    
    let progressBar = UIProgressView(progressViewStyle: .bar)
    var spinner: UIActivityIndicatorView!
    
    var webView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupWebView()
        self.setupNavigationBar()

        self.view.backgroundColor = AppColors.systemBackground
    }
    
    private func setupWebView() {
        // Calculate position on screen of elements
        let progressBarHeight = CGFloat(2.0)
        
        var barHeight: CGFloat = 0.0

        if #available(iOS 13, *) {
            barHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0
        } else {
            barHeight = UIApplication.shared.statusBarFrame.height
        }
        
        let topPosition = (self.navigationController?.navigationBar.frame.size.height)! + barHeight
        
        var webViewHeight = view.frame.height - (topPosition + progressBarHeight)
        if let tabController = self.tabBarController {
            webViewHeight -= tabController.tabBar.frame.height
        }
        
        // Setting configuration based on LinhT_24 comment in https://forums.developer.apple.com/thread/99674
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Use a single process pool for all web views
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.processPool = appDelegate.processPool
        
        // Make sure web view uses default data store
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()

        // Set web view to correct size before adding to view
        self.webView = WKWebView(frame: CGRect(x: 0, y: topPosition + progressBarHeight, width: view.frame.width, height: webViewHeight), configuration: webConfiguration)

        self.webView?.navigationDelegate = self
        self.webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.progressBar.frame = CGRect(x: 0, y: topPosition, width: view.frame.width, height: progressBarHeight)
        self.progressBar.alpha = 0
        self.progressBar.tintColor = UIColor(named: "yeltz-blue")
        self.progressBar.autoresizingMask = .flexibleWidth
        
        self.view.addSubview(self.progressBar)
        self.view.addSubview(self.webView!)
        
        // Swipe gestures automatically supported
        self.webView?.allowsBackForwardNavigationGestures = true
        
        // Add pull to refresh
        #if !targetEnvironment(macCatalyst)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControl.Event.valueChanged)
        self.webView?.scrollView.addSubview(refreshControl)
        #endif
        
        self.webView?.scrollView.bounces = true
        
        self.loadHomePage()
    }
    
    private func setupNavigationBar() {
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
    }
    
    // MARK: - Pull to refresh
    #if !targetEnvironment(macCatalyst)
    @objc
    func refreshWebView(_ sender: UIRefreshControl) {
        // Give haptic feedback
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
        
        self.reloadButtonTouchUp()
        sender.endRefreshing()
    }
    #endif
    
    // MARK: - Keyboard options
    override var keyCommands: [UIKeyCommand]? {
         if #available(iOS 13.0, *) {
            return [
                UIKeyCommand(title: "Forward", action: #selector(WebPageViewController.forwardButtonTouchUp), input: "]", modifierFlags: .command),
                UIKeyCommand(title: "Back", action: #selector(WebPageViewController.backButtonTouchUp), input: "[", modifierFlags: .command),
                UIKeyCommand(title: "Reload", action: #selector(WebPageViewController.reloadButtonTouchUp), input: "R", modifierFlags: .command),
                UIKeyCommand(title: "Home", action: #selector(WebPageViewController.loadHomePage), input: "H", modifierFlags: [.command, .shift])
            ]
         } else {
            return [
                UIKeyCommand(input: "]", modifierFlags: .command, action: #selector(WebPageViewController.forwardButtonTouchUp), discoverabilityTitle: "Forward"),
                UIKeyCommand(input: "[", modifierFlags: .command, action: #selector(WebPageViewController.backButtonTouchUp), discoverabilityTitle: "Back"),
                UIKeyCommand(input: "R", modifierFlags: .command, action: #selector(WebPageViewController.reloadButtonTouchUp), discoverabilityTitle: "Reload"),
                UIKeyCommand(input: "H", modifierFlags: [.command, .shift], action: #selector(WebPageViewController.loadHomePage), discoverabilityTitle: "Home")
            ]
        }
    }
    
    // MARK: - Nav bar actions
    @objc func reloadButtonTouchUp() {
        self.progressBar.setProgress(0, animated: false)
        self.webView?.reloadFromOrigin()
    }
    
    @objc func backButtonTouchUp() {
        self.webView?.goBack()
    }
    
    @objc func forwardButtonTouchUp() {
        self.webView?.goForward()
    }
    
    @objc func loadHomePage() {
        self.webView?.stopLoading()
        progressBar.setProgress(0, animated: false)
        
        if let requestUrl = self.homeUrl {
            let req = URLRequest(url: requestUrl)
            self.webView?.load(req)
            print("Loading home page:", requestUrl)
        }
    }
    
    func loadPage(_ requestUrl: URL) {
        self.webView?.stopLoading()
        progressBar.setProgress(0, animated: false)
        
        let req = URLRequest(url: requestUrl)
        self.webView?.load(req)

        print("Loading page:", requestUrl)
    }
    
    @objc func shareButtonTouchUp() {
        if let requestUrl = self.webView?.url {
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
