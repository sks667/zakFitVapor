//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 02/01/2025.
//
import Foundation
import Fluent
import Vapor


struct ContientDTO: Content{
    
    var alimentID: UUID
    var nom: String
    var quantite: Int
    var calorie: Int
}
