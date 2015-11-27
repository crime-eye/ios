//
//  PostcodeAPi.swift
//  CrimeEye
//
//  Created by Khen Cruzat on 26/11/2015.
//  Copyright © 2015 Gurpreet Paul. All rights reserved.
//

import Siesta

class _PostcodesAPI: Service {
    
    
    func lookupPostcode(postcode: String) -> Resource {
        return resource("/postcodes/\(postcode)")
    }
    
    init() {
        super.init(base: "http://api.postcodes.io")
    }
    
}

let PostcodesAPI = _PostcodesAPI()
