//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 05/12/2024.
//

import Foundation
import Fluent
import Vapor

final class ActivitePhysique: Model, Content, @unchecked Sendable {
    static let schema = "activite_physique"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "duree")
    var duree: Int

    @Field(key: "calorie_brule")
    var calorieBrule: Int

    @Parent(key: "id_user")
    var user: User

    init() {}
    init(id: UUID? = nil, duree: Int, calorieBrule: Int, userID: UUID) {
        self.id = id
        self.duree = duree
        self.calorieBrule = calorieBrule
        self.$user.id = userID
    }
}
