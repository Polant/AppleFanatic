import Foundation
import Kitura
import HeliumLogger
import LoggerAPI

HeliumLogger.use()

let (db, connection) = try connectToDatabase()

let router = Router()

let backend = BackEnd()
let frontend = FrontEnd()

Kitura.addHTTPServer(onPort: 8089, with: backend.router)
let frontendServer = Kitura.addHTTPServer(onPort: 8090, with: frontend.router)

frontendServer.started { [unowned frontend] in
    frontend.loadCategories()
}

Kitura.run()
