#import <Foundation/Foundation.h>
// Sample version 1.1
// April 17, 2020
// From https://is.gd/ltp_api

@interface LTPAPISampleCode : NSObject
@end

@implementation LTPAPISampleCode

- (NSURL *)generateLTPAPIRequestURL
{
	NSURL *retVal = nil;
	
	// Generate the JSON payload dictionary
	NSMutableDictionary *jsonPayload = [NSMutableDictionary dictionary];

	// Per the LogTen Pro API spec, the API request must always contain the
	// application and it's version number.
	NSDictionary *metadata = @{
		@"application" : @"My Application",
		@"version" : @"1.0",
		@"dateFormat" : @"MM/dd/yyyy",
		@"dateAndTimeFormat" : @"MM/dd/yyyy HH:mm",
		@"timesAreZulu" : @YES
	};

	// Add the metadata to the payload
	[jsonPayload setObject:metadata forKey:@"metadata"];

	NSMutableArray *entities = [NSMutableArray array];
	NSDictionary *entity1 = @{
		@"entity_name" : @"Flight",
		@"flight_flightDate" : @"12/25/2010",
		@"flight_from" : @"KPDX",
		@"flight_to" : @"KSFO",
		@"flight_totalTime" : @"2:30",
		@"flight_takeoffTime" : @"12/25/2010 15:50",
		@"flight_selectedAircraftType" : @"SR22",
		@"flight_remarks" : @"\"Never interrupt someone doing what you said couldn't be done.\" \\ Amelia Earhart"
	};
	[entities addObject:entity1];
	
	[jsonPayload setObject:entities forKey:@"entities"];
		
	if ([NSJSONSerialization isValidJSONObject:jsonPayload]) {
		__autoreleasing NSError *error = nil;
		NSData *jsonPayloadData = [NSJSONSerialization dataWithJSONObject:jsonPayload options:0 error:&error];
		if (jsonPayloadData) {
			NSString *payload = [[NSString alloc] initWithData:jsonPayloadData encoding:NSUTF8StringEncoding];

			NSString * const urlScheme = @"logtenprox";
			NSUInteger const logTenProAPIVersion = 2;
			NSString * const method = @"addEntities";

			NSString *encodedMethod = [method stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];

			// Create the base URL
			NSString *apiURLString = [NSString stringWithFormat:@"%@://v%lu/%@", urlScheme, (unsigned long)logTenProAPIVersion, encodedMethod];
			
			// Add the JSON package
			NSURLComponents *components = [NSURLComponents componentsWithString:apiURLString];
			NSURLQueryItem *queryItem1 = [NSURLQueryItem queryItemWithName:@"package" value:payload];
			[components setQueryItems:@[queryItem1]];

			retVal = [components URL];
		}
		else {
			NSLog(@"Unable to serialize object to JSON data. Error: %@", error);
		}
	}
	else {
		NSLog(@"Invalid JSON object: %@", jsonPayload);
	}
	
	return retVal;
}

@end

int main(int argc, char *argv[]) {
	@autoreleasepool {
		LTPAPISampleCode *sample = [[LTPAPISampleCode alloc] init];
		NSURL *ltpURL = [sample generateLTPAPIRequestURL];
		NSLog(@"%@", ltpURL);
	}
}
