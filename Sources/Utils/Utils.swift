//
//  Utils.swift
//  AppleFanatic
//
//  Created by Anton Poltoratskyi on 23.03.17.
//
//

import MySQL

func connectToDatabase() throws -> (Database, Connection) {
    let mysql = try Database(
        host: "localhost",
        user: "database_admin",
        password: "root",
        database: "AppleFanatic"
    )
    let connection = try mysql.makeConnection()
    return (mysql, connection)
}
