# LogTen Pro API

Version 2.0.2  
2021-04-06

[Coradine Aviation Systems](https://coradine.com) proudly presents the LogTen Pro Application Programming Interface (API) v2.0 which allows third-party applications to interact with LogTen Pro via a straight forward URL based approach using [JSON](https://json.org) (JavaScript Object Notation).

The LogTen Pro API v2.0 is available starting with LogTen Pro X 7.3. The 2.0.1 API is available starting with LogTen Pro 7.5.8, and is backward compatible with API v2.0.

LogTen Pro is registered to handle requests to the `logten://` URI scheme. Any requests made to the `logten://` scheme will be passed off to LogTen Pro for handling. The general format of the request is as follows: 

`logten://v2/method?package={JSON}`

NOTE: `logten` is the preferred scheme as of API version 2.0.2, however the legacy scheme of `logtenprox` remains compatible.

## Package

The `package` query parameter is a String containing a URL encoded JSON object, which contains two top level elements:

`metadata` and `entities`

thus:

```
{
  "metadata":{...},
  "entities":[...]
}
```

`metadata` represents a JSON object, detailed below.  
`entities` represents a JSON array of entity objects, further described below.

The `package` query parameter value must represent a valid JSON string. Please ensure values in the JSON are properly escaped and the JSON object passes linting checks (see [https://jsonlint.com](https://jsonlint.com)).

Additionally, because the value of the package query parameter contains JSON, it must be URL encoded such that the whole URL is valid. URL encoding, or "[percent encoding](https://en.wikipedia.org/wiki/Percent-encoding)" is a common practice and there are many resources available online to elaborate on the concept and techniques involved.

Coradine supplies sample code in various formats to illustrate how the URL can be properly constructed and encoded. Please visit [https://github.com/Coradine/LogTenProAPI](https://github.com/Coradine/LogTenProAPI) for our latest documentation and sample code.

The following is an example of a valid `addEntities` request:

```
logten://v2/addEntities?package=%7B%22entities%22%3A%5B%7B%22flight_flightDate%22%3A%2212%2F25%2F2010%22%2C%22flight_takeoffTime%22%3A%2212%2F25%2F2010%2015%3A50%22%2C%22flight_selectedAircraftType%22%3A%22SR22%22%2C%22flight_to%22%3A%22KSFO%22%2C%22flight_totalTime%22%3A%222%3A30%22%2C%22entity_name%22%3A%22Flight%22%2C%22flight_from%22%3A%22KPDX%22%2C%22flight_remarks%22%3A%22%5C%22Never%20interrupt%20someone%20doing%20what%20you%20said%20couldn%27t%20be%20done.%5C%22%20%5C%5C%20Amelia%20Earhart%22%7D%5D%2C%22metadata%22%3A%7B%22dateAndTimeFormat%22%3A%22MM%2Fdd%2Fyyyy%20HH%3Amm%22%2C%22timesAreZulu%22%3Atrue%2C%22application%22%3A%22MyApplication%22%2C%22dateFormat%22%3A%22MM%2Fdd%2Fyyyy%22%2C%22version%22%3A%221.0%22%7D%7D
```

Here's the same URL, without URL encoding:

```
logten://v2/addEntities?package={"entities":[{"flight_flightDate":"12/25/2010","flight_takeoffTime":"12/25/2010 15:50","flight_selectedAircraftType":"SR22","flight_to":"KSFO","flight_totalTime":"2:30","entity_name":"Flight","flight_from":"KPDX","flight_remarks":"\"Never interrupt someone doing what you said couldn't be done.\" \\ Amelia Earhart"}],"metadata":{"dateAndTimeFormat":"MM/dd/yyyy HH:mm","timesAreZulu":true,"application":"MyApplication","dateFormat":"MM/dd/yyyy","version":"1.0"}}
```

And here, the package query parameter value is expanded:

```
{
  "entities": [{
    "flight_flightDate": "12/25/2010",
    "flight_takeoffTime": "12/25/2010 15:50",
    "flight_selectedAircraftType": "SR22",
    "flight_to": "KSFO",
    "flight_totalTime": "2:30",
    "entity_name": "Flight",
    "flight_from": "KPDX",
    "flight_remarks": "\"Never interrupt someone doing what you said couldn't be done.\" \\ Amelia Earhart"
  }],
  "metadata": {
    "dateAndTimeFormat": "MM/dd/yyyy HH:mm",
    "timesAreZulu": true,
    "application": "MyApplication",
    "dateFormat": "MM/dd/yyyy",
    "version": "1.0"
  }
}
```

Please note the JSON is properly escaped. Specifically, the contents of the `flight_remarks` element is properly escaped such that the quotes (`"`)and backslashes (`\`) are properly handled to yield valid JSON. Please see [https://jsonlint.com](https://jsonlint.com) and [https://json.org](https://json.org) for specifics on how to properly format JSON data.

## Metadata

The `package` object shall always contain a `metadata` dictionary. The `metadata` dictionary must always contain the requesting application name as well as the requesting applicationʼs version information. While not required, the inclusion of a String value for the `serviceID` key is encouraged to help LogTen Pro uniquely identify the requesting application, and should not change over time. Unlike the `application` key whose value may be presented to the user, the value supplied for the `serviceID` will not be user facing and should follow the common notion of a reverse DNS naming convention (see the example). Similarly, the inclusion of a String value for the `serviceAccountKey` key is encouraged so LogTen Pro can associate the data in the API request with the sending service's account. This key should be unique to the specific user account represented by the requesting application/service, and the value (String) is treated as an opaque unique identifier by LogTen Pro (consider a UUID style value). Please note: If a value for `serviceAccountKey` is supplied, then a value for `serviceID` must also be supplied, as these two values are used in tandem. Additionally, depending on the actual method invoked, the `metadata` may contain further optional parameters (see specific documentation for supported methods).

Ex:

```
logten://v2/method?package={"metadata":{"application":"My Application", "version":"1.0", "serviceID": "com.acme.dehydrated_boulders", "serviceAccountKey": "63392ce4-d3f7-4fcf-a1fd-ee5640205568", "optionalParameter":"some_value"}, …}
```

## Identifying Entities

**IMPORTANT:** each entity *MUST* contain the `entity_name` attribute and specify the entity name.

| Entity Names          |
|:----------------------|
| `Flight`              |
| `Aircraft`              |


LogTen Pro utilizes the `flight_key` attribute on the `Flight` entity to uniquely identify flights provided from an external source. The `flight_key` attribute is a String value and is required to be unique for a given logbook. When a flight record is sent through the API that includes a `flight_key`, LogTen Pro will first attempt to locate a matching flight with that `flight_key`. If an `addEntities` or `modifyEntities` operation is being run and a matching `Flight` already exists with that `flight_key`, that `Flight` will be modified with the provided data. If a matching `Flight` is not found, a new entity will be created with the provided data. For removal operations, only flights with the matching `flight_key` will be removed. Please note: If the matching `Flight` is locked (`flight_isLocked` is set to `1`), the `Flight` will not be modified or deleted. 

## Supported Methods 

### addEntities

The `addEntities` method allows a third-party application to create/modify entities within the LogTen Pro logbook. When the `addEntities` method is invoked, LogTen Pro will ask the user if they wish to create/modify the entities from the requesting application. 

The `addEntities` method expects the `metadata` dictionary (see the `metadata` section above) and a collection of entities.

```
logten://v2/addEntities?package={"metadata":{"application":"My App", "version":"1.0", ...}, "entities":[{entity1 info...}, {entity2 info...}, …]}
```

#### metadata:

The `addEntities` method allows the following optional parameters in the `metadata` dictionary:

* `dateFormat` - The `dateFormat` parameter specifies how date values should be parsed when they are passed in as String values. The date format string uses the format patterns recognized by the Cocoa `NSDateFormatter` class (e.g. "MM/dd/yyyy").
* `dateAndTimeFormat` - The `dateAndTimeFormat` parameter specifies how date values should be parsed when they are passed in as String values. The date and time format string uses the format patterns recognized by the Cocoa `NSDateFormatter` class (i.e. "MM/dd/yyyy HH:mm").
* `timesAreZulu` - The `timesAreZulu` parameter specifies whether any passed in String time values are in Zulu time or should be converted to local time based on the time zone of the departure or arrival airports. Valid values for the `timesAreZulu` parameter are `true` or `false`. If this parameter is not supplied, the default value is `true`. 
* `shouldApplyAutoFillTimes` - The `shouldApplyAutoFillTimes` parameter specifies whether LogTen Pro should apply the users configured auto fill times (any time field within LogTen Pro set to Auto fill) to any flight entities that are created. This would include the auto calculation of night times. Valid values for the `shouldApplyAutoFillTimes` parameter are `true` or `false`. If this parameter is not supplied, the default value is `false`.
* `addCrewUsingID` - The `addCrewUsingID` parameter specifies whether LogTen Pro should add any new crew members found in the import by setting their ID field to the value from the import. Valid values for the `addCrewUsingID` parameter are `true` or `false`. If this parameter is not supplied, the default value is `false` (LogTen Pro will assume the value is the crew member's name).

#### entities

The `entities` collection shall contain the attributes for each entity to be created/modified.

LogTen Pro will first attempt to locate a `Flight` in the logbook matching the given `flight_key` (if any). If a matching `Flight` is found, that `Flight` will be updated with the provided attributes. If a matching `Flight` is not found, a new `Flight` will be created. Any of the valid LogTen Pro attributes are available for use (see the Appendix for the current, complete list of relevant attributes).

When creating `Flight` entities, the `addEntities` method will allow flight time values to be supplied as either the decimal number of hours (i.e. 1.5), the number of hours and minutes separated by a colon (i.e. "1:30") or the number of hours and minutes separated by a plus sign (i.e. "1+30").

The `addEntities` method will allow date values to be supplied as either a String value that matches the `dateFormat` parameter supplied in the `metadata` or as the number of seconds from the unix epoch (this value can be returned using the `NSDate` `timeIntervalSince1970` method in Cocoa). 

The `addEntities` method will allow date/time values to be to be supplied as either a String value that matches the `dateAndTimeFormat` parameter supplied in the `metadata` or as the number of seconds from the unix epoch (this value can be returned using the `NSDate` `timeIntervalSince1970` method in Cocoa).

The `timesAreZulu` parameter is only applicable to date/time values that are passed in as Strings. When handling local times, the `addEntities` method will first attempt to obtain the time zone for the applicable to or from place (depending on the attribute being set). If there is no corresponding place or it does not have a time zone associated with it, the `addEntities` method will attempt to use the default timezone set for LogTen Pro. If there is no default timezone configured, the `addEntities` method will use GMT (Zulu).

#### Advanced Options

Attributes that contain the `_selected` keyword denote convenience methods for accessing/creating related objects. When you set `flight_selectedAircraftType` to "SR22", LogTen Pro will first try to find an aircraft type with that Type designator, if one is found it is automatically set at the `Flight` entities `flight_aircraftType`, if not, a new Type is created and set. In general this is the simplest way to set data, and is all you need.

### modifyEntities

The `modifyEntities` method allows a third-party application to create, modify and remove flights created by the same application within the LogTen Pro logbook. When the `modifyEntities` method is invoked, LogTen Pro will ask the user if they wish to create/modify and remove the flights from the requesting application. 

The `modifyEntities` method expects the `metadata` dictionary (see the `metadata` section above), a collection of flights to create/modify (`entities`) and collection of flights to remove (`removeEntities`). The `modifyEntities` method requires both collections to be present, however it is valid to send empty collections.

```
logten://v2/modifyEntities?package={"metadata":{"application":"My App", "version":"1.0", ...}, "entities":[{flight1 info...}, {flight2 info...}, ...], "removeEntities":[{flight1 flight_key}, {flight2 flight_key}, ...]}
```

#### metadata

The `modifyEntities` method allows these optional parameters in the `metadata` dictionary:

* `dateFormat` - The `dateFormat` parameter specifies how date values should be parsed when they are passed in as String values. The date format string uses the format patterns recognized by the Cocoa `NSDateFormatter` class (e.g. "MM/dd/yyyy"). 
* `dateAndTimeFormat` - The `dateAndTimeFormat` parameter specifies how date values should be parsed when they are passed in as String values. The date and time format string uses the format patterns recognized by the Cocoa `NSDateFormatter` class (i.e. "MM/dd/yyyy HH:mm").
* `timesAreZulu` - The `timesAreZulu` parameter specifies whether any passed in String time values are in Zulu time or should be converted to local time based on the time zone of the departure or arrival airports. Valid values for the `timesAreZulu` parameter are `true` or `false`. If this parameter is not supplied, the default value is `true`.
* `shouldApplyAutoFillTimes` - The `shouldApplyAutoFillTimes` parameter specifies whether LogTen Pro should apply the users configured auto fill times to any flight entities that are created. This would include the auto calculation of night times. Valid values for the `shouldApplyAutoFillTimes` parameter are `true` or `false`. If this parameter is not supplied, the default value is `false`.
* `addCrewUsingID` - The `addCrewUsingID` parameter specifies whether LogTen Pro should add any new crew members found in the import by setting their ID field to the value from the import. Valid values for the `addCrewUsingID` parameter are `true` or `false`. If this parameter is not supplied, the default value is `false` (LogTen Pro will assume the value is the crew member's name).

#### entities

The `entities` collection shall contain the attributes for each entity to be created/modified. Only `Flight` entities, and only those with an associated `flight_key`, can be modified.

LogTen Pro will first attempt to locate a `Flight` in the logbook matching the given `flight_key` (if any). If a matching `Flight` is found, that `Flight` will be updated with the provided attributes. If a matching `Flight` is not found, a new `Flight` will be created. Any of the valid LogTen Pro attributes are available for use (see the Appendix for the current, complete list of relevant attributes).

When creating `Flight` entities, the `modifyEntities` method will allow flight time values to be supplied as either the decimal number of hours (i.e. 1.5), the number of hours and minutes separated by a colon (i.e. "1:30") or the number of hours and minutes separated by a plus sign (i.e. "1+30").

The `modifyEntities` method will allow date values to be supplied as either a String value that matches the `dateFormat` parameter supplied in the `metadata` or as the number of seconds from the unix epoch (this value can be returned using the `NSDate` `timeIntervalSince1970` method in Cocoa). 

The `modifyEntities` method will allow date/time values to be to be supplied as either a String value that matches the `dateAndTimeFormat` parameter supplied in the `metadata` or as the number of seconds from the unix epoch (this value can be returned using the `NSDate` `timeIntervalSince1970` method in Cocoa).

The `timesAreZulu` parameter is only applicable to date/time values that are passed in as Strings. When handling local times, the `modifyEntities` method will first attempt to obtain the time zone for the applicable to or from place (depending on the attribute being set). If there is no corresponding place or it does not have a time zone associated with it, the `modifyEntities` method will attempt to use the default timezone set for LogTen Pro. If there is no default timezone configured, the `modifyEntities` method will use GMT (Zulu).

#### removeEntities

The `removeEntities` collection shall contain the `flight_key` for each `Flight` to be removed.

The following is an example of a `modifyEntities` request (prior to encoding): 

```
logten://v2/modifyEntities?package={"metadata":{"application":"My Application","version":"1.0","dateFormat":"MM/dd/yyyy","dateAndTimeFormat":"MM/dd/yyyy HH:mm","timesAreZulu":true},"entities":[{"entity_name":"Flight","flight_key":"myAppFlight_101","flight_flightDate":"12/25/2010","flight_to":"KPIT","flight_from":"KPJC","flight_pic":"1:30","flight_takeoffTime":"12/25/2010 15:50"}],"removeEntities":[{"entity_name":"Flight","flight_key":"myAppFlight_102"},{"entity_name":"Flight","flight_key":"myAppFlight_103"}]}
```

specifically:

```
{
  "entities": [
    {
      "flight_pic": "1:30", 
      "flight_takeoffTime": "12/25/2010 15:50", 
      "entity_name": "Flight", 
      "flight_flightDate": "12/25/2010", 
      "flight_from": "KPJC", 
      "flight_to": "KPIT", 
      "flight_key": "myAppFlight_101"
    }
  ], 
  "removeEntities": [
    {
      "flight_key": "myAppFlight_102", 
      "entity_name": "Flight"
    }, 
    {
      "flight_key": "myAppFlight_103", 
      "entity_name": "Flight"
    }
  ], 
  "metadata": {...}
}
```

## Appendix

### Flight Attributes

| Key                                 | Data Type  | Notes                                                                                                                                                                            |
|:------------------------------------|:-----------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| flight_actualArrivalTime            | Date       |                                                                                                                                                                                  |
| flight_actualDepartureTime          | Date       |                                                                                                                                                                                  |
| flight_actualInstrument             | Integer 32 |                                                                                                                                                                                  |
| flight_aeroTows                     | Integer 32 |                                                                                                                                                                                  |
| flight_arrests                      | Integer 32 |                                                                                                                                                                                  |
| flight_autolands                    | Integer 32 |                                                                                                                                                                                  |
| flight_bolters                      | Integer 32 |                                                                                                                                                                                  |
| flight_catapults                    | Integer 32 |                                                                                                                                                                                  |
| flight_catII                        | Integer 32 |                                                                                                                                                                                  |
| flight_catIII                       | Integer 32 |                                                                                                                                                                                  |
| flight_cloudbase                    | Integer 32 |                                                                                                                                                                                  |
| flight_commandPractice              | Integer 32 |                                                                                                                                                                                  |
| flight_crossCountry                 | Integer 32 |                                                                                                                                                                                  |
| flight_crossCountryNight            | Integer 32 |                                                                                                                                                                                  |
| flight_customCapacity1              | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity2              | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity3              | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity4              | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity5              | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity6              | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity7              | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity8              | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity9              | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity10             | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity11             | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity12             | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity13             | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity14             | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity15             | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity16             | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity17             | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity18             | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity19             | Boolean    |                                                                                                                                                                                  |
| flight_customCapacity20             | Boolean    |                                                                                                                                                                                  |
| flight_customLanding1               | Integer 32 |                                                                                                                                                                                  |
| flight_customLanding2               | Integer 32 |                                                                                                                                                                                  |
| flight_customLanding3               | Integer 32 |                                                                                                                                                                                  |
| flight_customLanding4               | Integer 32 |                                                                                                                                                                                  |
| flight_customLanding5               | Integer 32 |                                                                                                                                                                                  |
| flight_customLanding6               | Integer 32 |                                                                                                                                                                                  |
| flight_customLanding7               | Integer 32 |                                                                                                                                                                                  |
| flight_customLanding8               | Integer 32 |                                                                                                                                                                                  |
| flight_customLanding9               | Integer 32 |                                                                                                                                                                                  |
| flight_customLanding10              | Integer 32 |                                                                                                                                                                                  |
| flight_customNote1                  | String     |                                                                                                                                                                                  |
| flight_customNote2                  | String     |                                                                                                                                                                                  |
| flight_customNote3                  | String     |                                                                                                                                                                                  |
| flight_customNote4                  | String     |                                                                                                                                                                                  |
| flight_customNote5                  | String     |                                                                                                                                                                                  |
| flight_customNote6                  | String     |                                                                                                                                                                                  |
| flight_customNote7                  | String     |                                                                                                                                                                                  |
| flight_customNote8                  | String     |                                                                                                                                                                                  |
| flight_customNote9                  | String     |                                                                                                                                                                                  |
| flight_customNote10                 | String     |                                                                                                                                                                                  |
| flight_customOp1                    | Integer 32 |                                                                                                                                                                                  |
| flight_customOp2                    | Integer 32 |                                                                                                                                                                                  |
| flight_customOp3                    | Integer 32 |                                                                                                                                                                                  |
| flight_customOp4                    | Integer 32 |                                                                                                                                                                                  |
| flight_customOp5                    | Integer 32 |                                                                                                                                                                                  |
| flight_customOp6                    | Integer 32 |                                                                                                                                                                                  |
| flight_customOp7                    | Integer 32 |                                                                                                                                                                                  |
| flight_customOp8                    | Integer 32 |                                                                                                                                                                                  |
| flight_customOp9                    | Integer 32 |                                                                                                                                                                                  |
| flight_customOp10                   | Integer 32 |                                                                                                                                                                                  |
| flight_customOp11                   | Integer 32 |                                                                                                                                                                                  |
| flight_customOp12                   | Integer 32 |                                                                                                                                                                                  |
| flight_customOp13                   | Integer 32 |                                                                                                                                                                                  |
| flight_customOp14                   | Integer 32 |                                                                                                                                                                                  |
| flight_customOp15                   | Integer 32 |                                                                                                                                                                                  |
| flight_customOp16                   | Integer 32 |                                                                                                                                                                                  |
| flight_customOp17                   | Integer 32 |                                                                                                                                                                                  |
| flight_customOp18                   | Integer 32 |                                                                                                                                                                                  |
| flight_customOp19                   | Integer 32 |                                                                                                                                                                                  |
| flight_customOp20                   | Integer 32 |                                                                                                                                                                                  |
| flight_customTakeoff1               | Integer 32 |                                                                                                                                                                                  |
| flight_customTakeoff2               | Integer 32 |                                                                                                                                                                                  |
| flight_customTakeoff3               | Integer 32 |                                                                                                                                                                                  |
| flight_customTakeoff4               | Integer 32 |                                                                                                                                                                                  |
| flight_customTakeoff5               | Integer 32 |                                                                                                                                                                                  |
| flight_customTakeoff6               | Integer 32 |                                                                                                                                                                                  |
| flight_customTakeoff7               | Integer 32 |                                                                                                                                                                                  |
| flight_customTakeoff8               | Integer 32 |                                                                                                                                                                                  |
| flight_customTakeoff9               | Integer 32 |                                                                                                                                                                                  |
| flight_customTakeoff10              | Integer 32 |                                                                                                                                                                                  |
| flight_customTime1                  | Integer 32 |                                                                                                                                                                                  |
| flight_customTime2                  | Integer 32 |                                                                                                                                                                                  |
| flight_customTime3                  | Integer 32 |                                                                                                                                                                                  |
| flight_customTime4                  | Integer 32 |                                                                                                                                                                                  |
| flight_customTime5                  | Integer 32 |                                                                                                                                                                                  |
| flight_customTime6                  | Integer 32 |                                                                                                                                                                                  |
| flight_customTime7                  | Integer 32 |                                                                                                                                                                                  |
| flight_customTime8                  | Integer 32 |                                                                                                                                                                                  |
| flight_customTime9                  | Integer 32 |                                                                                                                                                                                  |
| flight_customTime10                 | Integer 32 |                                                                                                                                                                                  |
| flight_customTime11                 | Integer 32 |                                                                                                                                                                                  |
| flight_customTime12                 | Integer 32 |                                                                                                                                                                                  |
| flight_customTime13                 | Integer 32 |                                                                                                                                                                                  |
| flight_customTime14                 | Integer 32 |                                                                                                                                                                                  |
| flight_customTime15                 | Integer 32 |                                                                                                                                                                                  |
| flight_customTime16                 | Integer 32 |                                                                                                                                                                                  |
| flight_customTime17                 | Integer 32 |                                                                                                                                                                                  |
| flight_customTime18                 | Integer 32 |                                                                                                                                                                                  |
| flight_customTime19                 | Integer 32 |                                                                                                                                                                                  |
| flight_customTime20                 | Integer 32 |                                                                                                                                                                                  |
| flight_dayLandings                  | Integer 32 |                                                                                                                                                                                  |
| flight_dayTakeoffs                  | Integer 32 |                                                                                                                                                                                  |
| flight_distance                     | Float      | Normally auto calculated by LT                                                                                                                                                   |
| flight_dualGiven                    | Integer 32 |                                                                                                                                                                                  |
| flight_dualReceived                 | Integer 32 |                                                                                                                                                                                  |
| flight_dualReceivedNight            | Integer 32 |                                                                                                                                                                                  |
| flight_duration                     | Integer 32 | "Air Time" normally calcuated automatically from Off to On                                                                                                                       |
| flight_dutyTimePayRate              | Float      |                                                                                                                                                                                  |
| flight_expenses                     | Float      |                                                                                                                                                                                  |
| flight_faaPart61                    | Boolean    |                                                                                                                                                                                  |
| flight_faaPart91                    | Boolean    |                                                                                                                                                                                  |
| flight_faaPart121                   | Boolean    |                                                                                                                                                                                  |
| flight_faaPart135                   | Boolean    |                                                                                                                                                                                  |
| flight_far1                         | Boolean    |                                                                                                                                                                                  |
| flight_fcls                         | Integer 32 | A Field Carrier Landing                                                                                                                                                          |
| flight_flagged                      | Boolean    | A Flagged flight in LT will show red on the Mac                                                                                                                                  |
| flight_flightDate                   | Date       |                                                                                                                                                                                  |
| flight_flightDutyEndTime            | Date       |                                                                                                                                                                                  |
| flight_flightDutyStartTime          | Date       |                                                                                                                                                                                  |
| flight_flightDutyTotal              | Integer 32 |                                                                                                                                                                                  |
| flight_flightEngineer               | Integer 32 |                                                                                                                                                                                  |
| flight_flightEngineerCapacity       | Boolean    |                                                                                                                                                                                  |
| flight_flightNumber                 | String     |                                                                                                                                                                                  |
| flight_flightTimePayRate            | Float      |                                                                                                                                                                                  |
| flight_from                         | String     |                                                                                                                                                                                  |
| flight_fuelAdded                    | Double     |                                                                                                                                                                                  |
| flight_fuelBurned                   | Double     |                                                                                                                                                                                  |
| flight_fuelMinimumForDiversion      | Double     |                                                                                                                                                                                  |
| flight_fuelRemaining                | Double     |                                                                                                                                                                                  |
| flight_fuelTotalAboard              | Double     |                                                                                                                                                                                  |
| flight_fuelTotalBeforeUplift        | Double     |                                                                                                                                                                                  |
| flight_fuelUplift                   | Double     |                                                                                                                                                                                  |
| flight_fullStops                    | Integer 32 |                                                                                                                                                                                  |
| flight_goArounds                    | Integer 32 |                                                                                                                                                                                  |
| flight_ground                       | Integer 32 |                                                                                                                                                                                  |
| flight_groundLaunches               | Integer 32 |                                                                                                                                                                                  |
| flight_hobbsStart                   | Float      |                                                                                                                                                                                  |
| flight_hobbsStop                    | Float      |                                                                                                                                                                                  |
| flight_holds                        | Integer 32 |                                                                                                                                                                                  |
| flight_ifr                          | Integer 32 | Usually denotes time flown under an IFR flight plan.                                                                                                                             |
| flight_ifrCapacity                  | Boolean    |                                                                                                                                                                                  |
| flight_instrumentProficiencyCheck   | Boolean    |                                                                                                                                                                                  |
| flight_key                          | String     |                                                                                                                                                                                  |
| flight_landingCapacity              | Boolean    |                                                                                                                                                                                  |
| flight_landingTime                  | Date       |                                                                                                                                                                                  |
| flight_leg                          | Integer 32 | Used to order flights on the same date.                                                                                                                                          |
| flight_legCount                     | Integer 32 | Used if a single flight entity contains multiple legs.                                                                                                                           |
| flight_multiPilot                   | Integer 32 |                                                                                                                                                                                  |
| flight_night                        | Integer 32 |                                                                                                                                                                                  |
| flight_nightLandings                | Integer 32 |                                                                                                                                                                                  |
| flight_nightTakeoffs                | Integer 32 |                                                                                                                                                                                  |
| flight_nightVisionGoggle            | Integer 32 |                                                                                                                                                                                  |
| flight_nightVisionGoggleLandings    | Integer 32 |                                                                                                                                                                                  |
| flight_nightVisionGoggleTakeoffs    | Integer 32 |                                                                                                                                                                                  |
| flight_offDutyTime                  | Date       |                                                                                                                                                                                  |
| flight_onDutyTime                   | Date       |                                                                                                                                                                                  |
| flight_p1us                         | Integer 32 |                                                                                                                                                                                  |
| flight_p1usNight                    | Integer 32 |                                                                                                                                                                                  |
| flight_paxCount                     | Integer 16 |                                                                                                                                                                                  |
| flight_paxCountBusiness             | Integer 16 |                                                                                                                                                                                  |
| flight_payload                      | Double     |                                                                                                                                                                                  |
| flight_pic                          | Integer 32 |                                                                                                                                                                                  |
| flight_picCapacity                  | Boolean    |                                                                                                                                                                                  |
| flight_picNight                     | Integer 32 |                                                                                                                                                                                  |
| flight_pilotCount                   | Integer 16 |                                                                                                                                                                                  |
| flight_pilotFlyingCapacity          | Boolean    |                                                                                                                                                                                  |
| flight_poweredLaunches              | Integer 32 |                                                                                                                                                                                  |
| flight_relief                       | Integer 32 |                                                                                                                                                                                  |
| flight_reliefCrewCapacity           | Boolean    |                                                                                                                                                                                  |
| flight_reliefNight                  | Integer 32 |                                                                                                                                                                                  |
| flight_remarks                      | String     |                                                                                                                                                                                  |
| flight_rest                         | Integer 32 |                                                                                                                                                                                  |
| flight_review                       | Boolean    |                                                                                                                                                                                  |
| flight_route                        | String     |                                                                                                                                                                                  |
| flight_scheduledArrivalTime         | Date       |                                                                                                                                                                                  |
| flight_scheduledDepartureTime       | Date       |                                                                                                                                                                                  |
| flight_scheduledTimePayRate         | Float      |                                                                                                                                                                                  |
| flight_scheduledTotalTime           | Integer 32 |                                                                                                                                                                                  |
| flight_sectionName                  | String     |                                                                                                                                                                                  |
| flight_selectedAircraftClass        | String     | Will autopopulate if the `flight_selectedAircraftType` is sent as an ICAO type.                                                                                                  |
| flight_selectedAircraftID           | String     | The aircraft ID will create an entry on the "Aircraft" page unless this aircraft ID already exists.                                                                              |
| flight_selectedAircraftType         | String     | The type of the aircraft. The preferred string is the exact ICAO code of this aircraft type. An entry on the "Types" page of LT will be created unless this type already exists. |
| flight_selectedApproach1            | String     |                                                                                                                                                                                  |
| flight_selectedApproach2            | String     |                                                                                                                                                                                  |
| flight_selectedApproach3            | String     |                                                                                                                                                                                  |
| flight_selectedApproach4            | String     |                                                                                                                                                                                  |
| flight_selectedApproach5            | String     |                                                                                                                                                                                  |
| flight_selectedApproach6            | String     |                                                                                                                                                                                  |
| flight_selectedApproach7            | String     |                                                                                                                                                                                  |
| flight_selectedApproach8            | String     |                                                                                                                                                                                  |
| flight_selectedApproach9            | String     |                                                                                                                                                                                  |
| flight_selectedApproach10           | String     |                                                                                                                                                                                  |
| flight_selectedCategory             | String     |                                                                                                                                                                                  |
| flight_selectedCrewCommander        | String     |                                                                                                                                                                                  |
| flight_selectedCrewCustom1          | String     |                                                                                                                                                                                  |
| flight_selectedCrewCustom2          | String     |                                                                                                                                                                                  |
| flight_selectedCrewCustom3          | String     |                                                                                                                                                                                  |
| flight_selectedCrewCustom4          | String     |                                                                                                                                                                                  |
| flight_selectedCrewCustom5          | String     |                                                                                                                                                                                  |
| flight_selectedCrewCustom6          | String     |                                                                                                                                                                                  |
| flight_selectedCrewCustom7          | String     |                                                                                                                                                                                  |
| flight_selectedCrewCustom8          | String     |                                                                                                                                                                                  |
| flight_selectedCrewCustom9          | String     |                                                                                                                                                                                  |
| flight_selectedCrewCustom10         | String     |                                                                                                                                                                                  |
| flight_selectedCrewFlightAttendant  | String     |                                                                                                                                                                                  |
| flight_selectedCrewFlightAttendant2 | String     |                                                                                                                                                                                  |
| flight_selectedCrewFlightAttendant3 | String     |                                                                                                                                                                                  |
| flight_selectedCrewFlightAttendant4 | String     |                                                                                                                                                                                  |
| flight_selectedCrewFlightEngineer   | String     |                                                                                                                                                                                  |
| flight_selectedCrewInstructor       | String     |                                                                                                                                                                                  |
| flight_selectedCrewObserver         | String     |                                                                                                                                                                                  |
| flight_selectedCrewObserver2        | String     |                                                                                                                                                                                  |
| flight_selectedCrewPIC              | String     |                                                                                                                                                                                  |
| flight_selectedCrewPurser           | String     |                                                                                                                                                                                  |
| flight_selectedCrewRelief           | String     |                                                                                                                                                                                  |
| flight_selectedCrewRelief2          | String     |                                                                                                                                                                                  |
| flight_selectedCrewRelief3          | String     |                                                                                                                                                                                  |
| flight_selectedCrewRelief4          | String     |                                                                                                                                                                                  |
| flight_selectedCrewSIC              | String     |                                                                                                                                                                                  |
| flight_selectedCrewStudent          | String     |                                                                                                                                                                                  |
| flight_selectedEngineType           | String     | Will autopopulate if the `flight_selectedAircraftType` is sent as an ICAO type code.                                                                                             |
| flight_selectedMake                 | String     | Will autopopulate if the `flight_selectedAircraftType` is sent as an ICAO type code.                                                                                             |
| flight_selectedModel                | String     | Will autopopulate if the `flight_selectedAircraftType` is sent as an ICAO type code.                                                                                             |
| flight_sfi                          | Integer 32 | Simulator Flight Instructor                                                                                                                                                      |
| flight_shipboardLandings            | Integer 32 |                                                                                                                                                                                  |
| flight_shipboardTakeoffs            | Integer 32 |                                                                                                                                                                                  |
| flight_sic                          | Integer 32 |                                                                                                                                                                                  |
| flight_sicCapacity                  | Boolean    |                                                                                                                                                                                  |
| flight_sicNight                     | Integer 32 |                                                                                                                                                                                  |
| flight_simulatedInstrument          | Integer 32 |                                                                                                                                                                                  |
| flight_simulator                    | Integer 32 |                                                                                                                                                                                  |
| flight_sky                          | String     |                                                                                                                                                                                  |
| flight_solo                         | Integer 32 |                                                                                                                                                                                  |
| flight_tachStart                    | Float      |                                                                                                                                                                                  |
| flight_tachStop                     | Float      |                                                                                                                                                                                  |
| flight_takeoffTime                  | Date       |                                                                                                                                                                                  |
| flight_taxiInTime                   | Date       |                                                                                                                                                                                  |
| flight_taxiOutTime                  | Date       |                                                                                                                                                                                  |
| flight_to                           | String     |                                                                                                                                                                                  |
| flight_totalDutyTime                | Integer 32 |                                                                                                                                                                                  |
| flight_totalEarned                  | Float      |                                                                                                                                                                                  |
| flight_totalLandings                | Integer 32 | Normally not sent as this is not a user accessible field. The preferred fields are `flight_nightLandings` and `flight_dayLandings` which will autopopulate this field.           |
| flight_totalPushTime                | Integer 32 |                                                                                                                                                                                  |
| flight_totalTakeoffs                | Integer 32 |                                                                                                                                                                                  |
| flight_totalTime                    | Integer 32 |                                                                                                                                                                                  |
| flight_touchAndGoes                 | Integer 32 |                                                                                                                                                                                  |
| flight_type                         | Integer 32 | *See below.                                                                                                                                                                      |
| flight_underSupervisionCapacity     | Boolean    |                                                                                                                                                                                  |
| flight_useCode                      | String     |                                                                                                                                                                                  |
| flight_visibility                   | Float      |                                                                                                                                                                                  |
| flight_waterLandings                | Integer 32 |                                                                                                                                                                                  |
| flight_waterTakeoffs                | Integer 32 |                                                                                                                                                                                  |
| flight_weather                      | String     |                                                                                                                                                                                  |
| flight_windDirection                | Integer 16 |                                                                                                                                                                                  |
| flight_windVelocity                 | Integer 16 |                                                                                                                                                                                  |



***flight_type** is used to determine the type of the flight entity:

    "Flight"			= 0,
    "Positioning"		= 1,
    "Non Flying"		= 2,
    "Simulator"			= 3,
    "Airport Reserve"	= 4,
    "Airport Standby"	= 5,
    "Home Reserve"		= 6,
    "Home Standby"		= 7

*Note: For any time field, if no night times are sent then it is assumed that the times are all "day". If `flight_night` is sent with the entity then the individual night times for other fields (PIC, XC, Dual, etc.) will auto fill. In most cases there isn't a need to send the individual night times.*

### Aircraft Attributes

If specific aircraft attributes must be set then a seperate payload can be sent setting the attributes of the Aircraft. As an example, if an aircraft must be set as complex then the following payload can be sent:
```
[{"entity_name":"Aircraft","aircraft_aircraftID":"N233MJ","aircraft_complex":true}]
```

Available attributes include:

| Key                               | Data Type | Notes |
|:----------------------------------|:----------|:------|
| aircraft_aerobatic                | Boolean   |       |
| aircraft_aircraftID               | String    |       |
| aircraft_autoEngine               | String    |       |
| aircraft_complex                  | String    |       |
| aircraft_customAttribute1         | Boolean   |       |
| aircraft_customAttribute2         | Boolean   |       |
| aircraft_customAttribute3         | Boolean   |       |
| aircraft_customAttribute4         | Boolean   |       |
| aircraft_customAttribute5         | Boolean   |       |
| aircraft_customText1              | String    |       |
| aircraft_customText2              | String    |       |
| aircraft_customText3              | String    |       |
| aircraft_customText4              | String    |       |
| aircraft_customText5              | String    |       |
| aircraft_customText6              | String    |       |
| aircraft_customText7              | String    |       |
| aircraft_customText8              | String    |       |
| aircraft_efis                     | Boolean   |       |
| aircraft_enginePower              | Integer   |       |
| aircraft_experimental             | Boolean   |       |
| aircraft_fuelInjection            | Boolean   |       |
| aircraft_highPerformance          | Boolean   |       |
| aircraft_hobbs                    | Float     |       |
| aircraft_instrumentType           | String    |       |
| aircraft_military                 | Boolean   |       |
| aircraft_notes                    | String    |       |
| aircraft_paxCapacity              | Integer   |       |
| aircraft_pressurized              | Boolean   |       |
| aircraft_radialEngine             | Boolean   |       |
| aircraft_secondaryID              | String    |       |
| aircraft_serialNumber             | String    |       |
| aircraft_simAuthNumber            | String    |       |
| aircraft_simLevel                 | String    |       |
| aircraft_tachometer               | Float     |       |
| aircraft_tailwheel                | Boolean   |       |
| aircraft_technicallyAdvanced      | Boolean   |       |
| aircraft_turboCharged             | Boolean   |       |
| aircraft_undercarriageAmphib      | Boolean   |       |
| aircraft_undercarriageFloats      | Boolean   |       |
| aircraft_undercarriageRetractable | Boolean   |       |
| aircraft_undercarriageSkids       | Boolean   |       |
| aircraft_undercarriageSkis        | Boolean   |       |
| aircraft_warbird                  | Boolean   |       |
| aircraft_weight                   | Float     |       |
| aircraft_wheelConfiguration       | String    |       |
| aircraft_year                     | Date      |       |


### Document Revision History

| Date       | Notes                                                                                                                  |
|:-----------|:-----------------------------------------------------------------------------------------------------------------------|
| 2020-04-17 | Added details about proper JSON formatting and parameter encoding. Added reference links.                              |
| 2020-04-23 | Converted to Markdown                                                                                                  |
| 2022-09-01 | Added flight field details, including flight type integers and other miscellaneous  notes. Added Aircraft entity type. |

---
![Creative Commons License](https://i.creativecommons.org/l/by/4.0/88x31.png "Creative Commons License")  
LogTen Pro API by [Coradine Aviation Systems](https://coradine.com) is licensed under a [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/).
Based on a work at [https://github.com/Coradine/LogTenProAPI](https://github.com/Coradine/LogTenProAPI)

This document is written in [GFM](https://github.github.com/gfm/)  
