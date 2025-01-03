//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 02/01/2025.
//

import Foundation
import Fluent
import Vapor

struct RepasDTO: Content {
    
    var id: UUID
    var calorieTotal: Double
    var typeRepas: String
    var dateRepas: Date
    var aliments: [ContientDTO]
}
