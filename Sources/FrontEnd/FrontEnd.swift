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
    
    let baseApiURL = URL(string: "http://localhost:8089")
    
    lazy var router: Router = {
        let router = Router()
        
        router.setDefault(templateEngine: self.createTemplateEngine())
        router.all("/static", middleware: StaticFileServer())
        router.post("/", middleware: BodyParser())
        
        router.get("/", handler: self.getHomePage)
        
        return router
    }()
    
    private func createTemplateEngine() -> StencilTemplateEngine {
        let namespace = Extension()
        return StencilTemplateEngine(extension: namespace)
    }
    
    func context(for request: RouterRequest) -> [String: Any] {
        var result = [String: Any]()
        return result
    }
    
    // MARK: - HTTP
    
    func get(_ path: String) -> JSON? {
        return fetch(path, method: "GET", body: "")
    }
    
    func post(_ path: String, fields: [String: Any]) -> JSON? {
        let string = JSON(fields).rawString() ?? ""
        return fetch(path, method: "POST", body: string)
    }
    
    func fetch(_ path: String, method: String, body requestBody: String) -> JSON? {
        
        guard let scheme = baseApiURL?.scheme,
            let host = baseApiURL?.host,
            let portNumber = baseApiURL?.port else {
                return nil
        }
        let port = Int16(portNumber)
        
        var requestOptions: [ClientRequest.Options] = []
        
        requestOptions.append(.schema("\(scheme)"))
        requestOptions.append(.hostname("\(host)"))
        requestOptions.append(.port(port))
        requestOptions.append(.method("\(method)"))
        requestOptions.append(.path("\(path)"))
        
        let headers = ["Content-Type": "application/json"]
        requestOptions.append(.headers(headers))
        
        var responseBody = Data()
        
        let request = HTTP.request(requestOptions) { clientResponse in
            if let response = clientResponse {
                guard response.statusCode == .OK else { return }
                _ = try? response.readAllData(into: &responseBody)
            }
        }
        
        // Send the request
        request.end(requestBody)
        
        return !responseBody.isEmpty ? JSON(data: responseBody) : nil
    }
    
    
    // MARK: - Routes
    
    func getHomePage(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        var pageContext = self.context(for: request)
        pageContext["title"] = "Top Stories"
        pageContext["stories"] = self.get("/stories")?.arrayObject
        
        try response.render("home", context: pageContext)
    }
}
