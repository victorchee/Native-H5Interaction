//
//  TestUIWebViewController.swift
//  Native&H5Interaction
//
//  Created by Migu on 2018/11/15.
//  Copyright © 2018 VIctorChee. All rights reserved.
//

import UIKit
import JavaScriptCore

@objc protocol TestJSExports: JSExport {
    var value: Int { get set }
    func JSCallNative(_ value: String)
}

class TestUIWebViewController: UIViewController {
    var webview: UIWebView!
    var jsContext: JSContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        webview = UIWebView()
        webview.delegate = self
        view.addSubview(webview)
        webview.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webview]|", options: .alignAllCenterX, metrics: nil, views: ["webview": webview]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[webview]|", options: .alignAllCenterX, metrics: nil, views: ["webview": webview]))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let url = Bundle.main.url(forResource: "index", withExtension: "html") else { return }
        webview.loadRequest(URLRequest(url: url))
    }
}

extension TestUIWebViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        // Old way: Intercept all request then filtrate for target request
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // Call JS
        let js = "messageFromNative(123);"
        let result = webView.stringByEvaluatingJavaScript(from: js)
        print(result ?? "")
        
        // -----------⬆︎Old Way-----⬇︎New Way----------
        
        // JS Context in JavaScriptCore framework
        jsContext = webView.value(forKeyPath: "documentView.webView.mainFrame.jsvaScriptContext") as? JSContext
        jsContext?.exceptionHandler = { context, exception in
            context?.exception = exception
            print(exception ?? "")
        }
        
        // Call JS
        let _ = jsContext?.objectForKeyedSubscript("nativeCallJS")?.call(withArguments: [2])
        
        // Call native from JS
        // 1. JSExport
        jsContext?.setObject(self, forKeyedSubscript: "native" as NSCopying & NSObjectProtocol)
        // 1. Block
        let log: @convention(block) (String) -> Void = { input in
            print(input)
        }
        jsContext?.setObject(unsafeBitCast(log, to: AnyObject.self), forKeyedSubscript: "log" as NSCopying & NSObjectProtocol)
    }
}

extension TestUIWebViewController: TestJSExports {
    var value: Int {
        get {
            return 1
        }
        set {
            
        }
    }
    
    func JSCallNative(_ value: String) {
        
    }
}
