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
}

