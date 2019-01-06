//
//  KVInfiniteScrollingView.swift
//  KVRefreshable
//
//  Created by Vu Van Khac on 1/24/17.
//  Copyright © 2017 Janle. All rights reserved.
//

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
            self.activityIndicatorView.color = newValue
        }
    }
    
    public var activityIndicatorViewStyle: UIActivityIndicatorView.Style {
        get {
            return self.activityIndicatorView.style
        }
        
        set {
            self.activityIndicatorView.style = newValue
        }
    }
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
        
        return activityIndicatorView
    }()
    
    var previousState: KVState = .stopped
    var state: KVState = .stopped {
        willSet {
            self.previousState = self.state
        }
        
        didSet {
            let viewBounds = self.activityIndicatorView.bounds
            let origin = CGPoint(x: (self.bounds.size.width - viewBounds.size.width) / 2, y: (self.bounds.size.height - viewBounds.size.height) / 2)
            self.activityIndicatorView.frame = CGRect(x: origin.x, y: origin.y, width: viewBounds.size.width, height: viewBounds.size.height)
            
            switch self.state {
            case .stopped:
                self.activityIndicatorView.stopAnimating()
                
            case .triggered:
                self.activityIndicatorView.startAnimating()
                
            case .loading:
                self.activityIndicatorView.startAnimating()
            }
            
            if self.previousState == .triggered && self.state == .loading && (self.infiniteScrollingHandler != nil) && self.enabled == true {
                self.infiniteScrollingHandler?()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.autoresizingMask = .flexibleWidth
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startAnimating() {
        self.state = .loading
    }
    
    public func stopAnimating() {
        self.state = .stopped
    }
    
    override public func willMove(toSuperview newSuperview: UIView?) {
        if (self.superview != nil) && newSuperview == nil {
            let scrollView: UIScrollView? = (self.superview as? UIScrollView)
            if let showsInfiniteScrolling = scrollView?.showsInfiniteScrolling, showsInfiniteScrolling == true {
                if self.observing {
                    scrollView?.removeObserver(self, forKeyPath: "contentOffset")
                    scrollView?.removeObserver(self, forKeyPath: "contentSize")
                    self.observing = false
                }
            }
        }
    }
    
    override public func layoutSubviews() {
        self.activityIndicatorView.center = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
    }
    
    func resetScrollViewContentInset() {
        guard let scrollView = self.scrollView else {
            return
        }
        
        var currentInsets = scrollView.contentInset
        currentInsets.bottom = self.originalBottomInset
        self.setScrollViewContentInset(currentInsets)
    }
    
    func setScrollViewContentInsetForInfiniteScrolling() {
        guard let scrollView = self.scrollView else {
            return
        }
        
        var currentInsets = scrollView.contentInset
        currentInsets.bottom = self.originalBottomInset + 60
        self.setScrollViewContentInset(currentInsets)
    }
    
    func setScrollViewContentInset(_ contentInset: UIEdgeInsets) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {() -> Void in
            self.scrollView?.contentInset = contentInset
        }, completion: { _ in })
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let contentOffset = change?[.newKey] as? CGPoint {
                self.scrollViewDidScroll(contentOffset)
            }
        } else if keyPath == "contentSize" {
            self.layoutSubviews()
            self.frame = CGRect(x: 0, y: (self.scrollView?.contentSize.height)!, width: self.bounds.size.width, height: 60)
        }
    }
    
    func scrollViewDidScroll(_ contentOffset: CGPoint) {
        if self.state != .loading && self.enabled {
            let scrollViewContentHeight: CGFloat = (self.scrollView?.contentSize.height)!
            let scrollOffsetThreshold: CGFloat = scrollViewContentHeight - (self.scrollView?.bounds.size.height)!
            if self.scrollView?.isDragging == true && self.state == .triggered {
                self.state = .loading
            } else if contentOffset.y > scrollOffsetThreshold && self.state == .stopped && self.scrollView?.isDragging == true {
                self.state = .triggered
            } else if contentOffset.y < scrollOffsetThreshold && self.state != .stopped {
                self.state = .stopped
            }
        }
    }

}
