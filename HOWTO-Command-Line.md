# Command line programs using NPOKit

As `NPOKit` is a true `Swift` application, and it supports the `Swift Package Manager`, you can create command line programs using `NPOKit`. In the stept below we will go through the process of creating a command line application that fetches the top 20 most popular tv shows.

## Create project

```bash
cd ~/Desktop
mkdir top20
cd top20
```

## Initialize project

```bash
swift package init --type executable
```

## Add NPOKit

Open `Package.swift` and add a dependency for [NPOKit](https://github.com/4np/NPOKit):

```swift
.package(url: "https://github.com/4np/NPOKit.git", from: "0.0.5")
```

And make sure you include it as a dependency for your target:

```swift
.target(name: "top20", dependencies: [ "NPOKit" ])
```

Your `Package.swift` should now look like this:

```swift
// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "top20",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/4np/NPOKit.git", from: "0.0.5")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "top20",
            dependencies: ["NPOKit"]),
    ]
)
```

## [Optional] Generate Xcode Project

If you're on a Mac, you can generate the Xcode project to edit in Xcode. **_Note that if you're on Linux, you can still continue by using another editor_** _(like vim or nano)_**_!_**

```bash
swift package generate-xcodeproj
```

and launch Xcode:

```bash
open top20.xcodeproj
```

## Add code to fetch programs

Open `Sources/top20/main.swift` for editing and replace it with the following code:

```swift
import Foundation
import NPOKit

// setup the paginator that fetched programs
let paginator = NPOKit.shared.getProgramPaginator { (result) in
    switch result {
    case .success(_, let programs):
        print("Top \(programs.count) TV Programs:\n")
        
        // iterate over programs
        for (index, program) in programs.enumerated() {
            // print the program name
            print("\(index + 1): \(program.title)")
        }
        
        // and exit
        exit(EXIT_SUCCESS)
    case .failure(let error as NPOError):
        // something went wrong, display an error message
        print("Error fetching programs (\(error.localizedDescription))")
        
        // and exit
        exit(EXIT_FAILURE)
    case.failure(let error):
        // something went wrong, display an error message
        print("Error fetching programs (\(error.localizedDescription))")
        
        // and exit
        exit(EXIT_FAILURE)
    }
}

// fetch the first page of programs
paginator.next()

// main loop to wait for the asynchronous request to complete
dispatchMain()
```

_We rely on the fact that the NPO 2.0 API by default sorts programs in the most popular order, and that the paginator by default uses pages of 20 items. All we need to do is instantiate the paginator and fetch the first page of programs to achieve our goal._

## Build and run

If all was done correctly, you should be able to build and run your test project:

```bash
swift build
./.build/debug/top20
```

## Result

If all went well, your compiled program should list the first batch of twenty programs. Something like this:

```bash
$ ./.build/debug/top20
Top 20 TV Programs:

1: De Luizenmoeder
2: Wie is de Mol?
3: Brugklas
4: Vier Handen Op Eén Buik
5: Floortje Naar Het Einde Van De Wereld
6: Zondag met Lubach
7: Jinek
8: Ik Vertrek
9: De Wereld Draait Door
10: Door het hart van China
11: Smeris
12: Dit Was Het Nieuws
13: SpangaS
14: Apple Tree Yard
15: De Rijdende Rechter
16: NOS Studio Sport Eredivisie
17: 2Doc:
18: Het Mooiste Meisje van de Klas
19: Spoorloos
20: Louis Theroux: Dark States
$ 
```
