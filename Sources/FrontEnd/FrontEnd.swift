//
//  FrontEnd.swift
//  AppleFanatic
//
//  Created by Anton Poltoratskyi on 22.03.17.
//
//

import Foundation
import Kitura
import KituraNet
import KituraStencil
import Markdown
import Stencil
import SwiftyJSON
import SwiftSlug

class FrontEnd {
    
    lazy var router: Router = {
        let router = Router()
        
        router.setDefault(templateEngine: self.createTemplateEngine())
        router.post("/", middleware: BodyParser())
        
        return router
    }()
    
    private func createTemplateEngine() -> StencilTemplateEngine {
        let namespace = Extension()
        return StencilTemplateEngine(extension: namespace)
    }
}
