# ZebrunnerAgent

## Installation steps:
1. Add [package as dependency](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) to your project
2. In `Info.plist` or Xcode settings of Test Target (Info tab), add `Principal class` with value `ZebrunnerAgent.ZebrunnerObserver`
3. Once the principal class is added, the agent is **not** automatically enabled. The valid configuration must be provided.

It is currently possible to provide the configuration via:
1. Environment variables 
2. Info.plist properties file

The configuration lookup will be performed in the order listed above, meaning that environment configuration will always take precedence over Info.plist.

### Environment variables

You have to perform some modifications to your Scheme for granting an access to provided environment variables. 

Navigate in Xcode: Product > Scheme > Edit Scheme > Test > Arguments tab > Environment Variables:

1. From this section, define as on the examples below:

- local Environment Variables for running tests directly from Xcode:

| Name                       | Value                         |
|----------------------------|-------------------------------|
| `REPORTING_ENABLED`        | true                          |
| `REPORTING_SERVER_HOSTNAME`| https://someproj.zebrunner.com|

- Command Line Arguments:

| Name                       | Value                         |
|----------------------------|-------------------------------|
| `REPORTING_ENABLED`        | `$(REPORTING_ENABLED)`        |
| `REPORTING_SERVER_HOSTNAME`| `$(REPORTING_SERVER_HOSTNAME)`|

for executing via `xcodebuild` command:

```
xcodebuild \
-project <Your-Project>.xcodeproj \
-scheme <Your-Scheme> \
-destination 'platform=iOS Simulator,name=iPhone 14' \
REPORTING_ENABLED=true \
REPORTING_SERVER_HOSTNAME=https://someproj.zebrunner.com \
test
```

2. Uncheck the "Use the Run action's arguments and environment variables"
3. Change the drop down "Expand Variables Based On" to the Test target in the Test scheme.


The following environment variables are recognized by the agent:
- `REPORTING_ENABLED` - enables or disables reporting. The default value is `false`;
- `REPORTING_SERVER_HOSTNAME` - mandatory if reporting is enabled. It is Zebrunner server base url (e.g. https://someproj.zebrunner.com);
- `REPORTING_SERVER_ACCESS_TOKEN` - mandatory if reporting is enabled. Access token must be used to perform API calls. It can be obtained in Zebrunner on the 'Account & profile' page under the 'Token' section;
- `REPORTING_PROJECT_KEY` - optional value. It is the project that the test run belongs to. The default value is `DEF`. You can manage projects in Zebrunner in the appropriate section;
- `REPORTING_RUN_DISPLAY_NAME` - optional value. It is the display name of the test run. The default value is `Default Suite`;
- `REPORTING_RUN_BUILD` - optional value. It is the build number that is associated with the test run. It can depict either the test build number or the application build number;
- `REPORTING_RUN_ENVIRONMENT` - optional value. It is the environment where the tests will run;
- `REPORTING_RUN_LOCALE` - optional value. Locale, that will be displayed for the run in Zebrunner if specified;
- `REPORTING_RUN_TREAT_SKIPS_AS_FAILURES` - optional value. The default value is `true`. If the value is set to `true`, skipped tests will be treated as failures when processing test run results. As a result, if value of the property is set to `false` and test run contains only skipped and passed tests, the entire test run will be treated as passed;
- `REPORTING_NOTIFICATION_NOTIFY_ON_EACH_FAILURE` - optional value. Specifies whether Zebrunner should send notification to Slack/Teams on each test failure. The notifications will be sent even if the suite is still running. The default value is `false`;
- `REPORTING_NOTIFICATION_SLACK_CHANNELS` - optional value. The list of comma-separated Slack channels to send notifications to. Notification will be sent only if Slack integration is properly configured in Zebrunner with valid credentials for the project the tests are reported to. Zebrunner can send two type of notifications: on each test failure (if appropriate property is enabled) and on suite finish;
- `REPORTING_NOTIFICATION_MS_TEAMS_CHANNELS` - optional value. The list of comma-separated Microsoft Teams channels to send notifications to. Notification will be sent only if Teams integration is configured in Zebrunner project with valid webhooks for the channels. Zebrunner can send two type of notifications: on each test failure (if appropriate property is enabled) and on suite finish;
- `REPORTING_NOTIFICATION_EMAILS` - optional value. The list of comma-separated emails to send notifications to. This type of notification does not require further configuration on Zebrunner side. Unlike other notification mechanisms, Zebrunner can send emails only on suite finish;
- `REPORTING_MILESTONE_ID` - optional value. Id of the Zebrunner milestone to link the suite execution to. The id is not displayed on Zebrunner UI, so the field is basically used for internal purposes. If the milestone does not exist, appropriate warning message will be displayed in logs, but the test suite will continue executing;
- `REPORTING_MILESTONE_NAME` - optional value. Name of the Zebrunner milestone to link the suite execution to. If the milestone does not exist, appropriate warning message will be displayed in logs, but the test suite will continue executing;
- `REPORTING_DEBUG_LOGS_ENABLED` - optional value. The default value is `false` that means that debugging functions from Swift Standard Library such as `print, debugPrint and dump` will not be displayed in log output.
- `REPORTING_RUN_TEST_CASE_STATUS_ON_PASS` - optional value. If automated tests are associated with test cases from a TCM system (TestRail, Xray, Zephyr) and there is a setting to push the execution results to the TCM, then this config determines what status will be set for a passed test.
- `REPORTING_RUN_TEST_CASE_STATUS_ON_FAIL` - optional value. If automated tests are associated with test cases from a TCM system (TestRail, Xray, Zephyr) and there is a setting to push the execution results to the TCM, then this config determines what status will be set for a failed test.
- `REPORTING_RUN_TEST_CASE_STATUS_ON_SKIP` - optional value. If automated tests are associated with test cases from a TCM system (TestRail, Xray, Zephyr) and there is a setting to push the execution results to the TCM, then this config determines what status will be set for a skipped test.

### Info.plist properties

Unlike environment variables, Info.plist files are separate for each Test Target and you could apply different Zebrunner settings for them. For example, turn off reporting for Unit tests and enable for UI tests.

The following configuration parameters are recognized by the agent:
- `ReportingEnabled` - enables or disables reporting. The default value is `false`;
- `ReportingServerHostname` - mandatory if reporting is enabled. It is Zebrunner server base url (e.g. https://someproj.zebrunner.com);
- `ReportingServerAccessToken` - mandatory if reporting is enabled. Access token must be used to perform API calls. It can be obtained in Zebrunner on the 'Account & profile' page under the 'Token' section;
- `ReportingProjectKey` - optional value. It is the project that the test run belongs to. The default value is `DEF`. You can manage projects in Zebrunner in the appropriate section;
- `ReportingRunDisplayName` - optional value. It is the display name of the test run. The default value is `Default Suite`;
- `ReportingRunBuild` - optional value. It is the build number that is associated with the test run. It can depict either the test build number or the application build number;
- `ReportingRunEnvironment` - optional value. It is the environment where the tests will run;
- `ReportingRunLocale` - optional value. Locale, that will be displayed for the run in Zebrunner if specified;
- `ReportingRunTreatSkipsAsFailures` - optional value. The default value is `true`. If the value is set to `true`, skipped tests will be treated as failures when processing test run results. As a result, if value of the property is set to `false` and test run contains only skipped and passed tests, the entire test run will be treated as passed;
- `ReportingNotificationNotifyOnEachFailure` - optional value. Specifies whether Zebrunner should send notification to Slack/Teams on each test failure. The notifications will be sent even if the suite is still running. The default value is `false`;
- `ReportingNotificationSlackChannels` - optional value. The list of comma-separated Slack channels to send notifications to. Notification will be sent only if Slack integration is properly configured in Zebrunner with valid credentials for the project the tests are reported to. Zebrunner can send two type of notifications: on each test failure (if appropriate property is enabled) and on suite finish;
- `ReportingNotificationMsTeamsChannels` - optional value. The list of comma-separated Microsoft Teams channels to send notifications to. Notification will be sent only if Teams integration is configured in Zebrunner project with valid webhooks for the channels. Zebrunner can send two type of notifications: on each test failure (if appropriate property is enabled) and on suite finish;
- `ReportingNotificationEmails` - optional value. The list of comma-separated emails to send notifications to. This type of notification does not require further configuration on Zebrunner side. Unlike other notification mechanisms, Zebrunner can send emails only on suite finish;
- `ReportingMilestoneId` - optional value. Id of the Zebrunner milestone to link the suite execution to. The id is not displayed on Zebrunner UI, so the field is basically used for internal purposes. If the milestone does not exist, appropriate warning message will be displayed in logs, but the test suite will continue executing;
- `ReportingMilestoneName` - optional value. Name of the Zebrunner milestone to link the suite execution to. If the milestone does not exist, appropriate warning message will be displayed in logs, but the test suite will continue executing;
- `ReportingDebugLogsEnabled` - optional value. The default value is `false` that means that debugging functions from Swift Standard Library such as `print, debugPrint and dump` will not be displayed in log output.
- `ReportingRunTestCaseStatusOnPass` - optional value. If automated tests are associated with test cases from a TCM system (TestRail, Xray, Zephyr) and there is a setting to push the execution results to the TCM, then this config determines what status will be set for a passed test.
- `ReportingRunTestCaseStatusOnFail` - optional value. If automated tests are associated with test cases from a TCM system (TestRail, Xray, Zephyr) and there is a setting to push the execution results to the TCM, then this config determines what status will be set for a failed test.
- `ReportingRunTestCaseStatusOnSkip` - optional value. If automated tests are associated with test cases from a TCM system (TestRail, Xray, Zephyr) and there is a setting to push the execution results to the TCM, then this config determines what status will be set for a skipped test.


## Useful classes
1. `Screenshot` - helps when you need to attach a screenshot to a test case;
2. `Log` - provides a possibility to send log messages to a test case;
3. `Artifact` - you can use static functions from this class to add artifacts and references to test cases and test run;
4. `Label` - useful to add Labels to test cases and test run;
5. `Locale` - provides a method to add a locale to a test run;
6. `TestRail`, `Xray`, `Zephyr` - performs syncing test executions with external Test Case Management systems.

## Test maintainer
You may want to add transparency to the process of automation maintenance by having an engineer responsible for evolution of specific tests. To serve that purpose Zebrunner comes with a concept of a maintainer.

If you wish to assign a test maintainer for your test case, you can set a valid Zebrunner username to `testMaintainer` variable in test case. Otherwise it will be set to `anonymous`.

```
func testSmth() {
    testMaintainer = "deve_loper"
    
    let app = XCUIApplication()
    app.launch()
    ...
}
```

## Screenshots
There are several options how to take a screenshot that will be automatically attached to XCTest report and sent to Zebrunner.

1. There is an extension of `XCTestCase` class and since all test classes extend it by default, you can take a screenshot everywhere in your test methods as on the examples below.

- full screenshot of the current screen:

```
func testSmth() {
    let app = XCUIApplication()
    app.launch()
    
    takeScreenshot()
    ...
}
```

- custom screenshot (e.g. single UI element):

```
func testSmth() {
    let firstNameTextFieldScreenshot = XCUIApplication().textFields["firstName"].screenshot()
    takeScreenshot(screenshot: firstNameTextFieldScreenshot)
    ...
}
```

2. In addition to option #1, it's highly recommended to extend your test classes from `ZebrunnerBaseTestCase` (extends `XCTestCase`) that is responsible for sending a screenshot of failed test automatically to Zebrunner. All examples mentioned above are still valid.
3. If you want to take a screenshot on your own and both options are not covered your needs, you can use static functions from `Screenshot` class.

```
func testSmth() {
    let screenshot = XCUIScreen.main.screenshot()
    Screenshot.sendScreenshot(self.name, screenshot: screenshot)
    ...
}
```

## Logs
Zebrunner agent collects your console output for a certain test case and sends captured logs to Zebrunner out of the box. No additional configuration is needed. 

_Which types of log messages are intercepted:_

1. default `XCTest/XCUITest` logging (like "Tap button", "Checking existence of" etc.);
2. custom logging using `NSLog`;
3. custom unified logging: `Logger` interface from `os` module and `os_log` from `os.log`.

_Not intercepted if `REPORTING_DEBUG_LOGS_ENABLED` / `ReportingDebugLogsEnabled` is `false`:_

- Debugging functions from Swift Standard Library: `print`, `debugPrint` and `dump`. To include them and send such log messages to Zebrunner, set environment variable `REPORTING_DEBUG_LOGS_ENABLED` or property `ReportingDebugLogsEnabled` to `true`.

In case of necessity sending custom logs for specific test case to Zebrunner, use `#sendLogs` function from `Log` class.

```
func testSmth() {
    let currentTimestamp = String(Int(Date().timeIntervalSince1970 * 1_000))
    Log.sendLogs(self.name, logMessages: ["Some custom string", "Another custom string"],
                level: LogLevel.info, timestamp: currentTimestamp)
    ...
}
```

## Artifacts
In case your tests or entire test run produce some artifacts, it may be useful to track them in Zebrunner. The agent comes with a few convenient methods for uploading artifacts in Zebrunner and linking them to the currently running test or the test run.

Artifacts can be uploaded using the `Artifact` class. 

- `#attachToTestRun` and `#attachToTestCase` functions can be used to upload and attach an artifact file to test run and test case respectively;
- `#attachReferenceToTestRun` and `#attachReferenceToTestCase` functions can be used to attach an arbitrary artifact reference to test run and test case respectively.

```
func testSmth() {
    let fullScreenshot = XCUIScreen.main.screenshot().pngRepresentation
    Artifact.attachToTestRun(artifact: fullScreenshot, name: "test_run_screenshot")
    Artifact.attachReferenceToTestRun(key: "Zebrunner Github", value: "https://github.com/zebrunner")
        
    let firstNameTextFieldScreenshot = XCUIApplication().textFields["firstName"].screenshot()
    Artifact.attachToTestCase(self.name, artifact: firstNameTextFieldScreenshot, name: "text_field_screenshot")
    Artifact.attachReferenceToTestCase(self.name, key: "Zebrunner website", value: "https://zebrunner.com/")
    ...
}
```

## Labels
In some cases, it may be useful to attach some meta information related to a test. The agent comes with a concept of labels. Label is a key-value pair associated with a test case or test run. 

Labels can be attached using the `Label` class. 

- `#attachToTestCase` functions can attach a pair or an array of labels to specified test case;
- `#attachToTestRun` - used for attaching labels for a whole test run.

```
func testSmth() {
    Label.attachToTestRun(key: "type", value: "device")
    Label.attachToTestRun(labels: ["feature": "login", "browser": "safari"])
   
    Label.attachToTestCase(self.name, key: "type", value: "simulator")
    Label.attachToTestCase(self.name, labels: ["status": "fail", "reason": "product_bug"])
    ...
}
```

## Locale
If you want to get full reporting experience and collect as much information in Zebrunner as its possible, you may want to report the test run locale. It can be done via one of the options below:
1. By providing a value via environment variable `REPORTING_RUN_LOCALE` or property `ReportingRunLocale`.
2. Using `#setLocale` function from `Locale` class:

```
func testSmth() {
    Locale.setLocale(localeValue: "EN_en")
    ...
}
```

## Test Case Management systems

Zebrunner provides an ability to upload test results to external TCMs on test run finish. For some TCMs it is possible to upload results in real-time during the test run execution.

Currently, Zebrunner supports TestRail, Xray, Zephyr Squad and Zephyr Scale test case management systems.

For successful upload of test run results in specific TCM system, two steps must be performed:

1. Integration with this TCM system is configured and enabled for Zebrunner project;
2. Configuration is performed on the tests side.

**NOTE**: basic configuration for all TCM systems must be invoked before all tests. For XCTest framework, it should be located inside `override class func setUp()` of *first test class of your Test Target (when tests are executing, they are sorted alphabetically)*.
In case of running all tests from different Test Targets (e.g. unit and UI), configuration should be done in first test class of each Test Target.

### TestRail

Zebrunner agent has a special `TestRail` class with a bunch of methods to control results upload:

- `#setSuiteId(String)` - mandatory. The method sets TestRail suite id for current test run. This method must be invoked before all tests;
- `#setTestCaseId(String)` - mandatory. Using this mechanism you can set TestRail's case associated with specific automated test
- `#disableSync()` - optional. Disables result upload. Same as `#setSuiteId(String)`, this method must be invoked before all tests;
- `#includeAllTestCasesInNewRun()` - optional. Includes all cases from suite into newly created run in TestRail. Same as `#setSuiteId(String)`, this method must be invoked before all tests;
- `#enableRealTimeSync()` - optional. Enables real-time results upload. In this mode, result of test execution will be uploaded immediately after test finish. This method also automatically invokes `#includeAllTestCasesInNewRun()`. Same as `#setSuiteId(String)`, this method must be invoked before all tests;
- `#setRunId(String)` - optional. Adds result into existing TestRail run. If not provided, test run is treated as new. Same as `#setSuiteId(String)`, this method must be invoked before all tests;
- `#setRunName(String)` - optional. Sets custom name for new TestRail run. By default, Zebrunner test run name is used. Same as `#setSuiteId(String)`, this method must be invoked before all tests;
- `#setMilestone(String)` - optional. Adds result in TestRail milestone with the given name. Same as `#setSuiteId(String)`, this method must be invoked before all tests;
- `#setAssignee(String)` - optional. Sets TestRail run assignee - should be email of existing TestRail user. Same as `#setSuiteId(String)`, this method must be invoked before all tests.

By default, a new run containing only cases assigned to the tests will be created in TestRail on test run finish.

```
override class func setUp() {
    TestRail.setSuiteId(suiteId: "1000")
    TestRail.enableRealTimeSync()
    TestRail.setRunName(runName: "XCUI tests")
    TestRail.setAssignee(assignee: "anytestrailuser@xtest.com")
    TestRail.setMilestone(milestone: "TestRail milestone")
}
    
func testSmth() {
    TestRail.setTestCaseId(testCaseId: "10000")
    ...
}
```

### Xray

Zebrunner agent has a special `Xray` class with a bunch of methods to control results upload:

- `#setExecutionKey(String)` - mandatory. The method sets Xray execution key. This method must be invoked before all tests;
- `#setTestKey(String)` - mandatory. Using these mechanisms you can set test keys associated with specific automated test;
- `#disableSync()` - optional. Disables result upload. Same as `#setExecutionKey(String)`, this method must be invoked before all tests;
- `#enableRealTimeSync()` - optional. Enables real-time results upload. In this mode, result of test execution will be uploaded immediately after test finish. Same as `#setExecutionKey(String)`, this method must be invoked before all tests.

By default, results will be uploaded to Xray on test run finish.

```
override class func setUp() {
    Xray.setExecutionKey(key: "ZBR-42")
    Xray.enableRealTimeSync()
}
    
func testSmth() {
    Xray.setTestKey(testKey: "ZBR-20000")
    ...
}
```

### Zephyr Squad & Zephyr Scale

Zebrunner agent has a special `Zephyr` class with a bunch of methods to control results upload:

- `#setTestCycleKey(String)` - mandatory. The method sets Zephyr test cycle key. This method must be invoked before all tests;
- `#setJiraProjectKey(String)` - mandatory. Sets Zephyr Jira project key. Same as `#setTestCycleKey(String)`, this method must be invoked before all tests;
- `#setTestCaseKey(String)` - mandatory. Using these mechanisms you can set test case keys associated with specific automated test;
- `#disableSync()` - optional. Disables result upload. Same as `#setTestCycleKey(String)`, this method must be invoked before all tests;
- `#enableRealTimeSync()` - optional. Enables real-time results upload. In this mode, result of test execution will be uploaded immediately after test finish. Same as `#setTestCycleKey(String)`, this method must be invoked before all tests.

By default, results will be uploaded to Zephyr on test run finish.

```
override class func setUp() {
    Zephyr.setTestCycleKey(testKey: "ZBR-R42")
    Zephyr.setJiraProjectKey(jiraKey: "ZBR")
}
    
func testSmth() {
    Zephyr.setTestCaseKey(testCaseKey: "ZBR-T20000")
    ...
}
```
