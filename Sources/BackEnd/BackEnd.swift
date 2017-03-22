//
//  BackEnd.swift
//  AppleFanatic
//
//  Created by Anton Poltoratskyi on 22.03.17.
//
//

import Foundation
import Kitura
import KituraNet
import HeliumLogger
import LoggerAPI
import MySQL
import SwiftyJSON

class BackEnd {
    
    lazy var router: Router = {
        let router = Router()
        
        router.post("/", middleware: BodyParser())
        
        return router
    }()
}
