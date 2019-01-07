//
//  KVPullToRefreshView.swift
//  PullToRefresh
//
//  Created by Vu Van Khac on 2/6/17.
//  Copyright © 2017 Janle. All rights reserved.
//

import UIKit

public class KVPullToRefreshView: UIView {

    var pullToRefreshHandler: (() -> Void)?
    
    weak var scrollView: UIScrollView?
    var originalTopInset: CGFloat = 0
    var wasTriggeredByUser: Bool = true
    var showsPullToRefresh: Bool = true
    var observing: Bool = false
    var isFirstTrigger: Bool = false
    
    public var arrowColor: UIColor = .gray {
        didSet {
            arrow.arrowColor = arrowColor
        }
    }
    
    public var titleTextColor: UIColor = .darkGray {
        didSet {
            titleLabel.textColor = titleTextColor
        }
    }
    
    public var subtitleTextColor: UIColor = .darkGray {
        didSet {
            subtitleLabel.textColor = subtitleTextColor
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 210, height: 20))
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = self.titleTextColor
        self.addSubview(titleLabel)
        
        return titleLabel
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 210, height: 20))
        subtitleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.textColor = self.subtitleTextColor
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
    
    public var activityIndicatorViewStyle: UIActivityIndicatorView.Style {
        get {
            return self.activityIndicatorView.style
        }
        
        set {
            self.activityIndicatorView.style = newValue
        }
    }
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
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
    
    lazy var arrow: KVPullToRefreshArrow = {
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
        titles = ["Pull to refresh", "Release to refresh", "Loading..."]
        subtitles = ["", "", ""]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if (self.superview != nil) && newSuperview == nil {
            if let scrollView = self.superview as? UIScrollView, scrollView.showsPullToRefresh {
                if observing {
                    scrollView.removeObserver(self, forKeyPath: "contentOffset")
                    scrollView.removeObserver(self, forKeyPath: "contentSize")
                    scrollView.removeObserver(self, forKeyPath: "frame")
                    observing = false
                }
            }
            
        }
    }
    
    public override func layoutSubviews() {
        switch self.state {
        case .stopped:
            activityIndicatorView.stopAnimating()
            rotateArrow(0, hide: false)
            
        case .triggered:
            rotateArrow(Float.pi, hide: false)
            
        case .loading:
            activityIndicatorView.startAnimating()
            rotateArrow(0, hide: true)
        }
        
        let leftViewWidth: CGFloat = max(arrow.bounds.size.width, activityIndicatorView.bounds.size.width)
        let margin: CGFloat = 10
        let marginY: CGFloat = 2
        
        titleLabel.text = titles[state.value()]
        let subtitle = subtitles[state.value()]
        self.subtitleLabel.text = subtitle.count > 0 ? subtitle : nil
        
        let titleSize: CGSize = titleLabel.intrinsicContentSize
        let subtitleSize: CGSize = subtitleLabel.intrinsicContentSize
        
        let maxLabelWidth: CGFloat = max(titleSize.width, subtitleSize.width)
        var totalMaxWidth: CGFloat = 0
        if maxLabelWidth > 0 {
            totalMaxWidth = leftViewWidth + margin + maxLabelWidth
        } else {
            totalMaxWidth = leftViewWidth + maxLabelWidth
        }
        
        let labelX = (bounds.size.width / 2.0) - (totalMaxWidth / 2.0) + leftViewWidth + margin
        if subtitleSize.height > 0 {
            let totalHeight = titleSize.height + subtitleSize.height + marginY
            let minY = (bounds.size.height / 2.0) - (totalHeight / 2.0)
            
            let titleY = minY
            titleLabel.frame = CGRect(x: labelX, y: titleY, width: titleSize.width, height: titleSize.height).integral
            subtitleLabel.frame = CGRect(x: labelX, y: titleY + titleSize.height + marginY, width: subtitleSize.width, height: subtitleSize.height).integral
        } else {
            let totalHeight: CGFloat = titleSize.height
            let minY: CGFloat = (bounds.size.height / 2.0) - (totalHeight / 2.0)
            
            let titleY = minY
            titleLabel.frame = CGRect(x: labelX, y: titleY, width: titleSize.width, height: titleSize.height)
            subtitleLabel.frame = CGRect(x: labelX, y: titleY + titleSize.height + marginY, width: subtitleSize.width, height: subtitleSize.height)
        }
        
        let arrowX: CGFloat = (self.bounds.size.width / 2.0) - (totalMaxWidth / 2.0) + (leftViewWidth - arrow.bounds.size.width) / 2.0
        self.arrow.frame = CGRect(x: arrowX, y: (self.bounds.size.height / 2.0) - (arrow.bounds.size.height / 2.0), width: arrow.bounds.size.width, height: arrow.bounds.size.height)
        activityIndicatorView.center = arrow.center
    }
    
    public func setTitle(_ title: String, forState state: KVState) {
        titles[state.value()] = title
        setNeedsLayout()
    }
    
    public func setSubtitle(_ subtitle: String, forState state: KVState) {
        subtitles[state.value()] = subtitle
        self.setNeedsLayout()
    }
    
    public func startAnimating() {
        guard let scrollView = scrollView else {
            return
        }
        
        if abs(scrollView.contentOffset.y) < CGFloat.ulpOfOne {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: -self.frame.size.height), animated: true)
            wasTriggeredByUser = false
        } else {
            wasTriggeredByUser = true
        }
    }
    
    public func stopAnimating() {
        guard let scrollView = scrollView else {
            return
        }
        
        state = .stopped
        if !wasTriggeredByUser {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: -originalTopInset), animated: true)
        }
    }
    
    func resetScrollViewContentInset() {
        guard let scrollView = scrollView else {
            return
        }
        
        var currentInsets = scrollView.contentInset
        currentInsets.top = originalTopInset
        setScrollViewContentInset(currentInsets)
    }
    
    func setScrollViewContentInsetForLoading() {
        guard let scrollView = scrollView else {
            return
        }
        
        let offset: CGFloat = max(-scrollView.contentOffset.y, 0)
        var currentInsets = scrollView.contentInset
        currentInsets.top = min(offset, originalTopInset + bounds.size.height)
        setScrollViewContentInset(currentInsets)
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
                if (self.isFirstTrigger) {
                    self.isFirstTrigger = false
                } else {
                    self.arrow.layer.opacity = 1
                }
            }
        }, completion: nil)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let contentOffset = change?[.newKey] as? CGPoint {
                scrollViewDidScroll(contentOffset)
            }
        } else if keyPath == "contentSize" {
            layoutSubviews()
            frame = CGRect(x: 0, y: -60, width: self.bounds.size.width, height: 60)
        } else if keyPath == "frame" {
            layoutSubviews()
        }
    }
    
    func scrollViewDidScroll(_ contentOffset: CGPoint) {
        if state != .loading {
            let scrollOffsetThreshold: CGFloat = frame.origin.y - originalTopInset;
            if let scrollView = scrollView, !scrollView.isDragging && state == .triggered {
                state = .loading
            } else if let scrollView = scrollView, scrollView.isDragging && contentOffset.y < scrollOffsetThreshold {
                state = .triggered
            } else if contentOffset.y >= scrollOffsetThreshold && state != .stopped {
                state = .stopped
            }
        } else {
            guard let scrollView = scrollView else {
                return
            }
            
            var offset: CGFloat = max(-scrollView.contentOffset.y, 0)
            offset = min(offset, originalTopInset + self.bounds.size.height)
            let contentInset: UIEdgeInsets = scrollView.contentInset
            scrollView.contentInset = UIEdgeInsets(top: offset, left: contentInset.left, bottom: contentInset.bottom, right: contentInset.right)
        }
    }
}
