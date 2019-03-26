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
    
    public var titleLabelFont: UIFont = UIFont.boldSystemFont(ofSize: 14) {
        didSet {
            titleLabel.font = titleLabelFont
        }
    }
    
    public var subtitleLabelFont: UIFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            subtitleLabel.font = subtitleLabelFont
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 210, height: 20))
        titleLabel.backgroundColor = .clear
        titleLabel.font = titleLabelFont
        titleLabel.textColor = titleTextColor
        addSubview(titleLabel)
        
        return titleLabel
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 210, height: 20))
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.font = subtitleLabelFont
        subtitleLabel.textColor = subtitleTextColor
        addSubview(subtitleLabel)
        
        return subtitleLabel
    }()
    
    public var activityIndicatorViewColor: UIColor {
        get {
            guard let color = activityIndicatorView.color else {
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
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
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
            setNeedsLayout()
            layoutIfNeeded()
            
            switch state {
            case .stopped:
                resetScrollViewContentInset()
                
            case .triggered:
                break
                
            case .loading:
                setScrollViewContentInsetForLoading()
                if previousState == .triggered && pullToRefreshHandler != nil {
                    pullToRefreshHandler?()
                }
            }
        }
    }
    
    lazy var arrow: KVPullToRefreshArrow = {
        let arrow = KVPullToRefreshArrow(frame: CGRect(x: 0, y: bounds.size.height - 54, width: 22, height: 48))
        arrow.backgroundColor = .clear
        addSubview(arrow)
        
        return arrow
    }()
    
    private var titles: [String] = [String]()
    private var subtitles: [String] = [String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .flexibleWidth
        titles = ["Pull to refresh", "Release to refresh", "Loading..."]
        subtitles = ["", "", ""]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if superview != nil && newSuperview == nil {
            if let scrollView = superview as? UIScrollView {
                if scrollView.showsPullToRefresh, observing {
                    scrollView.removeObserver(self, forKeyPath: "contentOffset")
                    scrollView.removeObserver(self, forKeyPath: "contentSize")
                    scrollView.removeObserver(self, forKeyPath: "frame")
                    observing = false
                }
            }
        }
    }
    
    public override func layoutSubviews() {
        switch state {
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
        let marginX: CGFloat = 16
        let marginY: CGFloat = 5
        
        titleLabel.text = titles[state.rawValue]
        let subtitle = subtitles[state.rawValue]
        subtitleLabel.text = subtitle.count > 0 ? subtitle : nil
        
        let titleSize: CGSize = titleLabel.intrinsicContentSize
        let subtitleSize: CGSize = subtitleLabel.intrinsicContentSize
        
        let maxLabelWidth: CGFloat = max(titleSize.width, subtitleSize.width)
        var totalMaxWidth: CGFloat = 0
        if maxLabelWidth > 0 {
            totalMaxWidth = leftViewWidth + marginX + maxLabelWidth
        } else {
            totalMaxWidth = leftViewWidth + maxLabelWidth
        }
        
        let labelX = (bounds.size.width / 2.0) - (totalMaxWidth / 2.0) + leftViewWidth + marginX
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
        
        let arrowX: CGFloat = (bounds.size.width / 2.0) - (totalMaxWidth / 2.0) + (leftViewWidth - arrow.bounds.size.width) / 2.0
        arrow.frame = CGRect(x: arrowX, y: (bounds.size.height / 2.0) - (arrow.bounds.size.height / 2.0), width: arrow.bounds.size.width, height: arrow.bounds.size.height)
        activityIndicatorView.center = arrow.center
    }
    
    public func setTitle(_ title: String, forState state: KVState) {
        titles[state.rawValue] = title
        setNeedsLayout()
    }
    
    public func setSubtitle(_ subtitle: String, forState state: KVState) {
        subtitles[state.rawValue] = subtitle
        setNeedsLayout()
    }
    
    public func startAnimating() {
        guard let scrollView = scrollView else {
            return
        }
        
        if abs(scrollView.contentOffset.y) < CGFloat.ulpOfOne {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: -frame.size.height), animated: true)
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
            if let scrollView = self.scrollView {
                scrollView.contentInset = contentInset
            }
        }, completion: nil)
    }
    
    func rotateArrow(_ degrees: Float, hide: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
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
            offset = min(offset, originalTopInset + bounds.size.height)
            let contentInset: UIEdgeInsets = scrollView.contentInset
            scrollView.contentInset = UIEdgeInsets(top: offset, left: contentInset.left, bottom: contentInset.bottom, right: contentInset.right)
        }
    }
}
