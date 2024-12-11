//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 05/12/2024.
//

import Foundation
import Fluent
import Vapor

struct RepasController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let repass = routes.grouped("repas")
        
        repass.get(use: get)
        repass.post(use: create)
        repass.delete(":userID", use: delete)
        
    }
        
        @Sendable
    func get(req: Request) async throws -> [Repas] {
            return try await Repas.query(on: req.db).all()
        }
        
        @Sendable
    func create (req: Request) async throws -> Repas {
            let repas = try req.content.decode(Repas.self)
        try await repas.save(on: req.db)
            return repas
        }
    
    @Sendable
        func delete(req: Request) async throws -> HTTPStatus {
            guard let repasID = req.parameters.get("repasID", as: UUID.self) else {
                throw Abort(.badRequest, reason: "Invalid repas ID.")
            }
            
            guard let repas = try await Aliment.find(repasID, on: req.db) else {
                throw Abort(.notFound, reason: "Repas not found.")
            }
            
            try await repas.delete(on: req.db)
            return .noContent
        }
        
    
}
