//// NavigationExampleViewController.swift
// 
// Copyright (c) 2019 - Sygic a.s.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import SygicMaps
import SygicMapsKit


class NavigationExampleViewController: UIViewController, SYMKModulePresenter {
    
    var presentedModules = [SYMKModuleViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupInitializingActivityIndicator()
        
        
        RoutingHelper.shared.computeRoute(from: SYGeoCoordinate(latitude: 48.146211, longitude: 17.126587)!, to: SYGeoCoordinate(latitude: 48.166338, longitude: 17.150818)!) { [weak self] (testRoute) in
            
            let navigationModule = SYMKNavigationViewController(with: testRoute)
            self?.presentModule(navigationModule)
            
//            let previewPosition = SYSimulatorPositionSource()
//            SYPositioning.shared().dataSource = previewPosition
//            previewPosition.start()
        }
    }
    
    /// Just to see something while SDK is initializing and SYRoute computing
    private func setupInitializingActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.centerInSuperview()
        activityIndicator.startAnimating()
    }
}


// MARK: - Temporary Routing helper

class RoutingHelper: NSObject, SYRoutingDelegate {
    
    static let shared = RoutingHelper()
    
    private var routing: SYRouting?
    private var routeComputed: ((SYRoute)->())?
    
    private override init() {
        super.init()
    }
    
    /// Helper function to quick get SYRoute. (The route can be obtained form SYMKRoutingModule in the future)
    public func computeRoute(from: SYGeoCoordinate, to: SYGeoCoordinate, completion: @escaping (SYRoute)->()) {
        routeComputed = completion
        
        SYMKSdkManager.shared.initializeIfNeeded { [weak self] success in
            guard let self = self else { return }
            guard success else {
                self.showSDKInitError()
                return
            }
            
            let start = SYWaypoint(position: from, type: .start, name: "StartWP")
            let end = SYWaypoint(position: to, type: .end, name: "EndWP")
            
            let routing = SYRouting()
            routing.delegate = self
            routing.computeRoute(start, to: end, via: nil, with: nil)
            self.routing = routing
        }
    }
    
    func routing(_ routing: SYRouting, didComputePrimaryRoute route: SYRoute?) {
        if let route = route {
            routeComputed?(route)
            routeComputed = nil
        }
        routing.cancelComputing()
        self.routing = nil
    }
    
    private func showSDKInitError() {
        let errorAlert = UIAlertController.init(title: "Error init SDK", message: nil, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController?.present(errorAlert, animated: true, completion: nil)
    }
}

