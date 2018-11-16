//
//  TestWKWebViewController.swift
//  Native&H5Interaction
//
//  Created by Migu on 2018/11/15.
//  Copyright © 2018 VIctorChee. All rights reserved.
//

import UIKit
import WebKit

class TestWKWebViewController: UIViewController {
    var webview: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let userContent = WKUserContentController()
        userContent.add(self, name: "JSCallNative")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContent
        webview = WKWebView(frame: CGRect.zero, configuration: configuration)
        view.addSubview(webview)
        webview.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webview]|", options: .alignAllCenterX, metrics: nil, views: ["webview": webview]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[webview]|", options: .alignAllCenterX, metrics: nil, views: ["webview": webview]))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let url = Bundle.main.url(forResource: "index", withExtension: "html") else { return }
        webview.load(URLRequest(url: url))
    }
}

extension TestWKWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js = "nativeCallJS(123);"
        webView.evaluateJavaScript(js) { (script, error) in
            print(error ?? script ?? "")
        }
    }
}

extension TestWKWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "JSCallNative" {
            // Support Type: NSNumber，String，Date，Array，Dictionary，NSNull
            guard let body = message.body as? String else { return }
            print(body)
        }
    }
}
