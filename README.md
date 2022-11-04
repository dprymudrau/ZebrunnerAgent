# ZebrunnerAgent

## Installation steps:
1. Add [package as dependency](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) to your project
2. Create swift class that extends `NSObject`. Example:
```
import Foundation
import ZebrunnerAgent

public class ObservationConfiguration: NSObject {
    public override init() {
        ZebrunnerObserver.setUp(baseUrl: "{https://someproj.zebrunner.com}",
                                projectKey: "XCTestIOS",
                                refreshToken: "{refreshToken}")
    }
}
```
`baseUrl` - URL of your Zebrunner workspace
`projectKey` - The possible values can be found in Zebrunner on Projects tab
`refreshToken` - Generate it on "Account and Profile" page on Zebrunner

3. In `Info.plist` or Xcode settings of Test Target (Info tab) add Principal class with value `{YourTarget}.{YourPrincipalClass}`
where 
`YourTarget` - project target where observation set up class created
`YourPrincipalClass` - class name of observation configuration class


## Useful classes
1. `Artifact` - you can use static methods from this class to add artifacts (e.g. logs) and references to test cases and test runs
2. `Label` - you can use static methods from this class to add Labels to test cases and test runs
3. `Screenshot` - use when you need attach screenshot to test case

## Test maintainer
You can assign test maintainer for your test case you'll need to set maintainer's zebrunner username value to `testMaintainer` variable in test case:
```
func testSmth() {
    testMaintainer = "dprymudrau"
    
    let app = XCUIApplication()
    app.launch()
    ...
}
```

## Screenshots
You can take a screenshot of current device screen everywhere in your test class (that extends XCTestCase) that will be automatically attached to XCTest report and sent to Zebrunner:
```
func testSmth() {
    let app = XCUIApplication()
    app.launch()
    
    takeScreenshot()
    ...
}
```

or you can perform taking a custom screenshot (e.g. single UI element) and attach it to the reports above:

```
func testSmth() {
    let firstNameTextFieldScreenshot = XCUIApplication().textFields["firstName"].screenshot()
    takeScreenshot(screenshot: firstNameTextFieldScreenshot)
    ...
}
```

## Logs
Zebrunner agent intercepts your console output for a certain test case and sends captured logs to Zebrunner.

_Which types of log messages are intercepted:_
1. default XCTest/XCUITest logging (like "Tap button", "Checking existence of" etc.)
2. custom logging using "NSLog"
3. custom unified logging: "Logger" interface from "os" module and "os_log" from "os.log"

_Not intercepted:_
Debugging functions from Swift Standard Library: print, debugPrint and dump.
