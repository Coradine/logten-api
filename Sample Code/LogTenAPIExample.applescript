(*
Sample version 1.0
Coradine Aviation 2021-12-10
From https://is.gd/ltp_api

Some examples of using AppleScript to invoke the LogTen API.
Please note, LogTen must be installed for the URL handler to be recognized.
*)

on run
	tell application "Finder"
		
		-- URL Encoded
		-- Here we have the URL package pre-encoded and can use it directly
		set urlencoded_example to "logten://v2/addEntities?package=%7B%22entities%22%3A%5B%7B%22flight_flightDate%22%3A%2212%2F25%2F2010%22%2C%22flight_takeoffTime%22%3A%2212%2F25%2F2010%2015%3A50%22%2C%22flight_selectedAircraftType%22%3A%22SR22%22%2C%22flight_to%22%3A%22KSFO%22%2C%22flight_totalTime%22%3A%222%3A30%22%2C%22entity_name%22%3A%22Flight%22%2C%22flight_from%22%3A%22KPDX%22%2C%22flight_remarks%22%3A%22%5C%22Never%20interrupt%20someone%20doing%20what%20you%20said%20couldn%27t%20be%20done.%5C%22%20%5C%5C%20Amelia%20Earhart%22%7D%5D%2C%22metadata%22%3A%7B%22dateAndTimeFormat%22%3A%22MM%2Fdd%2Fyyyy%20HH%3Amm%22%2C%22timesAreZulu%22%3Atrue%2C%22application%22%3A%22MyApplication%22%2C%22dateFormat%22%3A%22MM%2Fdd%2Fyyyy%22%2C%22version%22%3A%221.0%22%7D%7D"
		-- Uncomment the following line to test
		--open location urlencoded_example
		
		-- AppleScript escape
		-- Here we have the logten URL unencoded, but we must escape double quotes properly to have it inline as AppleScript syntax:
		set applescript_escaped_example to "logten://v2/addEntities?package={\"entities\":[{\"flight_flightDate\":\"12/25/2010\",\"flight_takeoffTime\":\"12/25/2010 15:50\",\"flight_selectedAircraftType\":\"SR22\",\"flight_to\":\"KSFO\",\"flight_totalTime\":\"2:30\",\"entity_name\":\"Flight\",\"flight_from\":\"KPDX\",\"flight_remarks\":\"\\\"Never interrupt someone doing what you said couldn't be done.\\\" \\\\ Amelia Earhart\"}],\"metadata\":{\"dateAndTimeFormat\":\"MM/dd/yyyy HH:mm\",\"timesAreZulu\":true,\"application\":\"MyApplication\",\"dateFormat\":\"MM/dd/yyyy\",\"version\":\"1.0\"}}"
		-- Uncomment the following line to test
		--open location applescript_escaped_example
		
		tell me to set encodedPackage to urlEncode("{\"entities\":[{\"flight_flightDate\":\"12/25/2010\",\"flight_takeoffTime\":\"12/25/2010 15:50\",\"flight_selectedAircraftType\":\"SR22\",\"flight_to\":\"KSFO\",\"flight_totalTime\":\"2:30\",\"entity_name\":\"Flight\",\"flight_from\":\"KPDX\",\"flight_remarks\":\"\\\"Never interrupt someone doing what you said couldn't be done.\\\" \\\\ Amelia Earhart\"}],\"metadata\":{\"dateAndTimeFormat\":\"MM/dd/yyyy HH:mm\",\"timesAreZulu\":true,\"application\":\"MyApplication\",\"dateFormat\":\"MM/dd/yyyy\",\"version\":\"1.0\"}}")
		set encodedURL to "logten://v2/addEntities?package=" & encodedPackage
		-- Uncomment the following line to test
		--open location encodedURL
		
	end tell
end run

use framework "Foundation"

-- URL Encode's the given string
-- From https://stackoverflow.com/a/43562220/397210
on urlEncode(input)
	tell current application's NSString to set rawUrl to stringWithString_(input)
	set theEncodedURL to rawUrl's stringByAddingPercentEscapesUsingEncoding:4
	-- (4 is 'NSUTF8StringEncoding')
	return theEncodedURL as Unicode text
end urlEncode
