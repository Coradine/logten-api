import Foundation
// Sample version 1.1
// April 17, 2020
// From https://is.gd/ltp_api

// This top level code executes the sample from the Swift REPL when executed as a shell script or playground
// To execute, enter the command below in a Terminal at the location of this file:
//
// /usr/bin/swift LTPAPISampleCode.swift

let sample = LTPAPISampleCode()
let url = sample.generateLTPAPIRequestURL()

if let url = url {
	print("\(url)")
}

class LTPAPISampleCode {
    // MARK: - Properties
    let method = "addEntities"

    // MARK: - Public API
    func generateLTPAPIRequestURL() -> URL? {
        // Generate the JSON payload dictionary
        var jsonPayload = [String: Any]()

        // Add the metadata to the payload
        jsonPayload["metadata"] = configureMetadata()
        var entities = [[String: Any]]()
        entities.append(configureEntity())

        // Add entities to the payload
        jsonPayload["entities"] = entities

        // Convert the jsonPayload into a string we add to the URL
        guard let payload = payloadString(for: jsonPayload),
            let encodedMethod = method.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
                print("Payload creation failed: \(jsonPayload)")
                return nil
        }

        // Create the base URL
        let apiURLString = configureApiURLStringWith(encodedMethod: encodedMethod)

        guard var urlComponents = URLComponents(string: apiURLString) else {
            print("Unable to serialize object to JSON data.")
            return nil
        }

        // Add the JSON package
        urlComponents.queryItems = [URLQueryItem(name: "package", value: payload)]
        return urlComponents.url
    }
}

private extension LTPAPISampleCode {
    func payloadString(for jsonPayload: [String: Any]) -> String? {
        guard JSONSerialization.isValidJSONObject(jsonPayload) else {
            print("Invalid JSON object: \(jsonPayload)")
            return nil
        }

        do {
            let jsonPayloadData = try JSONSerialization.data(withJSONObject: jsonPayload)

            guard let payload = String(bytes: jsonPayloadData, encoding: .utf8) else {
                return nil
            }
			print("payload: \"\(payload)")

            return payload
        } catch {
            print(String(describing: error))
            return nil
        }
    }

    func configureMetadata() -> [String: Any] {
        return [
            "application": "My Application",
            "version": "1.0",
            "dateFormat": "MM/dd/yyyy",
            "dateAndTimeFormat": "MM/dd/yyyy HH:mm",
            "timesAreZulu": true
        ]
    }

    func configureEntity() -> [String: Any] {
        return [
            "entity_name": "Flight",
            "flight_flightDate": "12/25/2010",
            "flight_from": "KPDX",
            "flight_to": "KSFO",
            "flight_totalTime": "2:30",
            "flight_takeoffTime": "12/25/2010 15:50",
            "flight_selectedAircraftType": "SR22",
			"flight_remarks": "\"Never interrupt someone doing what you said couldn't be done.\" \\ Amelia Earhart"
        ]
    }

    func configureApiURLStringWith(encodedMethod: String) -> String {
        let urlScheme = "logtenpro"
        let logTenProAPIVersion = 2

        return "\(urlScheme)://v\(logTenProAPIVersion)/\(encodedMethod)"
    }
}
