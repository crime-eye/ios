//
//  PoliceAPI.swift
//  CrimeEye
//
//  Created by Gurpreet Paul on 25/11/2015.
//  Copyright © 2015 Gurpreet Paul. All rights reserved.
//

import Siesta

class _PoliceAPI: Service {
    
    
    
    var lastUpdated: Resource {
        return resource("/crime-last-updated")
    }
    
    init() {
        super.init(base: "https://data.police.uk/api")
    }
    
}

let PoliceAPI = _PoliceAPI()