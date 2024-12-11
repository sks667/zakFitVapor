//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 05/12/2024.
//

import Foundation
import Fluent
import Vapor

struct ActiviteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let activites = routes.grouped("activite")
        
        activites.get(use: get)
        activites.post(use: create)
        activites.delete(":alimentID", use: delete)
        
    }
        
        @Sendable
        func get(req: Request) async throws -> [ActivitePhysique] {
            return try await ActivitePhysique.query(on: req.db).all()
        }
        
        @Sendable
        func create (req: Request) async throws -> ActivitePhysique {
            let activite = try req.content.decode(ActivitePhysique.self)
            try await activite.save(on: req.db)
            return activite
        }
    
    @Sendable
        func delete(req: Request) async throws -> HTTPStatus {
            guard let activiteID = req.parameters.get("activiteID", as: UUID.self) else {
                throw Abort(.badRequest, reason: "Invalid activite ID.")
            }
            
            guard let activite = try await Aliment.find(activiteID, on: req.db) else {
                throw Abort(.notFound, reason: "Aliment not found.")
            }
            
            try await activite.delete(on: req.db)
            return .noContent
        }
        
    
}
