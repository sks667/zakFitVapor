//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 02/01/2025.
//

import Foundation
import Vapor

struct AlimentDTO: Content {
    
    var id: UUID?

    var nom: String

    var qteCalorie: Int

    var qteGlucide: Int

    var qteLipide: Int
    
}
