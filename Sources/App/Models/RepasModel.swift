//
//  Repas.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 05/12/2024.
//

import Foundation
import Fluent
import Vapor

/// Représente un repas enregistré par l'utilisateur.
///
/// Ce modèle stocke les informations liées aux repas pris par l'utilisateur, telles que le type de repas, la date, et le nombre total de calories.
final class Repas: Model, Content, @unchecked Sendable {
    
    /// Nom de la table dans la base de données.
    static let schema = "repas"
    
    // MARK: - Propriétés
    
    /// Identifiant unique du repas (UUID).
    @ID(key: .id)
    var id: UUID?
    
    /// Nombre total de calories pour ce repas.
    @Field(key: "calorie_total")
    var calorieTotal: Double
    
    /// Type de repas (exemple : "Petit-déjeuner", "Déjeuner", "Dîner").
    @Field(key: "type_repas")
    var typeRepas: String
    
    /// Date du repas (exemple : 04 janvier 2025).
    @Field(key: "date_repas")
    var dateRepas: Date
    
    /// Utilisateur associé à ce repas (relation `Parent`).
    @Parent(key: "id_users")
    var user: User
    
    // MARK: - Initialisateurs
    
    /// Initialisateur vide requis par Fluent.
    init() {}
    
    /**
     Initialisateur principal pour créer un nouveau repas.
     
     - Parameters:
        - id: Identifiant unique du repas (optionnel).
        - calorieTotal: Nombre total de calories pour ce repas.
        - typeRepas: Type de repas (exemple : "Déjeuner").
        - dateRepas: Date à laquelle le repas a été pris.
        - userID: Identifiant de l'utilisateur associé à ce repas.
     */
    init(id: UUID? = nil, calorieTotal: Double, typeRepas: String, dateRepas: Date, userID: UUID) {
        self.id = id
        self.calorieTotal = calorieTotal
        self.typeRepas = typeRepas
        self.dateRepas = dateRepas
        self.$user.id = userID
    }
}
