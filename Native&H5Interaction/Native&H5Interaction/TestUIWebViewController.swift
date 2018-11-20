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
    var valueFromNative: Int { get set }
    func JSCallNative(_ value: String)
}

class TestUIWebViewController: UIViewController {
    private var webview: UIWebView!
    fileprivate var jsContext: JSContext?
    fileprivate var value = 1984

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
        // Old Way: Intercept all request then filtrate for target request
        if let scheme = request.url?.scheme, scheme == "oldway" {
            print(request.url?.absoluteString ?? "")
            return false
        }
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // Call JS
        let js = "nativeCallJS('[Old Way]Message from native');"
        let result = webView.stringByEvaluatingJavaScript(from: js)
        print(result ?? "")
        
        // -----------⬆︎Old Way-----⬇︎New Way----------
        
        // JS Context in JavaScriptCore framework
        jsContext = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
        jsContext?.exceptionHandler = { context, exception in
            context?.exception = exception
            print(exception ?? "")
        }
        
        // Call JS
        let _ = jsContext?.objectForKeyedSubscript("nativeCallJS")?.call(withArguments: ["[New Way]Message from native"])
        
        // Call native from JS
        // 1. JSExport
        jsContext?.setObject(self, forKeyedSubscript: "native" as NSCopying & NSObjectProtocol)
        // 1. Block
        let log: @convention(block) (String) -> Void = { input in
            print(input)
//            let arguments = JSContext.currentArguments()
//            print(arguments ?? "")
        }
        jsContext?.setObject(log, forKeyedSubscript: "log" as NSCopying & NSObjectProtocol)
    }
}

extension TestUIWebViewController: TestJSExports {
    var valueFromNative: Int {
        get {
            return value
        }
        set {
            value = newValue
        }
    }
    
    func JSCallNative(_ value: String) {
        print(value)
    }
}
