/**
 
 Copyright (c) 2017 Vu Van Khac <khacvv0451@gmail.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

import UIKit

extension UIScrollView {
    
    private struct KVPullToRefreshObject {
        static var pullToRefreshView = "PullToRefreshView"
    }
    
    public private(set) var pullToRefreshView: KVPullToRefreshView {
        get {
            if let pullToRefreshView = objc_getAssociatedObject(self, &KVPullToRefreshObject.pullToRefreshView) as? KVPullToRefreshView {
                return pullToRefreshView
            } else {
                let pullToRefreshView = KVPullToRefreshView(frame: CGRect(x: 0, y: -60, width: bounds.size.width, height: 60))
                objc_setAssociatedObject(self, &KVPullToRefreshObject.pullToRefreshView, pullToRefreshView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return pullToRefreshView
            }
        }
        
        set {
            willChangeValue(forKey: KVPullToRefreshObject.pullToRefreshView)
            objc_setAssociatedObject(self, &KVPullToRefreshObject.pullToRefreshView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            didChangeValue(forKey: KVPullToRefreshObject.pullToRefreshView)
        }
    }
    
    public var showsPullToRefresh: Bool {
        get {
            return pullToRefreshView.isHidden
        }
        
        set {
            pullToRefreshView.isHidden = !newValue
            
            if newValue {
                if !pullToRefreshView.observing {
                    addObserver(pullToRefreshView, forKeyPath: "contentOffset", options: .new, context: nil)
                    addObserver(pullToRefreshView, forKeyPath: "contentSize", options: .new, context: nil)
                    addObserver(pullToRefreshView, forKeyPath: "frame", options: .new, context: nil)
                    pullToRefreshView.frame = CGRect(x: 0, y: -60, width: bounds.size.width, height: 60)
                    pullToRefreshView.observing = true
                }
            } else {
                if pullToRefreshView.observing {
                    removeObserver(pullToRefreshView, forKeyPath: "contentOffset")
                    removeObserver(pullToRefreshView, forKeyPath: "contentSize")
                    removeObserver(pullToRefreshView, forKeyPath: "frame")
                    pullToRefreshView.resetScrollViewContentInset()
                    pullToRefreshView.observing = false
                }
            }
        }
    }
    
    public func addPullToRefreshWithActionHandler(_ actionHandler: @escaping () -> Void, withConfig config: () -> Void) {
        pullToRefreshView.pullToRefreshHandler = actionHandler
        pullToRefreshView.scrollView = self
        pullToRefreshView.originalTopInset = contentInset.top
        addSubview(pullToRefreshView)
        showsPullToRefresh = true
        
        config()
    }
    
    public func triggerPullToRefresh() {
        pullToRefreshView.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.pullToRefreshView.alpha = 1.0
        }
        
        pullToRefreshView.isFirstTrigger = true
        pullToRefreshView.state = .triggered
        pullToRefreshView.startAnimating()
    }
}
