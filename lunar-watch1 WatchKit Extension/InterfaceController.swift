//
//  InterfaceController.swift
//  lunar-watch1 WatchKit Extension
//
//  Created by Chris Taylor on 11/8/17.
//  Copyright © 2017 Chris Taylor. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

var longitude: Double = 0.0
var latitude: Double = 0.0

class DateClass {
    var name: String
    let date = Date()
    let dateFormatter = DateFormatter()
    
    init(name: String) {
        self.name = name
    }
    
    func whatdateisit() -> String {
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: date)
    }
    
    func whattimeisit() -> String {
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
}

//Get set up to decode some JSON
struct Moon: Codable {
    let curphase: String?
    let moondata: [Moondata]?
    
    struct Moondata: Codable {
        let phen: String
        let time: String
    }
}

var secondsFromGMT: Int { return ((TimeZone.current.secondsFromGMT())/60)/60 }

class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    @IBOutlet var riseLabel: WKInterfaceLabel!
    @IBOutlet var transitLabel: WKInterfaceLabel!
    @IBOutlet var setLabel: WKInterfaceLabel!
    @IBOutlet var moonImageGrp: WKInterfaceGroup!

    var manager: CLLocationManager!
    var location: CLLocation!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        self.manager = CLLocationManager()
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.manager.distanceFilter = 10000
        self.manager.requestWhenInUseAuthorization()
        self.manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        latitude = locValue.latitude
        longitude = locValue.longitude
        doURLsessions()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Error with geolocation " + error.localizedDescription)
    }
    
    @objc func doURLsessions() {
        //Go to the USNO web service and get the rise and set times. We're just interested in the moon here.
        //See: https://aa.usno.navy.mil/data/docs/api.php#rstt
        let now = DateClass(name: "my date for now")
        let sessionMoonTime = URLSession(configuration: URLSessionConfiguration.default)
        if let timeurl = URL(string: "https://api.usno.navy.mil/rstt/oneday?date=\(now.whatdateisit())&coords=\(latitude),\(longitude)&tz=\(secondsFromGMT)") {
            (sessionMoonTime.dataTask(with: timeurl) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    //print("timeurl is \(timeurl)") //Uncomment if you want to see the web service endpoint
                    let jsonDecoder = JSONDecoder()
                    let moonresponse = try? jsonDecoder.decode(Moon.self, from: data)
                        if (moonresponse?.moondata != nil) {
                        for item in [moonresponse?.moondata] {
                            for phenitem in item! {
                                switch phenitem.phen {
                                case "R": self.riseLabel.setText(phenitem.time)
                                case "U": self.transitLabel.setText(phenitem.time)
                                case "S": self.setLabel.setText(phenitem.time)
                                default: ()
                                }
                            }
                        }
                    }
                }
            }).resume()
        }
        
        let sessionMoonImage = URLSession(configuration: URLSessionConfiguration.default)
        //Get an image of what the moon looks like now
        //See: https://aa.usno.navy.mil/data/docs/api.php#diskmap
        if let imgurl = URL(string: "https://api.usno.navy.mil/imagery/moon.png?date=\(now.whatdateisit())&time=\(now.whattimeisit())") {
            (sessionMoonImage.dataTask(with: imgurl ) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    self.moonImageGrp.setBackgroundImage(UIImage(data: data))
                }
            }).resume()
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        manager.startUpdatingLocation()
            NSLog("app in foreground")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        manager.stopUpdatingLocation()
        NSLog("app in background")
    }
 }
