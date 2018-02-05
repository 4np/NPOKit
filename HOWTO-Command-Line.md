# Command line programs using NPOKit

As `NPOKit` is a true `Swift` application, and it supports the `Swift Package Manager`, you can create command line programs using `NPOKit`. An example on how to accomplish this:

## Create project

```
cd ~/Desktop
mkdir foo
cd foo
```

## Initialize project

```
swift package init --type executable
```

## Add NPOKit

Open `Package.swift` and add a dependency for [NPOKit](https://github.com/4np/NPOKit):

```
.package(url: "https://github.com/4np/NPOKit.git", from: "0.0.1")
```

And make sure you include it as a dependency for your target:

```
.target(name: "foo", dependencies: [ "NPOKit" ])
```

Your `Package.swift` should now look like this:

```
import PackageDescription

let package = Package(
    name: "foo",
    dependencies: [
        .package(url: "https://github.com/4np/NPOKit.git", from: "0.0.1")
    ],
    targets: [
        .target(name: "foo", dependencies: [ "NPOKit" ])
    ]
)
```

## [Optional] Generate Xcode Project

If you're on a Mac, you can generate the Xcode project to edit in Xcode. **_Note that if you're on Linux, you can still continue by using another editor_** _(like vim or nano)_**_!_**

```
swift package generate-xcodeproj
```

and launch Xcode:

```
open foo.xcodeproj
```

## Add code to fetch programs

Open `Sources/foo/main.swift` for editing and replace it with the following code:

```
import Foundation
import NPOKit

// setup the paginator that fetched programs
let paginator = NPOKit.shared.getProgramPaginator(successHandler: { (paginator, programs) in
    print("Fetched \(programs.count) programs:\n")
    
    // iterate over programs
    for (index, program) in programs.enumerated() {
        // print the program name
        print("Program \(index + 1): \(program.title)")
    }
    
    // and exit
    exit(EXIT_SUCCESS)
}) { (paginator) in
    // something went wrong, display an error message
    print("Error fetching programs")
    
    // end exit
    exit(EXIT_FAILURE)
}

// fetch the first page of programs
paginator.next()

// main loop to wait for the asynchronous request to complete
dispatchMain()
```

## Build and run

If all was done correctly, you should be able to build and run your test project:

```
swift build
./.build/debug/foo
```

## Result

If all went well, your compiled program should list the first batch of twenty programs. Something like this:

```
$ ./.build/debug/foo
Fetched 20 programs:

Program 1: De Luizenmoeder
Program 2: Wie is de Mol?
Program 3: Brugklas
Program 4: Vier Handen Op Eén Buik
Program 5: Jinek
Program 6: Floortje Naar Het Einde Van De Wereld
Program 7: Over Mijn Lijk
Program 8: De Wereld Draait Door
Program 9: Zondag met Lubach
Program 10: Door het hart van China
Program 11: Smeris
Program 12: Apple Tree Yard
Program 13: De slimste mens
Program 14: NOS Studio Sport Eredivisie
Program 15: SpangaS
Program 16: Dit Was Het Nieuws
Program 17: De Rijdende Rechter
Program 18: Ik Vertrek
Program 19: Spoorloos
Program 20: The Dateables
$
```