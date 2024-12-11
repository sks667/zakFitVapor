//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 06/12/2024.
//

import Foundation
import Fluent
import Vapor

struct ContientController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let contients = routes.grouped("contient")
        
        contients.get(use: get)
        contients.post(use: create)
        contients.delete(":contientID", use: delete)
        
    }
        
        @Sendable
    func get(req: Request) async throws -> [Contient] {
            return try await Contient.query(on: req.db).all()
        }
        
        @Sendable
        func create (req: Request) async throws -> Contient {
            let contient = try req.content.decode(Contient.self)
            try await contient.save(on: req.db)
            return contient
        }
    
    @Sendable
        func delete(req: Request) async throws -> HTTPStatus {
            guard let contientID = req.parameters.get("contientID", as: UUID.self) else {
                throw Abort(.badRequest, reason: "Invalid contient ID.")
            }
            
            guard let contient = try await Contient.find(contientID, on: req.db) else {
                throw Abort(.notFound, reason: "Aliment not found.")
            }
            
            try await contient.delete(on: req.db)
            return .noContent
        }
        
    
}
