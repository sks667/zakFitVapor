//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 05/12/2024.
//

import Foundation
import Fluent
import Vapor

struct TypeActController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let types = routes.grouped("type")
        
        types.get(use: get)
        types.post(use: create)
        types.delete(":userID", use: delete)
        
    }
        
        @Sendable
    func get(req: Request) async throws -> [TypeActivite] {
            return try await TypeActivite.query(on: req.db).all()
        }
        
        @Sendable
        func create (req: Request) async throws -> TypeActivite {
            let type = try req.content.decode(TypeActivite.self)
            try await type.save(on: req.db)
            return type
        }
    
    @Sendable
        func delete(req: Request) async throws -> HTTPStatus {
            guard let typeID = req.parameters.get("TypeID", as: UUID.self) else {
                throw Abort(.badRequest, reason: "Invalid type ID.")
            }
            
            guard let type = try await Aliment.find(typeID, on: req.db) else {
                throw Abort(.notFound, reason: "TypeActivite not found.")
            }
            
            try await type.delete(on: req.db)
            return .noContent
        }
        
    
}
