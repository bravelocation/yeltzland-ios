//
//  YeltzForumHelper.swift
//  yeltzland
//
//  Created by John Pollard on 16/10/2019.
//  Copyright © 2019 John Pollard. All rights reserved.
//

import Foundation
import WebKit

class YeltzForumHelper {
    
    // MARK: - Cookie handling methods
    func saveForumCookies(url: URL, webView: WKWebView) {
        if (self.isForumRequest(url: url)) {
            // If it's a logout, clear the cookies
            if (self.isLogoutRequest(url: url)) {
                self.saveCookieString("")
                print("COOKIES: Clearing cookies in logout \(url.absoluteString)")
                return
            }
            
            // Check the current cookies and save them if changed
            self.currentCookieString(webView: webView, completionHandler: {(currentCookieString) in
                if (currentCookieString.count > 0) {
                    guard let storedCookieString = self.storedCookieString() else {
                        return
                    }
                    
                    if (currentCookieString.elementsEqual(storedCookieString) == false) {
                        self.saveCookieString(currentCookieString)
                        print("COOKIES: Saving cookies to storage: \(currentCookieString) for \(url.absoluteString)")
                    }
                }
            })
        }
    }
    
    func addForumCookies(request: NSMutableURLRequest) {
        if let url = request.url {
            if (self.isForumRequest(url: url) == true && self.isLoginRequest(url: url) == false && self.isLogoutRequest(url: url) == false) {
                guard let cookieString = self.storedCookieString() else {
                    return
                }
                
                if (cookieString.count > 0) {
                    request.addValue(cookieString, forHTTPHeaderField: "Cookie")
                    print("COOKIES: Adding cookies from storage: \(cookieString) for \(url.absoluteString)")
                }
            }
        }
    }
    
    func cookiesAvailableAndMissing(url: URL, webView: WKWebView, completionHandler: @escaping (_ result: Bool) -> Void) {
        if (self.isForumRequest(url: url) && self.isLoginRequest(url: url) == false && self.isLogoutRequest(url: url) == false) {
            self.currentCookieString(webView: webView, completionHandler: {(currentCookieString) in
                guard let storedCookieString = self.storedCookieString() else {
                    completionHandler(false)
                    return
                }
                
                if (storedCookieString.count > 0 && currentCookieString.count == 0) {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            })
        } else {
            completionHandler(false)
        }
    }

    // MARK: - Private functions
    private func isForumRequest(url: URL) -> Bool {
        if let host = url.host {
            return host.contains("yeltz.co.uk")
        }
        
        return false
    }

    private func isLoginRequest(url: URL) -> Bool {
        let result = url.absoluteString.contains("ucp.php?mode=login")
        
        if (result) {
            print("COOKIES: Detected Login request:  \(url.absoluteString)")
        }
        
        return result
    }

    private func isLogoutRequest(url: URL) -> Bool {
        let result = url.absoluteString.contains("index.php?sid=")
        
        if (result) {
            print("COOKIES: Detected Logout request:  \(url.absoluteString)")
        }
        
        return result
    }

    private func currentCookieString(webView: WKWebView, completionHandler: @escaping (_ cookieString: String) -> Void) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies() { cookies in
            var cookieString = ""
            
            for cookie in cookies {
                if (cookie.domain.contains("yeltz.co.uk") && cookie.name.starts(with: "phpbb3_")) {
                    // If user not logged in, return empty string
                    if (cookie.name == "phpbb3_qkcy3_u" && cookie.value == "1") {
                        completionHandler("")
                        return
                    } else if (cookie.name == "phpbb3_qkcy3_k" && cookie.value == "") {
                        completionHandler("")
                        return
                    }
                    
                    cookieString += cookie.name + "=" + cookie.value + ";"
                }
            }
            
            completionHandler(cookieString)
        }
    }
    
    private func saveCookieString(_ cookieString: String) {
        print("COOKIES: Saving cookie string \(cookieString)")
        GameSettings.shared.forumCookies = cookieString
    }
    
    private func storedCookieString() -> String? {
        // Retrieve the values from storage
        return GameSettings.shared.forumCookies
    }
}
