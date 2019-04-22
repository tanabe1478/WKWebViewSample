//
//  ViewController.swift
//  WKWebViewSample
//
//  Created by 田辺信之 on 2019/04/22.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    @IBOutlet weak private var containerView: UIView!
    var webView: WKWebView!
    private var _observers = [NSKeyValueObservation]()
    @IBOutlet weak private var backButton: UIButton! {
        didSet {
            backButton.isEnabled = false
            backButton.alpha = 0.4
        }
    }
    @IBOutlet weak private var forwardButton: UIButton! {
        didSet {
            forwardButton.isEnabled = false
            forwardButton.alpha = 0.4
        }
    }
    
    @IBAction func tappedBackButton(_ sender: UIButton) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @IBAction func tappedForwardButton(_ sender: UIButton) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    @IBAction func tappedReloadButton(_ sender: Any) {
        webView.reload()
    }
    
    override func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        containerView.addSubview(webView)
        // 制約
        webView.topAnchor.constraint(equalToSystemSpacingBelow: containerView.topAnchor, multiplier: 0.0).isActive = true
        webView.bottomAnchor.constraint(equalToSystemSpacingBelow: containerView.bottomAnchor, multiplier: 0.0)
        webView.leadingAnchor.constraint(equalToSystemSpacingAfter: containerView.leadingAnchor, multiplier: 0.0)
        webView.trailingAnchor.constraint(equalToSystemSpacingAfter: containerView.trailingAnchor, multiplier: 0.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _observers.append(webView.observe(\.canGoBack, options: .new){ _, change in
            if let value = change.newValue {
                 DispatchQueue.main.async {
                    self.backButton.isEnabled = value
                    self.backButton.alpha = value ? 1.0 : 0.4
                }
            }
        })
        
        _observers.append(webView.observe(\.canGoForward, options: .new){ _, change in
            if let value = change.newValue {
                 DispatchQueue.main.async {
                self.forwardButton.isEnabled = value
                self.forwardButton.alpha = value ? 1.0 : 0.4
                }
            }
        })
        
        _observers.append(webView.observe(\.isLoading, options: .new) {_, change in
            if let value = change.newValue {
                DispatchQueue.main.async {
                    // isLoadingがtrueのときは更新できないようにしたい
                    self.reloadButton.isEnabled = !value
                    self.reloadButton.alpha = !value ? 1.0 : 0.4
                }
            }
        })
        
        _observers.append(webView.observe(\.title, options: .new) {_, change in
            if let value = change.newValue {
                DispatchQueue.main.async {
                    self.titleLabel.text = value
                }
            }
        })
        
        
        guard let url = URL(string: "https://www.apple.com") else { fatalError() }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

extension ViewController:  UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // webView.goBack()を優先したい
        return !webView.canGoBack
    }
}
