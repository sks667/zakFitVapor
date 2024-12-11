//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 05/12/2024.
//

import Foundation
import Fluent
import Vapor

final class Repas:  Model, Content, @unchecked Sendable {
    static let schema = "repas"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "calorie_total")
    var calorieTotal: Double

    @Field(key: "type_repas")
    var typeRepas: String

    @Field(key: "date_repas")
    var dateRepas: Date

    @Parent(key: "id_users")
    var user: User

    init() {}
    init(id: UUID? = nil, calorieTotal: Double, typeRepas: String, dateRepas: Date, userID: UUID) {
        self.id = id
        self.calorieTotal = calorieTotal
        self.typeRepas = typeRepas
        self.dateRepas = dateRepas
        self.$user.id = userID
    }
}
