//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 05/12/2024.
//

import Foundation
import Fluent
import Vapor
import JWTKit
import FluentSQL

struct AlimentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let aliments = routes.grouped("aliment").grouped(JWTAuthMiddleware())
        
        
//        let tokenAuthMiddleware = TokkenSession.authenticator()
//        let guardtokenhMiddleware = TokkenSession.guardMiddleware()
//        let authGroups = aliments.grouped(tokenAuthMiddleware, guardtokenhMiddleware)
        
        aliments.get(use: get)
        aliments.post(use: create)
        aliments.get("count", use: countAliments)
 
    }
        
    @Sendable
        func get(req: Request) async throws -> [Aliment] {
            // Récupérer l'utilisateur authentifié
            let user = try req.auth.require(User.self)
            
            // Récupérer les aliments de base et ceux de l'utilisateur
            return try await Aliment.query(on: req.db)
                .group(.or) { group in
                    group.filter(\.$user.$id == nil) // Aliments de base
                    group.filter(\.$user.$id == user.id) // Aliments personnels
                }
                .all()
        }
        
    @Sendable
    func create(req: Request) async throws -> AlimentDTO {
        // Récupérer l'utilisateur authentifié
        let user = try req.auth.require(User.self)
        
        // Décoder l'AlimentDTO depuis la requête
        let dto = try req.content.decode(AlimentDTO.self)
        
        // Créer une nouvelle instance d'Aliment
        let aliment = Aliment(
            id: nil, // L'ID sera généré automatiquement par la base de données
            nom: dto.nom,
            qteCalorie: dto.qteCalorie,
            qteGlucide: dto.qteGlucide,
            qteLipide: dto.qteLipide
        )
        
        // Associer l'aliment à l'utilisateur connecté
        aliment.$user.id = try user.requireID()
        
        // Enregistrer l'aliment dans la base de données
        try await aliment.save(on: req.db)
        
        // Retourner un DTO pour la réponse
        return AlimentDTO(
            id: aliment.id,
            nom: aliment.nom,
            qteCalorie: aliment.qteCalorie,
            qteGlucide: aliment.qteGlucide,
            qteLipide: aliment.qteLipide
        )
    }
    @Sendable
    func countAliments(req: Request) async throws -> Int {
        // Conversion de la base de données en SQLDatabase
        let sqlDb = req.db as! SQLDatabase
        
        // Requête brute pour compter les aliments
        let result = try await sqlDb.raw("SELECT COUNT(*) AS totalCount FROM aliment")
            .first(decoding: TotalCount.self)

        struct TotalCount: Decodable {
            let totalCount: Int
        }

        return result?.totalCount ?? 0
    }
        
    
}
