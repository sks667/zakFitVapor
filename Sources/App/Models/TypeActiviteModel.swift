//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 05/12/2024.
//

import Foundation
import Vapor
import Fluent

final class TypeActivite: Model, Content, @unchecked Sendable {
    static let schema = "type_activite"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "nom_activite")
    var nomActivite: String

    @Parent(key: "id_activite")
    var activite: ActivitePhysique

    init() {}
    init(id: UUID? = nil, nomActivite: String, activiteID: UUID) {
        self.id = id
        self.nomActivite = nomActivite
        self.$activite.id = activiteID
    }
}
