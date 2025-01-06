//
//  Contient.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 05/12/2024.
//

import Foundation
import Vapor
import Fluent

/// Représente une relation entre un repas et un aliment.
///
/// Ce modèle stocke les informations sur la quantité d'un aliment dans un repas spécifique et les calories associées.
final class Contient: Model, Content, @unchecked Sendable {
    
    /// Nom de la table dans la base de données.
    static let schema = "contient"

    // MARK: - Propriétés

    /// Identifiant unique de la relation (UUID).
    @ID(key: .id)
    var id: UUID?

    /// Repas associé à cette relation (clé étrangère vers la table `repas`).
    @Parent(key: "id_repas")
    var repas: Repas

    /// Aliment associé à cette relation (clé étrangère vers la table `aliment`).
    @Parent(key: "id_aliment")
    var aliment: Aliment

    /// Quantité de l'aliment dans le repas (en grammes).
    @Field(key: "quantite")
    var quantite: Int

    /// Nombre de calories calculé pour cette quantité d'aliment.
    @Field(key: "calorie")
    var calorie: Int

    // MARK: - Initialisateurs

    /// Initialisateur vide requis par Fluent.
    init() {}

    /**
     Initialisateur principal pour créer une nouvelle relation "Contient".
     
     - Parameters:
        - repasID: Identifiant du repas.
        - alimentID: Identifiant de l'aliment.
        - quantite: Quantité de l'aliment en grammes.
        - calorie: Nombre total de calories pour cette quantité d'aliment.
     */
    init(repasID: UUID, alimentID: UUID, quantite: Int, calorie: Int) {
        self.$repas.id = repasID
        self.$aliment.id = alimentID
        self.quantite = quantite
        self.calorie = calorie
    }
}
