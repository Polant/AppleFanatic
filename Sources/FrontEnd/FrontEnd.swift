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
    
    // MARK: - Public
    
    lazy var router: Router = {
        let router = Router()
        
        router.setDefault(templateEngine: self.createTemplateEngine())
        router.all("/static", middleware: StaticFileServer())
        router.all("/static/*") { req, res, next in
            try res.end()
        }
        router.post("/", middleware: BodyParser())
        
        router.get("/", handler: self.getHomePage)
        router.get("/:category/:id/:slug", handler: self.getStory)
        
        return router
    }()

    
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
    
    func getStory(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        guard let id = request.parameters["id"] else {
            renderError("Missing ID", response, next)
            return
        }
        guard let story = get("/story/\(id)")?.dictionaryObject else {
            renderError("Page not found", response, next)
            return
        }
        var pageContext = context(for: request)
        pageContext["title"] = story["title"] ?? ""
        pageContext["story"] = story
        try response.render("read", context: pageContext).end()
    }
}


// MARK: - Templates
extension FrontEnd {
    
    fileprivate func createTemplateEngine() -> StencilTemplateEngine {
        let namespace = Extension()
        namespace.registerFilter("link") { (value: Any?) -> Any? in
            guard let unwrapped = value as? [String: Any] else { return nil }
            
            guard let category = unwrapped["category"] as? String,
                let id = unwrapped["id"],
                let slug = unwrapped["slug"] else {
                    return value
            }
            return "/\(category.lowercased())/\(id)/\(slug)"
        }
        namespace.registerFilter("markdown") { (value: Any?) -> Any? in
            guard let unwrapped = value as? String else { return nil }
            
            let trimmed = unwrapped.replacingOccurrences(of: "\r\n", with: "\n")
            
            if let markdown = try? Markdown(string: trimmed) {
                if let htmlDocument = try? markdown.document() {
                    return htmlDocument
                }
            }
            return unwrapped
        }
        return StencilTemplateEngine(extension: namespace)
    }
}


// MARK: - Utils

extension FrontEnd {
    fileprivate func context(for request: RouterRequest) -> [String: Any] {
        var result = [String: Any]()
        return result
    }
    fileprivate func renderError(_ message: String, _ response: RouterResponse, _ next: () -> Void) {
        _ = try? response.send("Error: \(message)").end()
    }
}
