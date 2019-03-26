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
    
    private struct KVInfiniteScrollingObject {
        static var infiniteScrollingView    = "InfiniteScrollingView"
        static var showsInfiniteScrolling   = "isShowsInfiniteScrolling"
    }
    
    public private(set) var infiniteScrollingView: KVInfiniteScrollingView {
        get {
            if let infiniteScrollingView = objc_getAssociatedObject(self, &KVInfiniteScrollingObject.infiniteScrollingView) as? KVInfiniteScrollingView {
                return infiniteScrollingView
            } else {
                let infiniteScrollingView = KVInfiniteScrollingView(frame: CGRect(x: 0, y: contentSize.height, width: bounds.size.width, height: 60))
                objc_setAssociatedObject(self, &KVInfiniteScrollingObject.infiniteScrollingView, infiniteScrollingView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return infiniteScrollingView
            }
        }
        
        set {
            objc_setAssociatedObject(self, &KVInfiniteScrollingObject.infiniteScrollingView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
            if newValue {
                addObserver(infiniteScrollingView, forKeyPath: "contentOffset", options: .new, context: nil)
                addObserver(infiniteScrollingView, forKeyPath: "contentSize", options: .new, context: nil)
                infiniteScrollingView.setScrollViewContentInsetForInfiniteScrolling()
                infiniteScrollingView.observing = true
                infiniteScrollingView.setNeedsLayout()
            } else {
                if infiniteScrollingView.observing {
                    removeObserver(infiniteScrollingView, forKeyPath: "contentOffset")
                    removeObserver(infiniteScrollingView, forKeyPath: "contentSize")
                    infiniteScrollingView.resetScrollViewContentInset()
                    infiniteScrollingView.observing = false
                }
            }
            
            objc_setAssociatedObject(self, &KVInfiniteScrollingObject.showsInfiniteScrolling, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func addInfiniteScrollingWithActionHandler(_ actionHandler: @escaping () -> Void) {
        infiniteScrollingView.infiniteScrollingHandler = actionHandler
        infiniteScrollingView.scrollView = self
        infiniteScrollingView.originalBottomInset = contentInset.bottom
        addSubview(infiniteScrollingView)
        showsInfiniteScrolling = true
    }
    
    public func triggerInfiniteScrolling() {
        infiniteScrollingView.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.infiniteScrollingView.alpha = 1.0
        }
        
        infiniteScrollingView.state = .triggered
        infiniteScrollingView.startAnimating()
    }
}
