//
//  ViewController.swift
//  Texarkana College iOS
//
//  Created by Cory Lowry on 7/3/21.
//

import UIKit
import WebKit
import GoogleMobileAds

class ViewController: UIViewController, WKNavigationDelegate {
    
    lazy var bannerView: GADBannerView! = GADBannerView(adSize: kGADAdSizeBanner)
    
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-4546055219731501/7993421653"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        let url = URL(string: "https://www.texarkanacollege.edu")
        webView.load(URLRequest(url: url!))
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: view.safeAreaLayoutGuide,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0),
            
            ])
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        addBannerViewToView(bannerView)
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    @IBAction func backButton(_ sender: Any) {
        
        if webView.canGoBack {
            webView.goBack()
        }
        else {
            self.navigationController!.popViewController(animated:true)
        }
    }
    @IBAction func refreshButton(_ sender: Any) {
        webView?.reload()
    }
}

