//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 05/12/2024.
//

import Foundation
import Fluent
import Vapor

struct AlimentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        
        let aliments = routes.grouped("aliment")
        let tokenAuthMiddleware = TokkenSession.authenticator()
        let guardtokenhMiddleware = TokkenSession.guardMiddleware()
        
        let authGroups = aliments.grouped(tokenAuthMiddleware, guardtokenhMiddleware)
        
        authGroups.get(use: get)
        aliments.post(use: create)
        authGroups.delete(":alimentID", use: delete)
        

        
    }
        
    @Sendable
    func get(req: Request) async throws -> [Aliment] {
        let user = try req.auth.require(User.self) // Récupérer l'utilisateur connecté
        
        // Récupérer les aliments de base (id_userr = NULL) et les aliments personnels de l'utilisateur
        return try await Aliment.query(on: req.db)
            .group(.or) { group in
                group.filter(\.$user.$id == user.id) // Aliments personnels
                group.filter(\.$user.$id == nil)    // Aliments de base
            }
            .all()
    }
        
        @Sendable
        func create (req: Request) async throws -> Aliment {
            let aliment = try req.content.decode(Aliment.self)
            try await aliment.save(on: req.db)
            return aliment
        }
    
    @Sendable
        func delete(req: Request) async throws -> HTTPStatus {
            guard let alimentID = req.parameters.get("alimentID", as: UUID.self) else {
                throw Abort(.badRequest, reason: "Invalid aliment ID.")
            }
            
            guard let aliment = try await Aliment.find(alimentID, on: req.db) else {
                throw Abort(.notFound, reason: "Aliment not found.")
            }
            
            try await aliment.delete(on: req.db)
            return .noContent 
        }
        
    
}
