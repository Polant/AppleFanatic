//
//  Database+SingleQuery.swift
//  AppleFanatic
//
//  Created by Anton Poltoratskyi on 26.03.17.
//
//

import Foundation
import MySQL

extension Database {
    func singleQuery(_ query: String, _ values: [NodeRepresentable] = [], _ connection: Connection? = nil) -> Node? {
        do {
            return try self.execute(query, values, connection).first?.first?.value
        } catch {
            return nil
        }
    }
}
