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
            guard let pullToRefreshView = pullToRefreshView else {
                return false
            }
            
            return !pullToRefreshView.isHidden
        }
        
        set {
            guard let pullToRefreshView = pullToRefreshView else {
                return
            }
            
            pullToRefreshView.isHidden = !newValue
            
            if !newValue {
                if pullToRefreshView.observing {
                    removeObserver(pullToRefreshView, forKeyPath: "contentOffset")
                    removeObserver(pullToRefreshView, forKeyPath: "contentSize")
                    removeObserver(pullToRefreshView, forKeyPath: "frame")
                    pullToRefreshView.resetScrollViewContentInset()
                    pullToRefreshView.observing = false
                }
            } else {
                if !pullToRefreshView.observing {
                    addObserver(pullToRefreshView, forKeyPath: "contentOffset", options: .new, context: nil)
                    addObserver(pullToRefreshView, forKeyPath: "contentSize", options: .new, context: nil)
                    addObserver(pullToRefreshView, forKeyPath: "frame", options: .new, context: nil)
                    pullToRefreshView.observing = true
                    pullToRefreshView.frame = CGRect(x: 0, y: -60, width: bounds.size.width, height: 60)
                }
            }
        }
    }
    
    public func addPullToRefreshWithActionHandler(_ actionHandler: @escaping () -> Void, withConfig: () -> Void) {
        if pullToRefreshView == nil {
            let view = KVPullToRefreshView(frame: CGRect(x: 0, y: -60, width: bounds.size.width, height: 60))
            view.pullToRefreshHandler = actionHandler
            view.scrollView = self
            view.originalTopInset = contentInset.top
            addSubview(view)
            pullToRefreshView = view
            showsPullToRefresh = true
        }
        
        withConfig()
    }
    
    public func triggerPullToRefresh() {
        let lastTitleTextColor = pullToRefreshView?.titleTextColor ?? .darkGray
        let lastSubtitleTextColor = pullToRefreshView?.subtitleTextColor ?? .darkGray
        let lastActivityIndicatorViewColor = pullToRefreshView?.activityIndicatorViewColor ?? .gray
        pullToRefreshView?.arrow.layer.opacity = 0
        pullToRefreshView?.titleTextColor = .clear
        pullToRefreshView?.subtitleTextColor = .clear
        pullToRefreshView?.activityIndicatorViewColor = .clear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.pullToRefreshView?.titleTextColor = lastTitleTextColor
            weakSelf.pullToRefreshView?.subtitleTextColor = lastSubtitleTextColor
            weakSelf.pullToRefreshView?.activityIndicatorViewColor = lastActivityIndicatorViewColor
        }
        
        pullToRefreshView?.isFirstTrigger = true
        pullToRefreshView?.state = .triggered
        pullToRefreshView?.startAnimating()
    }
}
