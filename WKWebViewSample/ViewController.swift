//
//  ViewController.swift
//  WKWebViewSample
//
//  Created by 田辺信之 on 2019/04/22.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var headerView: UIView!
    var webView: WKWebView!
    private var _observers = [NSKeyValueObservation]()
    var progressView: UIProgressView!
    func setUpProgressView() {
        self.progressView = UIProgressView(frame: CGRect(
            x: 0,
            y: headerView.frame.maxY,
            width: self.view.frame.width,
            height: 3.0))
        self.progressView.progressViewStyle = .bar
        self.view.addSubview(self.progressView)
        _observers.append(self.webView.observe(\.estimatedProgress, options: .new, changeHandler: { (webView, change) in
            self.progressView.alpha = 1.0
            self.progressView.setProgress(Float(change.newValue!), animated: true)
            if self.webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3,
                               delay: 0.3,
                               options: [.curveEaseOut],
                               animations: { [weak self] in
                                self?.progressView.alpha = 0.0
                    }, completion: {_ in
                        self.progressView.setProgress(0.0, animated: false)
                })
            }
        })
        )
    }
    
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
        setUpProgressView()
        
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
        
        
        guard let url = URL(string: "https://google.co.jp") else { fatalError() }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        
        guard let url = navigationAction.request.url else {
            return nil
        }
        
        if url.absoluteString.range(of: "//itunes.apple.com/") != nil {
            if UIApplication.shared.responds(to: #selector(UIApplication.open(_:options:completionHandler:))) {
                UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: false], completionHandler: { (finished: Bool) in
                    
                })
            } else {
                UIApplication.shared.open(url)
                return nil
            }
        } else if !url.absoluteString.hasPrefix("http://") && !url.absoluteString.hasPrefix("https://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return nil
            }
        }
        
        // target="_blank"のリンクを開く
        guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
            webView.load(URLRequest(url: url))
            return nil
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        // alert対応
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        // confirm対応
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController  = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        let okHandler: () -> Void = {
            if let textField = alertController.textFields?.first {
                completionHandler(textField.text)
            } else {
                completionHandler("")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(nil)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            okHandler()
        }
        alertController.addTextField { $0.text = defaultText }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: WKNavigationDelegate {}

extension ViewController:  UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // webView.goBack()を優先したい
        return !webView.canGoBack
    }
}
