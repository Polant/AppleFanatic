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
        router.get("/stories", handler: self.getAllStories)
        router.get("/story/:id", handler: self.getStory)
        
        router.get("/categories", handler: self.getAllCategories)
        
        return router
    }()
    
    func getAllStories(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        let (db, connection) = try connectToDatabase()
        let query = "SELECT p.`id`, `title`, `strap`, c.`name` AS `category`, `slug`, `date` FROM `posts` p, `categories` c WHERE p.`category` = c.`id` ORDER BY `date` DESC;"
        
        let posts = try db.execute(query, [], connection)

        let parsedPosts = posts.map { post -> [String: Any] in
            
            var postDictionary = [String: Any]()
            
            postDictionary["id"] = post["id"]?.int
            postDictionary["title"] = post["title"]?.string
            postDictionary["strap"] = post["strap"]?.string
            postDictionary["category"] = post["category"]?.string
            postDictionary["slug"] = post["slug"]?.string
            postDictionary["date"] = post["date"]?.string
            
            return postDictionary
        }
        response.status(.OK).send(json: JSON(parsedPosts))
    }
    
    func getStory(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        // Ensure a story was requested
        guard let storyID = request.parameters["id"] else {
            response.status(.badRequest).send("Missing story ID.")
            return
        }
        
        let (db, connection) = try connectToDatabase()
        let query = "SELECT p.`id`, `title`, `strap`, `content`, c.`name` AS `category`, `slug`, `date` FROM `posts` p, `categories` c WHERE p.`category` = c.`id` AND p.`id` = ?;"
        
        let posts = try db.execute(query, [storyID], connection)
        
        // If we got nothing back, return a 404
        guard let post = posts.first else {
            response.status(.notFound).send("Unknown story ID.")
            return
        }
        
        var postDictionary = [String: Any]()
        
        postDictionary["id"] = post["id"]?.int
        postDictionary["title"] = post["title"]?.string
        postDictionary["strap"] = post["strap"]?.string
        postDictionary["content"] = post["content"]?.string
        postDictionary["category"] = post["category"]?.string
        postDictionary["slug"] = post["slug"]?.string
        postDictionary["date"] = post["date"]?.string
        
        response.status(.OK).send(json: JSON(postDictionary))
    }
    
    func getAllCategories(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
        defer { next() }
        
        let (db, connection) = try connectToDatabase()
        let query = "SELECT `name` FROM `categories` ORDER BY `name`;"
        
        let categories = try db.execute(query, [], connection)
        let categoryNames = categories.flatMap { $0["name"]?.string }
        
        response.status(.OK).send(json: JSON(categoryNames))
    }
    
}

