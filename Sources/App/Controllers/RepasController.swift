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
        // Grouping routes with JWT middleware for authentication
        let repass = routes.grouped("repas").grouped(JWTAuthMiddleware())

        repass.get(use: getAll)
        repass.post(use: create) 
        repass.delete(":repasID", use: delete) // Supprimer un repas spécifique
    }
    
    @Sendable
    func getAll(req: Request) async throws -> [RepasDTO] {
        // Récupérer l'utilisateur authentifié
        let user = try req.auth.require(User.self)

        // Récupérer uniquement les repas de cet utilisateur
        let userID = try user.requireID()
        let repas = try await Repas.query(on: req.db)
            .filter(\.$user.$id == userID)
            .all()

        var repasDTOList: [RepasDTO] = []

        for repas in repas {
            // Charger les aliments associés
            let contenus = try await Contient.query(on: req.db)
                .filter(\.$repas.$id == repas.id!)
                .with(\.$aliment)
                .all()

            // Construire un DTO pour chaque repas
            let dto = RepasDTO(
                id: try repas.requireID(),
                calorieTotal: repas.calorieTotal,
                typeRepas: repas.typeRepas,
                dateRepas: repas.dateRepas,
                aliments: contenus.map { contenu in
                    ContientDTO(
                        alimentID: try! contenu.aliment.requireID(),
                        nom: contenu.aliment.nom,
                        quantite: contenu.quantite,
                        calorie: contenu.calorie
                    )
                }
            )

            repasDTOList.append(dto)
        }

        return repasDTOList
    }
    
    @Sendable
    func create(req: Request) async throws -> HTTPStatus {
        struct CreateRepasInput: Content {
            var typeRepas: String
            var dateRepas: Date
            var aliments: [ContientInput]
        }

        struct ContientInput: Content {
            var alimentID: UUID
            var quantite: Int
        }

        let input = try req.content.decode(CreateRepasInput.self)

        // Récupérer l'utilisateur authentifié
        let user = try req.auth.require(User.self)

        // Créer le repas sans calories totales au début
        let repas = Repas(
            calorieTotal: 0,  // Initialement à zéro, on fera la somme ensuite
            typeRepas: input.typeRepas,
            dateRepas: input.dateRepas,
            userID: try user.requireID()
        )
        
        try await repas.save(on: req.db)

        // Parcourir les aliments envoyés par l'utilisateur
        var totalCalories = 0.0

        for aliment in input.aliments {
            // Rechercher l'aliment en base de données
            guard let alimentEnBase = try await Aliment.find(aliment.alimentID, on: req.db) else {
                throw Abort(.notFound, reason: "L'aliment avec l'ID \(aliment.alimentID) n'existe pas.")
            }

            // Calculer les calories pour la quantité donnée
            let calories = (Double(aliment.quantite) * Double(alimentEnBase.qteCalorie)) / 100
            totalCalories += calories

            // Créer une relation dans la table `Contient`
            let contient = Contient(
                repasID: try repas.requireID(),
                alimentID: aliment.alimentID,
                quantite: aliment.quantite,
                calorie: Int(calories)
            )
            try await contient.save(on: req.db)
        }

        // Mettre à jour les calories totales du repas
        repas.calorieTotal = totalCalories
        try await repas.update(on: req.db)

        return .created
    }
    
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let repasID = req.parameters.get("repasID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid repas ID.")
        }

        guard let repas = try await Repas.find(repasID, on: req.db) else {
            throw Abort(.notFound, reason: "Repas not found.")
        }

        try await repas.delete(on: req.db)
        return .noContent
    }
}
// test commit
