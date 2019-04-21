//
//  ViewController.swift
//  WKWebViewSample
//
//  Created by 田辺信之 on 2019/04/22.
//  Copyright © 2019 田辺信之. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {
    @IBOutlet weak var containerView: UIView!
    var webView: WKWebView!
    
    @IBAction func tappedBackButton(_ sender: UIButton) {
        webView.goBack()
    }
    
    @IBAction func tappedForwardButton(_ sender: UIButton) {
        webView.goForward()
    }
    
    override func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), configuration: webConfiguration)
        webView.uiDelegate = self
        containerView.addSubview(webView)
        // 制約
        webView.topAnchor.constraint(equalToSystemSpacingBelow: containerView.topAnchor, multiplier: 0.0).isActive = true
        webView.bottomAnchor.constraint(equalToSystemSpacingBelow: containerView.bottomAnchor, multiplier: 0.0)
        webView.leadingAnchor.constraint(equalToSystemSpacingAfter: containerView.leadingAnchor, multiplier: 0.0)
        webView.trailingAnchor.constraint(equalToSystemSpacingAfter: containerView.trailingAnchor, multiplier: 0.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = URL(string: "https://www.apple.com") else { fatalError() }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

