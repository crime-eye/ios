//
//  PostcodeAPi.swift
//  CrimeEye
//
//  Created by Khen Cruzat on 26/11/2015.
//  Copyright © 2015 Gurpreet Paul. All rights reserved.
//

import Siesta

class _PostcodesAPI: Service {
    
    var lat: Double = 0.0
    var lng: Double = 0.0
    var postcode: String = ""
    
    func postcodeToLatAndLng(postcode: String) -> Resource {
        return resource("/postcodes").child(postcode)
    }
    
    func getPostcode(lat: Double, lng : Double) -> Resource {
        return resource("/postcodes")
            .withParam("lon", "\(lng)")
            .withParam("lat", "\(lat)")
    }
    
    func validatePostcode(postcode: String) -> Resource{
        return resource("/postcodes")
            .child(postcode)
            .child("validate")
    }
        
    init() {
        super.init(base: "http://api.postcodes.io")
    }
    
}

let PostcodesAPI = _PostcodesAPI()
