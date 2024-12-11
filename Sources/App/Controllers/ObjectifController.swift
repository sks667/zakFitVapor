//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 05/12/2024.
//

import Foundation
import Fluent
import Vapor

struct ObjectifController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let objectifs = routes.grouped("objectif")
        
        objectifs.get(use: get)
        objectifs.post(use: create)
        objectifs.delete(":objectifID", use: delete)
        
    }
        
        @Sendable
        func get(req: Request) async throws -> [Objectif] {
            return try await Objectif.query(on: req.db).all()
        }
        
        @Sendable
        func create (req: Request) async throws -> Objectif {
            let objectif = try req.content.decode(Objectif.self)
            try await objectif.save(on: req.db)
            return objectif
        }
    
    @Sendable
        func delete(req: Request) async throws -> HTTPStatus {
            guard let objectifID = req.parameters.get("objectifID", as: UUID.self) else {
                throw Abort(.badRequest, reason: "Invalid objectif ID.")
            }
            
            guard let objectif = try await Aliment.find(objectifID, on: req.db) else {
                throw Abort(.notFound, reason: "objectif not found.")
            }
            
            try await objectif.delete(on: req.db)
            return .noContent
        }
        
    
}
