//
//  UIScrollView+KVInfiniteScrolling.swift
//  KVRefreshable
//
//  Created by Vu Van Khac on 1/24/17.
//  Copyright © 2017 Janle. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    private struct KVInfiniteScrollingObject {
        static var infiniteScrollingView    = "InfiniteScrollingView"
        static var showsInfiniteScrolling   = "isShowsInfiniteScrolling"
    }
    
    public private(set) var infiniteScrollingView: KVInfiniteScrollingView? {
        get {
            return objc_getAssociatedObject(self, &KVInfiniteScrollingObject.infiniteScrollingView) as? KVInfiniteScrollingView
        }
        
        set {
            if let unwrappedValue = newValue {
                objc_setAssociatedObject(self, &KVInfiniteScrollingObject.infiniteScrollingView, unwrappedValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    public var showsInfiniteScrolling: Bool {
        get {
            if let isShowsInfiniteScrolling = objc_getAssociatedObject(self, &KVInfiniteScrollingObject.showsInfiniteScrolling) as? Bool {
                return isShowsInfiniteScrolling
            } else {
                return false
            }
        }
        
        set {
            if newValue == false {
                if self.infiniteScrollingView?.observing == true {
                    self.removeObserver(self.infiniteScrollingView!, forKeyPath: "contentOffset")
                    self.removeObserver(self.infiniteScrollingView!, forKeyPath: "contentSize")
                    self.infiniteScrollingView?.resetScrollViewContentInset()
                    self.infiniteScrollingView?.observing = false
                }
            } else {
                if self.infiniteScrollingView?.observing == false {
                    self.addObserver(self.infiniteScrollingView!, forKeyPath: "contentOffset", options: .new, context: nil)
                    self.addObserver(self.infiniteScrollingView!, forKeyPath: "contentSize", options: .new, context: nil)
                    self.infiniteScrollingView?.setScrollViewContentInsetForInfiniteScrolling()
                    self.infiniteScrollingView?.observing = true
                    self.infiniteScrollingView?.setNeedsLayout()
                }
            }
            
            objc_setAssociatedObject(self, &KVInfiniteScrollingObject.showsInfiniteScrolling, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func addInfiniteScrollingWithActionHandler(_ actionHandler: @escaping (_: Void) -> Void) {
        if self.infiniteScrollingView == nil {
            let view = KVInfiniteScrollingView(frame: CGRect(x: 0, y: self.contentSize.height, width: self.bounds.size.width, height: 60))
            view.infiniteScrollingHandler = actionHandler
            view.scrollView = self
            self.addSubview(view)
            view.originalBottomInset = self.contentInset.bottom
            self.infiniteScrollingView = view
            self.showsInfiniteScrolling = true
        }
    }
    
    public func triggerInfiniteScrolling() {
        self.infiniteScrollingView?.state = .triggered
        self.infiniteScrollingView?.startAnimating()
    }
    
}
