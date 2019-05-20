# KVRefreshable

[![CI Status](http://img.shields.io/travis/Vu Van Khac/KVRefreshable.svg?style=flat)](https://travis-ci.org/Vu Van Khac/KVRefreshable)
[![Version](https://img.shields.io/cocoapods/v/KVRefreshable.svg?style=flat)](http://cocoapods.org/pods/KVRefreshable)
[![License](https://img.shields.io/cocoapods/l/KVRefreshable.svg?style=flat)](http://cocoapods.org/pods/KVRefreshable)
[![Platform](https://img.shields.io/cocoapods/p/KVRefreshable.svg?style=flat)](http://cocoapods.org/pods/KVRefreshable)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS 8.0+
* Swift 5.0

## Installation

KVRefreshable is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
# For Swift 5.0
pod 'KVRefreshable', '~> 2.0.3'
```

## Usage

Adding pull to refresh
```swift
tableView.addPullToRefreshWithActionHandler {
    // Stop pull to refresh animation
    self.tableView.pullToRefreshView.stopAnimating()
}
```

Trigger the pull to refresh
```swift
tableView.triggerPullToRefresh()
```


Show the pull to refresh view
```swift
tableView.showsPullToRefresh = true
```

Hide the pull to refresh view
```swift
tableView.showsPullToRefresh = false
```

Adding infinite scrolling
```swift
tableView.addInfiniteScrollingWithActionHandler {
    // Stop infinite scrolling animation
    self.tableView.infiniteScrollingView.stopAnimating()
}
```

Trigger the infinite scrolling
```swift
tableView.triggerPullToRefresh()
```

Show the infinite scrolling view
```swift
tableView.showsInfiniteScrolling = true
```

Hide the infinite scrolling view
```swift
tableView.showsInfiniteScrolling = false
```

## Author

Vu Van Khac, khacvv0451@gmail.com<br/>
My Facebook: https://www.facebook.com/vuvankhac.official<br/>
My Twitter: https://twitter.com/vuvankhac<br/>

## License

KVRefreshable is available under the MIT license. See the LICENSE file for more info.
