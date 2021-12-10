# LogTen API Examples

Coradine Aviation 2021-12-10

Please see the [API documentation](https://is.gd/ltp_api)

---

### Overview

The LogTen API allows for multiple entities (Flights) to be added at one time using the documented 'v2' API. Additionally, but not documented or officially supported (please be sure to backup your logbook!), Person entities can also be added to the logbook.

While Flight entities have the `flight_key` concept to allow updating of existing flights, there is no similar concept for other entities (People), so a new entity will be created  with the same data for each call of the LogTen API with that entity.

One can, however, create the Person entity in one API call and then reference the Person by name using the `flight_selectedCrewPIC` (or similar crew-related) property.

### Included Files

* `LogTenAPIExample.applescript`

Includes examples of opening a LogTen API URL using AppleScript, with various encoding strategies.

* `multiple_flights_example.json`

Includes example package JSON containing multiple flights. Make note of the use of `flight_selectedCrewPIC` to identify the PIC Person in the logbook. Note, also, there are many more `flight_selected...` properties available (see the docs).

The value of the `flight_selectedCrewPIC` (and other crew related fields) should be the full name of the Person to associate with the flight.

Also note the use of the `flight_key` property to prevent multiple copies of the same flight from being added (see the docs).

* `person_example.json`

Gives an example of how to add a Person entity to the logbook. Please note this will create a new Person entry every time the LogTen API processes it; there is no conceptual equivalent to `flight_key` for other entities.

* `shell_example.sh`

A small shell script which utilizes the `jq` command line tool to properly encode the LogTen API URL with a JSON package from the given file, then instruct the OS to `open` the file with LogTen.