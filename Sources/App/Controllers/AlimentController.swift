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
        // Groupe de routes protégées par l'authentification JWT
        let aliments = routes.grouped("aliment").grouped(JWTAuthMiddleware())
        
        
//        let tokenAuthMiddleware = TokkenSession.authenticator()
//        let guardtokenhMiddleware = TokkenSession.guardMiddleware()
//        let authGroups = aliments.grouped(tokenAuthMiddleware, guardtokenhMiddleware)
        
        aliments.get(use: get)
        aliments.post(use: create)
        aliments.get("count", use: countAliments)
 
    }
        
    /**
         Récupération des aliments pour l'utilisateur authentifié.
         
         Cette fonction retourne une liste d'aliments comprenant :
         - Les aliments standards (qui ne sont pas associés à un utilisateur spécifique).
         - Les aliments personnalisés de l'utilisateur connecté.
         
         - Parameter req: La requête HTTP contenant l'utilisateur authentifié.
         - Returns: Une liste d'aliments (`[Aliment]`).
         - Throws: Une erreur si l'utilisateur n'est pas authentifié ou si la récupération échoue.
         */
        @Sendable
        func get(req: Request) async throws -> [Aliment] {
            let user = try req.auth.require(User.self) // Récupération de l'utilisateur
            return try await Aliment.query(on: req.db)
                .group(.or) { group in
                    group.filter(\.$user.$id == nil) // Aliments standards
                    group.filter(\.$user.$id == user.id) // Aliments de l'utilisateur
                }
                .all()
        }
        
        /**
         Création d'un nouvel aliment pour l'utilisateur authentifié.
         
         Cette fonction permet à un utilisateur d'ajouter un aliment personnalisé à sa liste.
         
         - Parameter req: La requête HTTP contenant le corps JSON de l'aliment à créer.
         - Returns: Un objet `AlimentDTO` représentant l'aliment ajouté.
         - Throws: Une erreur si la création ou la sauvegarde échoue.
         */
        @Sendable
        func create(req: Request) async throws -> AlimentDTO {
            let user = try req.auth.require(User.self)
            let dto = try req.content.decode(AlimentDTO.self) // Décodage du DTO depuis la requête
            
            let aliment = Aliment(
                id: nil,
                nom: dto.nom,
                qteCalorie: dto.qteCalorie,
                qteGlucide: dto.qteGlucide,
                qteLipide: dto.qteLipide
            )
            
            aliment.$user.id = try user.requireID() // Association de l'aliment à l'utilisateur connecté
            try await aliment.save(on: req.db) // Enregistrement de l'aliment en base de données
            
            return AlimentDTO(
                id: aliment.id,
                nom: aliment.nom,
                qteCalorie: aliment.qteCalorie,
                qteGlucide: aliment.qteGlucide,
                qteLipide: aliment.qteLipide
            )
        }
        
        /**
         Requête SQL pour compter le nombre total d'aliments enregistrés.
         
         - Parameter req: La requête HTTP.
         - Returns: Le nombre total d'aliments dans la table `aliment`.
         - Throws: Une erreur si la requête SQL échoue.
         
         - Important: Cette requête ne filtre pas les aliments par utilisateur.
         */
        @Sendable
        func countAliments(req: Request) async throws -> Int {
            let sqlDb = req.db as! SQLDatabase
            
            let result = try await sqlDb.raw("SELECT COUNT(*) AS totalCount FROM aliment")
                .first(decoding: TotalCount.self)
            
            struct TotalCount: Decodable {
                let totalCount: Int
            }

            return result?.totalCount ?? 0
        }
    }
