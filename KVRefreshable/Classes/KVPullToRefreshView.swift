//
//  KVPullToRefreshView.swift
//  PullToRefresh
//
//  Created by Vu Van Khac on 2/6/17.
//  Copyright © 2017 Janle. All rights reserved.
//

import UIKit

public class KVPullToRefreshView: UIView {

    var pullToRefreshHandler: ((_: Void) -> Void)?
    
    weak var scrollView: UIScrollView?
    var originalTopInset: CGFloat = 0
    var wasTriggeredByUser: Bool = true
    var showsPullToRefresh: Bool = true
    var observing: Bool = false
    
    public var arrowColor: UIColor = .gray
    public var textColor: UIColor = .darkGray
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 210, height: 20))
        titleLabel.text = "Pull to refresh..."
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = self.textColor
        self.addSubview(titleLabel)
        
        return titleLabel
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 210, height: 20))
        subtitleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.textColor = self.textColor
        self.addSubview(subtitleLabel)
        
        return subtitleLabel
    }()
    
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
    
    public var activityIndicatorViewStyle: UIActivityIndicatorViewStyle {
        get {
            return self.activityIndicatorView.activityIndicatorViewStyle
        }
        
        set {
            self.activityIndicatorView.activityIndicatorViewStyle = newValue
        }
    }
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
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
            self.setNeedsLayout()
            self.layoutIfNeeded()
            
            switch self.state {
            case .stopped:
                self.resetScrollViewContentInset()
                
            case .triggered:
                break
                
            case .loading:
                self.setScrollViewContentInsetForLoading()
                if self.previousState == .triggered && (self.pullToRefreshHandler != nil) {
                    self.pullToRefreshHandler?()
                }
            }
        }
    }
    
    private lazy var arrow: KVPullToRefreshArrow = {
        let arrow = KVPullToRefreshArrow(frame: CGRect(x: 0, y: self.bounds.size.height - 54, width: 22, height: 48))
        arrow.backgroundColor = .clear
        self.addSubview(arrow)
        
        return arrow
    }()
    
    private var titles: [String] = [String]()
    private var subtitles: [String] = [String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.autoresizingMask = .flexibleWidth
        self.titles = ["Release to refresh...", "Loading...", "Pull to refresh..."]
        self.subtitles = ["", "", ""]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if (self.superview != nil) && newSuperview == nil {
            if let scrollView = self.superview as? UIScrollView, scrollView.showsPullToRefresh {
                if self.observing {
                    scrollView.removeObserver(self, forKeyPath: "contentOffset")
                    scrollView.removeObserver(self, forKeyPath: "contentSize")
                    scrollView.removeObserver(self, forKeyPath: "frame")
                    self.observing = false
                }
            }
            
        }
    }
    
    public override func layoutSubviews() {
        switch self.state {
        case .stopped:
            self.arrow.alpha = 1
            self.activityIndicatorView.stopAnimating()
            self.rotateArrow(0, hide: false)
            
        case .triggered:
            self.rotateArrow(Float(M_PI), hide: false)
            
        case .loading:
            self.activityIndicatorView.startAnimating()
            self.rotateArrow(0, hide: true)
        }
        
        let leftViewWidth: CGFloat = max(self.arrow.bounds.size.width, self.activityIndicatorView.bounds.size.width)
        let margin: CGFloat = 10
        let marginY: CGFloat = 2
        
        self.titleLabel.text = self.titles[self.state.value()]
        let subtitle = self.subtitles[self.state.value()]
        self.subtitleLabel.text = subtitle.characters.count > 0 ? subtitle : nil
        
        let titleSize: CGSize = self.titleLabel.intrinsicContentSize
        let subtitleSize: CGSize = self.subtitleLabel.intrinsicContentSize
        
        let maxLabelWidth: CGFloat = max(titleSize.width, subtitleSize.width)
        var totalMaxWidth: CGFloat = 0
        if maxLabelWidth > 0 {
            totalMaxWidth = leftViewWidth + margin + maxLabelWidth
        } else {
            totalMaxWidth = leftViewWidth + maxLabelWidth
        }
        
        let labelX = (self.bounds.size.width / 2) - (totalMaxWidth / 2) + leftViewWidth + margin
        if subtitleSize.height > 0 {
            let totalHeight = titleSize.height + subtitleSize.height + marginY
            let minY = (self.bounds.size.height / 2) - (totalHeight / 2)
            
            let titleY = minY
            self.titleLabel.frame = CGRect(x: labelX, y: titleY, width: titleSize.width, height: titleSize.height).integral
            self.subtitleLabel.frame = CGRect(x: labelX, y: titleY + titleSize.height + marginY, width: subtitleSize.width, height: subtitleSize.height).integral
        } else {
            let totalHeight: CGFloat = titleSize.height
            let minY: CGFloat = (self.bounds.size.height / 2) - (totalHeight / 2)
            
            let titleY = minY
            self.titleLabel.frame = CGRect(x: labelX, y: titleY, width: titleSize.width, height: titleSize.height)
            self.subtitleLabel.frame = CGRect(x: labelX, y: titleY + titleSize.height + marginY, width: subtitleSize.width, height: subtitleSize.height)
        }
        
        let arrowX: CGFloat = (self.bounds.size.width / 2) - (totalMaxWidth / 2) + (leftViewWidth - self.arrow.bounds.size.width) / 2
        self.arrow.frame = CGRect(x: arrowX, y: (self.bounds.size.height / 2) - (self.arrow.bounds.size.height / 2), width: self.arrow.bounds.size.width, height: self.arrow.bounds.size.height)
        self.activityIndicatorView.center = self.arrow.center
    }
    
    public func setTitle(_ title: String, forState state: KVState) {
        self.titles[state.value()] = title
        self.setNeedsLayout()
    }
    
    public func setSubtitle(_ subtitle: String, forState state: KVState) {
        self.subtitles[state.value()] = subtitle
        self.setNeedsLayout()
    }
    
    public func startAnimating() {
        guard let scrollView = self.scrollView else {
            return
        }
        
        if fabs(scrollView.contentOffset.y) < CGFloat(FLT_EPSILON) {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: -self.frame.size.height), animated: true)
            self.wasTriggeredByUser = false
        } else {
            self.wasTriggeredByUser = true
        }
    }
    
    public func stopAnimating() {
        guard let scrollView = self.scrollView else {
            return
        }
        
        self.state = .stopped
        if !self.wasTriggeredByUser {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: -self.originalTopInset), animated: true)
        }
    }
    
    func resetScrollViewContentInset() {
        guard let scrollView = self.scrollView else {
            return
        }
        
        var currentInsets = scrollView.contentInset
        currentInsets.top = self.originalTopInset
        self.setScrollViewContentInset(currentInsets)
    }
    
    func setScrollViewContentInsetForLoading() {
        guard let scrollView = self.scrollView else {
            return
        }
        
        let offset: CGFloat = max(-scrollView.contentOffset.y, 0)
        var currentInsets = scrollView.contentInset
        currentInsets.top = min(offset, self.originalTopInset + self.bounds.size.height)
        self.setScrollViewContentInset(currentInsets)
    }
    
    func setScrollViewContentInset(_ contentInset: UIEdgeInsets) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { 
            self.scrollView?.contentInset = contentInset
        }, completion: nil)
    }
    
    func rotateArrow(_ degrees: Float, hide: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction, animations: {
            self.arrow.layer.transform = CATransform3DMakeRotation(CGFloat(degrees), 0, 0, 1)
            if hide {
                self.arrow.layer.opacity = 0
            } else {
                self.arrow.layer.opacity = 1
            }
        }, completion: nil)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let contentOffset = change?[.newKey] as? CGPoint {
                self.scrollViewDidScroll(contentOffset)
            }
        } else if keyPath == "contentSize" {
            self.layoutSubviews()
            self.frame = CGRect(x: 0, y: -60, width: self.bounds.size.width, height: 60)
        } else if keyPath == "frame" {
            self.layoutSubviews()
        }
    }
    
    func scrollViewDidScroll(_ contentOffset: CGPoint) {
        if self.state != .loading {
            let scrollOffsetThreshold: CGFloat = self.frame.origin.y - self.originalTopInset;
            
            if let scrollView = self.scrollView, !scrollView.isDragging && self.state == .triggered {
                self.state = .loading
            } else if let scrollView = self.scrollView, scrollView.isDragging && contentOffset.y < scrollOffsetThreshold {
                self.state = .triggered
            } else if contentOffset.y >= scrollOffsetThreshold && self.state != .stopped {
                self.state = .stopped
            }
        } else {
            guard let scrollView = self.scrollView else {
                return
            }
            
            var offset: CGFloat = max(-scrollView.contentOffset.y, 0)
            offset = min(offset, self.originalTopInset + self.bounds.size.height)
            let contentInset: UIEdgeInsets = scrollView.contentInset
            scrollView.contentInset = UIEdgeInsetsMake(offset, contentInset.left, contentInset.bottom, contentInset.right)
        }
    }
    
}
