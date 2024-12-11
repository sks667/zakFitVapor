//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 05/12/2024.
//
import Foundation
import Fluent
import Vapor

final class Aliment: Model, Content, @unchecked Sendable{
    static let schema = "aliment"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "nom")
    var nom: String

    @Field(key: "qte_calorie")
    var qteCalorie: Int

    @Field(key: "qte_glucide")
    var qteGlucide: Int

    @Field(key: "qte_lipide")
    var qteLipide: Int

    init() {}
    init(id: UUID? = nil, nom: String, qteCalorie: Int, qteGlucide: Int, qteLipide: Int) {
        self.id = id
        self.nom = nom
        self.qteCalorie = qteCalorie
        self.qteGlucide = qteGlucide
        self.qteLipide = qteLipide
    }
}
