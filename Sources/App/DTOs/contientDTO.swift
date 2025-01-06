//
//  ContientDTO.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 02/01/2025.
//

import Foundation
import Fluent
import Vapor

/// `ContientDTO` est un Data Transfer Object (DTO) utilisé pour transférer les données d'une relation "repas-aliment".
///
/// Ce DTO représente un aliment ajouté dans un repas avec sa quantité consommée et les calories associées.
struct ContientDTO: Content {
    
    /// Identifiant de l'aliment ajouté au repas.
    var alimentID: UUID
    
    /// Nom de l'aliment (par exemple "Poulet", "Riz").
    var nom: String
    
    /// Quantité de l'aliment consommée (en grammes).
    var quantite: Int
    
    /// Nombre total de calories calculé pour la quantité consommée.
    var calorie: Int
}
