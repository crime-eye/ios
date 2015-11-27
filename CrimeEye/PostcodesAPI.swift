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
    
    func postcodeToLatAndLng(postcode: String) -> Resource {
        return resource("/postcodes").child(postcode)
    }
    
    init() {
        super.init(base: "http://api.postcodes.io")
    }
    
}

let PostcodesAPI = _PostcodesAPI()
