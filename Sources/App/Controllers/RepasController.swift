//
//  RepasController.swift
//  zakFitVapor
//
//  Created by Apprenant 178 le 05/12/2024.
//

import Foundation
import Fluent
import Vapor

/// `RepasController` est responsable de la gestion des requêtes HTTP liées aux repas.
///
/// Ce contrôleur offre plusieurs fonctionnalités :
/// - Récupérer tous les repas d'un utilisateur.
/// - Ajouter un nouveau repas avec des aliments.
/// - Supprimer un repas spécifique.
struct RepasController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        // Groupe de routes protégées par l'authentification JWT
        let repass = routes.grouped("repas").grouped(JWTAuthMiddleware())

        repass.get(use: getAll)
        repass.post(use: create)
        repass.delete(":repasID", use: delete) 
    }
    
    /**
     ## `getAll(req:)`
     
     Récupère tous les repas de l'utilisateur authentifié.
     
     - Parameter req: La requête HTTP contenant le JWT pour identifier l'utilisateur.
     - Returns: Une liste de `RepasDTO`, contenant le type de repas, la date, les calories et les aliments associés.
     - Throws: Une erreur si l'utilisateur n'est pas authentifié ou si la récupération échoue.
     */
    @Sendable
    func getAll(req: Request) async throws -> [RepasDTO] {
        let user = try req.auth.require(User.self) // Récupération de l'utilisateur authentifié
        let userID = try user.requireID()

        // Requête pour récupérer les repas de cet utilisateur
        let repas = try await Repas.query(on: req.db)
            .filter(\.$user.$id == userID)
            .all()

        var repasDTOList: [RepasDTO] = []

        for repas in repas {
            // Charger les aliments associés à chaque repas
            let contenus = try await Contient.query(on: req.db)
                .filter(\.$repas.$id == repas.id!)
                .with(\.$aliment)
                .all()

            // Créer un `RepasDTO` pour chaque repas
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
    
    /**
     ## `create(req:)`
     
     Crée un nouveau repas pour l'utilisateur connecté.
     
     Cette fonction reçoit un `CreateRepasInput`, contenant :
     - Le type de repas (Petit-déjeuner, Déjeuner, Dîner, etc.).
     - La date du repas.
     - Une liste d'aliments avec leur quantité consommée.
     
     - Parameter req: La requête HTTP contenant les informations du repas et l'utilisateur.
     - Returns: Un `HTTPStatus` indiquant si le repas a été ajouté avec succès.
     - Throws: Une erreur si un aliment n'existe pas ou si la requête échoue.
     */
    @Sendable
    func create(req: Request) async throws -> HTTPStatus {
        struct CreateRepasInput: Content {
            var typeRepas: String
            var dateRepas: Date
            var aliments: [ContientInput] // Aliments ajoutés dans le repas
        }

        struct ContientInput: Content {
            var alimentID: UUID
            var quantite: Int
        }

        let input = try req.content.decode(CreateRepasInput.self) // Décodage du corps de la requête
        let user = try req.auth.require(User.self) // Utilisateur authentifié

        // Création du repas avec calories à zéro
        let repas = Repas(
            calorieTotal: 0,
            typeRepas: input.typeRepas,
            dateRepas: input.dateRepas,
            userID: try user.requireID()
        )
        
        try await repas.save(on: req.db)

        // Calcul des calories pour chaque aliment ajouté
        var totalCalories = 0.0

        for aliment in input.aliments {
            guard let alimentEnBase = try await Aliment.find(aliment.alimentID, on: req.db) else {
                throw Abort(.notFound, reason: "L'aliment avec l'ID \(aliment.alimentID) n'existe pas.")
            }

            let calories = (Double(aliment.quantite) * Double(alimentEnBase.qteCalorie)) / 100
            totalCalories += calories

            let contient = Contient(
                repasID: try repas.requireID(),
                alimentID: aliment.alimentID,
                quantite: aliment.quantite,
                calorie: Int(calories)
            )
            try await contient.save(on: req.db)
        }

        // Mise à jour des calories totales dans le repas
        repas.calorieTotal = totalCalories
        try await repas.update(on: req.db)

        return .created
    }
    
    /**
     ## `delete(req:)`
     
     Supprime un repas spécifique de la base de données.
     
     - Parameter req: La requête HTTP contenant l'identifiant du repas à supprimer.
     - Returns: Un `HTTPStatus` `.noContent` si le repas a été supprimé avec succès.
     - Throws: Une erreur si l'identifiant est invalide ou si le repas n'existe pas.
     */
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
