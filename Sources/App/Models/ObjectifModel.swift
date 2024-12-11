//
//  File 2.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 05/12/2024.
//

import Foundation
import Vapor
import Fluent

final class Objectif: Model, Content, @unchecked Sendable{
    static let schema = "objectif"

    @ID(custom: "id", generatedBy: .user)
    var id: UUID?

    @Field(key: "type_objectif")
    var typeObjectif: String

    @Field(key: "valeur_objectif")
    var valeurObjectif: Int

    @Field(key: "date_debut")
    var dateDebut: Date

    @Field(key: "date_fin")
    var dateFin: Date

    @Parent(key: "id_user")
    var user: User

    init() {}
    init(id: UUID? = nil, typeObjectif: String, valeurObjectif: Int, dateDebut: Date, dateFin: Date, userID: UUID) {
        self.id = id
        self.typeObjectif = typeObjectif
        self.valeurObjectif = valeurObjectif
        self.dateDebut = dateDebut
        self.dateFin = dateFin
        self.$user.id = userID
    }
}
