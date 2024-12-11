//
//  userModel.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 05/12/2024.
//

import Fluent
import Vapor
import struct Foundation.UUID

final class User: Model, Content, @unchecked Sendable {
    static let schema = "user"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "nom")
    var nom: String

    @Field(key: "prenom")
    var prenom: String

    @Field(key: "taille")
    var taille: Int

    @Field(key: "email")
    var email: String

    @Field(key: "mdp")
    var mdp: String
    
    @Field(key: "poids")
    var poids: Int

    @Field(key: "preference_alimentaire")
    var preference_alimentaire: String
    
    init() {
    }
    
    init(id: UUID? = nil, nom: String, prenom: String, taille: Int, email: String, mdp: String, poids: Int, preference_alimentaire: String) {
        self.id = id
        self.nom = nom
        self.prenom = prenom
        self.taille = taille
        self.email = email
        self.mdp = mdp
        self.poids = poids
        self.preference_alimentaire = preference_alimentaire
    }
    
    func toDTO() -> UserDTO {
        .init(
            id: self.id,
            nom: self.nom,
            prenom: self.prenom,
            email: self.email,
            taille: self.taille,
            poids: self.poids,
            preference_alimentaire: self.preference_alimentaire)
    }

    
}

// Place l'extension en dehors de la classe
extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$mdp

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.mdp)
    }
}

