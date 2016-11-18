ServerSync for iOS Apps
============================

Sometimes your app can't rely on the device's date and time settings being correct.
This library will help you calibrate your app's (NB: **Not** the device) time to the _correct_ UTC time using either your own server or Google's.
This allows you to coordinate events between your server and your app.


You can use websockets, but that tends to be overkill and adds extra complexity client and server side. Ideally, the app will periodically calibrate with the server. This library uses an exponential running average to increase accuracy and reduce the effects of variations in latency.


I will publish better documentation within a few months.

The library is written in Swift 2. I will convert it to Swift 3 in a few months.


Installation
-------------

### CocoaPods (iOS 8+)

Not set up yet

### Manual (iOS 7+)

Copy `ServerSync.swift` into your project.

(Optional) If you want to calibrate with Google's server, then Copy `GoogleCalibrate.swift` into your project.

Usage
-----

Client will refer to the iPhone in the below contexts.

### General Usage

In order to calibrate `NSDate`, you must first calibrate with a server. You can use Google or your own server (see below).
If you do not calibrate, then this library will return the client's time unchanged - no detriment to you.

Ideally, you should run the calibration periodically or upon observing `UIApplicationWillEnterForegroundNotification` because you can't rely on one HTTP request having low latency. High latency will reduce the accuracy of the calibration. This library will utilize an exponential moving average to get as accurate as possible.

After calibrating, the functions of note are:

**func toClientTime() -> NSDate** - If you have a time that is calibrated to the server's time (i.e. server's UTC time) and you want to translate it to the client's time:


```swift

//Server states that something in your app should happen at this time: "2016-11-18 01:18:00" (UTC)
dateFormat = NSDateFormatter()
dateFormat.timeZone = NSTimeZone(abbreviation: "GMT")
dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"

let serverDate: NSDate = dateFormat.dateFromString("2016-11-18 01:18:00")
let clientDate: NSDate = serverDate.toClientTime()

//Now use `clientDate` in your app. It has been calibrated.

```


**static func reset()** - Uncalibrates `NSDate` so it is no longer synchronized to the server.

```swift

NSDate.reset()

```


### If you have your own server


**Concepts**

Let's assume that from the moment the client sends it's request, the total response time is made up of 3 components:

* L<sub>req</sub> - The transmission time before your server can start processing the request.
* Operation Duration - How long the server took to process the request
* L<sub>res</sub> - The transmission time afterwards

Your server must respond with it's UTC time in UNIX format (nanoseconds) - ideally generated as late as possible.
It can be embedded in the JSON response for example. If not possible, you can use the `Date` header field which provides second-level accuracy.
Whether the `Date` header field is generated as late as possible is dependent on the server.

Ideally, the server will also return how long it took to perform the operation (i.e. process the request). The units must be in nanoseconds.
If this is not possible, you can approximate it as 0 nanoseconds, at the cost of some accuracy.


**Parameters:**

`clientRequestUTCUnixNano` - Before the client sends the request, you record the client-side UTC Unix time in nanoseconds

`serverOperationDurationNano` - The server should respond with how long it took to process the response from start of receiving request to start of sending out response. If you don't have access to the server, you can approximate this value to 0

`serverUTCUnixNano` - The server should respond with it's internal UTC time in UTC Unix time in nanoseconds - preferably as late as possible before sending response.

**static func updateOffsetRaw(clientRequestUTCUnixNano: Int64, serverOperationDurationNano: Int64, serverUTCUnixNano: Int64) -> Int64**


**Server setup**

Sample Go Code:

```go

import (
	"time"
	"net/http"
)

type Response struct {
	SyncDuration    int64            `json:"SyncDuration"` //How long the request took to process in nanoseconds
	SyncUTC         int64            `json:"SyncUTC"`      //UTC time at end of response in UNIX time (nanoseconds)
}


func RequestHandler (w http.ResponseWriter, r *http.Request) {
	operationStartTime := time.Now().UTC()
	

	//Process stuff. Do what ever. Compile Response etc

	response := Response{}

	//As late as possible: For UTC server-client synchronisation
	operationEndTime := time.Now().UTC()
	response.SyncDuration = operationEndTime.Sub(operationStartTime).Nanoseconds()
	response.SyncUTC = operationEndTime.UnixNano()
	ReturnSuccess(w, response) //Return response in JSON format
}

```

**Client setup**


The client must record the exact moment (in Unix nanosecond format) it sent the http request.

Sample Swift Code (Using AFNetworking):

```swift

let sm: AFHTTPSessionManager = AFHTTPSessionManager(baseURL: apiBaseUrl)

let clientRequestTime: Int64 = NSDate.UTCToUnixNano()
sm.GET(path, parameters: nil, progress: nil, success: {(task: NSURLSessionDataTask, responseObject: AnyObject?) -> Void in
	
	//response will have 2 json fields
	// `syncDuration` - See Go code above
	// `syncUTC` - See Go code above
	let response = f(responseObject)

	//UTC server-client synchronisation
    NSDate.updateOffsetRaw(clientRequestTime, serverOperationDurationNano: response.syncDuration, serverUTCUnixNano: response.syncUTC)
})


```


### Using Google's server

You can asynchronously calibrate using Google's servers. The library will attempt to use the lowest-latency server available.


```swift

NSDate.calibrate()

```



Other Useful Packages
------------

Check out [`"github.com/pjebs/Obfuscator-iOS"`](https://github.com/pjebs/Obfuscator-iOS) library. Secure your app by obfuscating all the hard-coded security-sensitive strings embedded in the binary.


Check out [`"github.com/pjebs/GAE-Toolkit-Go"`](https://github.com/pjebs/GAE-Toolkit-Go) package. Escape CloudSQL and save money by using an external MYSQL database with Google App Engine - Go.

Final Notes
------------

If you found this package useful, please **Star** it on github. Feel free to fork or provide pull requests. Any bug reports will be warmly received.


[SkyLovely Pty Ltd](http://www.skylove.ly)

```
