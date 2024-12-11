//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 05/12/2024.
//

import Foundation
import Vapor
import Fluent

final class Contient: Model, Content, @unchecked Sendable{
    static let schema = "contient"

    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "id_repas")
    var repas: Repas

    @Parent(key: "id_aliment")
    var aliment: Aliment

    @Field(key: "quantite")
    var quantite: Int

    @Field(key: "calorie")
    var calorie: Int

    init() {}
    init(repasID: UUID, alimentID: UUID, quantite: Int, calorie: Int) {
        self.$repas.id = repasID
        self.$aliment.id = alimentID
        self.quantite = quantite
        self.calorie = calorie
    }
}
