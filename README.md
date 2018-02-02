# NPOKit

[![Build Status](https://travis-ci.org/4np/NPOKit.svg?branch=master)](https://travis-ci.org/4np/NPOKit)
[![Release](https://img.shields.io/github/release/4np/NPOKit.svg)](https://github.com/4np/UitzendingGemist/releases/latest)
[![Platform](https://img.shields.io/badge/platform-tvOS%2011-green.svg?maxAge=3600)](https://developer.apple.com/tvos/)
[![Swift](https://img.shields.io/badge/language-Swift-ed523f.svg?maxAge=3600)](https://swift.org)
[![Open Issues](https://img.shields.io/github/issues/4np/NPOKit.svg?maxAge=3600)](https://github.com/4np/NPOKit/issues)
[![Closed Issues](https://img.shields.io/github/issues-closed/4np/NPOKit.svg?maxAge=3600)](https://github.com/4np/NPOKit/issues?q=is%3Aissue+is%3Aclosed)

`NPOKit` is a `Swift 4` framework for interfacing with Dutch Public Broadcaster's (_Nederlandse Publieke Omroep_ - [NPO](https://www.npo.nl)) APIs. It supports fetching _programs_, _episodes_ and _video steams_ for playback.

_Note: This project is in active development so method signatures might change between versions without notice! Consider this in alpha stage... Changes that are likely coming are removing the failure closure in favor of an error argument. Note that this has currently only been tested on tvOS!_

## Installation

Add something similar to the following lines to your `Podfile`. You may need to adjust based on your platform, version/branch etc.

### Cocoapods

Using cocoapods is the most common way of installing frameworks.

```
source 'https://github.com/CocoaPods/Specs.git'
platform :tvos, '11.0'
use_frameworks!

pod 'NPOKit', :git => 'https://github.com/4np/NPOKit.git'
```

### Swift Package Manager

Add the following entry to your package's dependencies:

```
.package(url: "https://github.com/4np/NPOKit.git", from: "0.0.1")
```

## Command Line

As `NPOKit` is a true Swift application and supports the `Swift Package Manager`, you can create command line applications with it. Please refer to the [HOWTO](HOWTO-Command-Line.md) for details.

## Basic Usage

### Fetching programs

Below you'll find some sample code on how to implement some paginated fetching of programs. Unfortunately the API currently does not support sorting in alphabetical order, so the result will be based by the sort order the NPO returns (which is by most used). 

```
func getProgramPaginator(successHandler: @escaping Paginator<Program>.SuccessHandler,
                         failureHandler: Paginator<Program>.FailureHandler? = nil) -> Paginator<Program>
```

#### Example:

This code assumes you use a _scroll view_ in your user interface, so something like a _table view_ or a _collection view_.

```swift
import NPOKit

class MyViewController: UIViewController {
    private var paginator: Paginator<Item>?
    private var programs = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up paginator        
        setupPaginator()
    }
    
    // MARK: Networking
    
    private func setupPaginator() {
        // set up paginator
        paginator = NPOKit.shared.getProgramPaginator(successHandler: { [weak self] (paginator, programs) in
            // on the main queue as this might involve UI updating
            DispatchQueue.main.async {
            		// append the new batch of programs
                self?.programs.append(contentsOf: programs)
                // TODO: make sure you update the UI accordingly...
            }
        }, failureHandler: { (_) in
        	print("failure :'(")
        })
        
        // fetch the first page
        paginator?.next()
    }
}

// MARK: UIScrollViewDelegate
extension ProgramsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = collectionView, let paginator = paginator else { return }
        
        let numberOfPagesToInitiallyFetch = 2
        let yOffsetToLoadNextPage = collectionView.contentSize.height - (collectionView.bounds.height * CGFloat(numberOfPagesToInitiallyFetch))
        
        guard scrollView.contentOffset.y > yOffsetToLoadNextPage else { return }
        
        // fetch the next page of programs...
        paginator.next()
    }
}
```

### Fetching episodes

Fetching episodes works very much like fetching programs (see above), it just requires a `program` argument when setting up the paginator:

```
func getEpisodePaginator(for item: Item,
                         successHandler: @escaping Paginator<Episode>.SuccessHandler,
                         failureHandler: Paginator<Episode>.FailureHandler? = nil) -> Paginator<Episode>
```

### Fetching images

`Item` bases resources (like `Program` and `Episode`) may provide images for different usages. The most common way you would use those images on `tvOS` are for populating collection view cells, or by showing a header:

```
func fetchCollectionImage(for item: Item, completionHandler completed: @escaping (UIImage?, URLSessionDataTask?, Error?) -> Void) -> URLSessionDataTask?

func fetchHeaderImage(for item: Item, completionHandler: @escaping (UIImage?, URLSessionDataTask?, Error?) -> Void) -> URLSessionDataTask?
```

## Logging

`NPOKit` support logging through any logging framework your application uses by providing a `logging wrapper`. Below is an example of how to bind based on Dave Wood's [XCGLogger](https://github.com/DaveWoodCom/XCGLogger) that was developed completely in Swift.

### LoggerWrapper

First, you need to set up the `LoggerWrapper` which inherits from `NPOKitLogger`. It basically normalizes the logging calls to your logging framework of choice, in this case `XCGLogger`:

```
import Foundation
import NPOKit

// Logging Wrapper
class LoggerWrapper: NPOKitLogger {
    public static let shared = LoggerWrapper()
    
    override func verbose(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
        log.verbose(closure, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo)
    }
    
    override func debug(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
        log.debug(closure, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo)
    }
    
    override func info(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
        log.info(closure, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo)
    }
    
    override func warning(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
        log.warning(closure, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo)
    }
    
    override func error(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
        log.error(closure, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo)
    }
}
```

### AppDelegate

In your `AppDelegate`'s `application:didFinishLaunchingWithOptions:` you need to bind your `LoggerWrapper` to `NPOKit`, and logging will work. Set the loglevel to `debug` to get debug information or `verbose` to more elaborate information like `GET` and `POST` requests.

```
import XCGLogger
import NPOKit

let log = XCGLogger.default

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // configure logging
        log.setup(level: .verbose, showThreadName: false, showLevel: true, showFileNames: true, showLineNumbers: true)
        
        // log entry
        log.info("Application launched.")
        log.logAppDetails()
        
        // bind logger to NPOKit
        NPOKit.shared.log = LoggerWrapper.shared
        
        return true
    }
    ...
}
```

# Working on `NPOKit`

In order to work on `NPOKit` in `Xcode`, you need to generate an Xcode project. Run the following command in the project root:

```
swift package generate-xcodeproj
```

_Note: the Xcode project will not be comitted to git._


# License

See the accompanying [LICENSE](LICENSE) and [NOTICE](NOTICE) files for more information.

```
Copyright 2018 Jeroen Wesbeek

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```