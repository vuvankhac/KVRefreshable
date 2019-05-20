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

public class KVInfiniteScrollingView: UIView {

    var infiniteScrollingHandler: (() -> Void)?
    
    weak var scrollView: UIScrollView?
    var originalBottomInset: CGFloat = 0.0
    var enabled: Bool = true
    var observing: Bool = false
    
    public var activityIndicatorViewColor: UIColor {
        get {
            guard let color = self.activityIndicatorView.color else {
                return .gray
            }
            
            return color
        }
        
        set {
            activityIndicatorView.color = newValue
        }
    }
    
    public var activityIndicatorViewStyle: UIActivityIndicatorView.Style {
        get {
            return activityIndicatorView.style
        }
        
        set {
            activityIndicatorView.style = newValue
        }
    }
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.hidesWhenStopped = true
        addSubview(activityIndicatorView)
        
        return activityIndicatorView
    }()
    
    var previousState: KVState = .stopped
    var state: KVState = .stopped {
        willSet {
            previousState = state
        }
        
        didSet {
            let origin = CGPoint(x: (bounds.size.width - activityIndicatorView.bounds.size.width) / 2.0, y: (bounds.size.height - activityIndicatorView.bounds.size.height) / 2.0)
            activityIndicatorView.frame = CGRect(x: origin.x, y: origin.y, width: activityIndicatorView.bounds.size.width, height: activityIndicatorView.bounds.size.height)
            
            switch state {
            case .stopped:
                activityIndicatorView.stopAnimating()
                
            case .triggered:
                activityIndicatorView.startAnimating()
                
            case .loading:
                activityIndicatorView.startAnimating()
            }
            
            if previousState == .triggered && state == .loading && enabled && infiniteScrollingHandler != nil {
                if let scrollView = scrollView, scrollView.showsInfiniteScrolling {
                    infiniteScrollingHandler?()
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .flexibleWidth
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startAnimating() {
        state = .loading
    }
    
    public func stopAnimating() {
        state = .stopped
    }
    
    override public func willMove(toSuperview newSuperview: UIView?) {
        if superview != nil && newSuperview == nil {
            if let scrollView = superview as? UIScrollView {
                if scrollView.showsInfiniteScrolling {
                    if observing {
                        scrollView.removeObserver(self, forKeyPath: "contentOffset")
                        scrollView.removeObserver(self, forKeyPath: "contentSize")
                        observing = false
                    }
                }
            }
        }
    }
    
    override public func layoutSubviews() {
        activityIndicatorView.center = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
    }
    
    func resetScrollViewContentInset() {
        guard let scrollView = scrollView else {
            return
        }
        
        var currentInsets = scrollView.contentInset
        currentInsets.bottom = originalBottomInset
        setScrollViewContentInset(currentInsets)
    }
    
    func setScrollViewContentInsetForInfiniteScrolling() {
        guard let scrollView = scrollView else {
            return
        }
        
        var currentInsets = scrollView.contentInset
        currentInsets.bottom = originalBottomInset + 60
        setScrollViewContentInset(currentInsets)
    }
    
    func setScrollViewContentInset(_ contentInset: UIEdgeInsets) {
        guard let scrollView = scrollView else {
            return
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {() -> Void in
            scrollView.contentInset = contentInset
        }, completion: nil)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let contentOffset = change?[.newKey] as? CGPoint {
                scrollViewDidScroll(contentOffset)
            }
        } else if keyPath == "contentSize" {
            layoutSubviews()
            if let scrollView = scrollView {
                frame = CGRect(x: 0, y: scrollView.contentSize.height, width: bounds.size.width, height: 60)
            }
        }
    }
    
    func scrollViewDidScroll(_ contentOffset: CGPoint) {
        if state != .loading && enabled {
            if let scrollView = scrollView {
                let scrollOffsetThreshold: CGFloat = scrollView.contentSize.height - scrollView.bounds.size.height
                if scrollView.isDragging && state == .triggered {
                    state = .loading
                } else if contentOffset.y > scrollOffsetThreshold && state == .stopped && scrollView.isDragging {
                    state = .triggered
                } else if contentOffset.y < scrollOffsetThreshold && state != .stopped {
                    state = .stopped
                }
            }
        }
    }
}
