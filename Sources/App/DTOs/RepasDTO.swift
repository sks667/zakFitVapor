//
//  RepasDTO.swift
//  zakFitVapor
//
//  Created par Apprenant 178 le 02/01/2025.
//

import Foundation
import Fluent
import Vapor

/**
 `RepasDTO` est un Data Transfer Object utilisé pour transférer les données d'un repas complet.

 Ce DTO regroupe toutes les informations nécessaires sur un repas :
 - Le type de repas (exemple : "Petit-déjeuner").
 - La date du repas.
 - Le total des calories consommées.
 - La liste des aliments consommés dans le repas.

 ### Pourquoi utiliser `RepasDTO` ?

 Le `RepasDTO` permet de :
 - Regrouper les informations du repas et les aliments associés dans une seule structure.
 - Envoyer une réponse claire et complète au **front-end** pour éviter plusieurs requêtes HTTP.
 - Simplifier le traitement des données côté client, qui reçoit le total des calories et les aliments dans un seul objet.
 */
struct RepasDTO: Content {
    
    /// Identifiant unique du repas.
    var id: UUID
    
    /// Nombre total de calories consommées dans ce repas.
    var calorieTotal: Double
    
    /// Type de repas (exemple : "Petit-déjeuner", "Déjeuner", "Dîner").
    var typeRepas: String
    
    /// Date du repas.
    var dateRepas: Date
    
    /// Liste des aliments consommés dans ce repas, avec leur quantité et leurs calories.
    var aliments: [ContientDTO]
}
