//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 08/12/2024.
//

import Foundation
import Fluent
import Vapor

struct UserDTO: Content {
    
    var id: UUID?
    var nom: String
    var prenom: String
    var email: String
    var taille: Int
    var poids: Int
    var preference_alimentaire: String
    
    func convertToPublic() -> UserDTO {
        return UserDTO(id: id, nom: nom, prenom: prenom, email: email, taille: taille, poids: poids, preference_alimentaire: preference_alimentaire)
    }
}
