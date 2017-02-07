//
//  UIScrollView+KVPullToRefresh.swift
//  PullToRefresh
//
//  Created by Vu Van Khac on 2/6/17.
//  Copyright © 2017 Janle. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    private struct KVPullToRefreshObject {
        static var pullToRefreshView = "PullToRefreshView"
    }
    
    public private(set) var pullToRefreshView: KVPullToRefreshView? {
        get {
            return objc_getAssociatedObject(self, &KVPullToRefreshObject.pullToRefreshView) as? KVPullToRefreshView
        }
        
        set {
            if let unwrappedValue = newValue {
                self.willChangeValue(forKey: KVPullToRefreshObject.pullToRefreshView)
                objc_setAssociatedObject(self, &KVPullToRefreshObject.pullToRefreshView, unwrappedValue, .OBJC_ASSOCIATION_ASSIGN)
                self.didChangeValue(forKey: KVPullToRefreshObject.pullToRefreshView)
            }
        }
    }
    
    public var showsPullToRefresh: Bool {
        get {
            guard let pullToRefreshView = self.pullToRefreshView else {
                return false
            }
            
            return !pullToRefreshView.isHidden
        }
        
        set {
            guard let pullToRefreshView = self.pullToRefreshView else {
                return
            }
            
            pullToRefreshView.isHidden = !newValue
            
            if !newValue {
                if pullToRefreshView.observing {
                    self.removeObserver(pullToRefreshView, forKeyPath: "contentOffset")
                    self.removeObserver(pullToRefreshView, forKeyPath: "contentSize")
                    self.removeObserver(pullToRefreshView, forKeyPath: "frame")
                    pullToRefreshView.resetScrollViewContentInset()
                    pullToRefreshView.observing = false
                }
            } else {
                if !pullToRefreshView.observing {
                    self.addObserver(pullToRefreshView, forKeyPath: "contentOffset", options: .new, context: nil)
                    self.addObserver(pullToRefreshView, forKeyPath: "contentSize", options: .new, context: nil)
                    self.addObserver(pullToRefreshView, forKeyPath: "frame", options: .new, context: nil)
                    pullToRefreshView.observing = true
                    pullToRefreshView.frame = CGRect(x: 0, y: -60, width: self.bounds.size.width, height: 60)
                }
            }
        }
    }
    
    public func addPullToRefreshWithActionHandler(_ actionHandler: @escaping (_: Void) -> Void) {
        if self.pullToRefreshView == nil {
            let view = KVPullToRefreshView(frame: CGRect(x: 0, y: -60, width: self.bounds.size.width, height: 60))
            view.pullToRefreshHandler = actionHandler
            view.scrollView = self
            self.addSubview(view)
            view.originalTopInset = self.contentInset.top
            self.pullToRefreshView = view
            self.showsPullToRefresh = true
        }
    }
    
    public func triggerPullToRefresh() {
        self.pullToRefreshView?.state = .triggered
        self.pullToRefreshView?.startAnimating()
    }
    
}
