//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 08/12/2024.
//

import JWTKit
import Vapor

struct TokkenSession: Content, Authenticatable, JWTPayload{
    var expirationTime: TimeInterval = 60 * 10
    
    // token Data
    var expiration: ExpirationClaim
    var userId: UUID
    
    init(with user: User) throws {
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
        self.userId = try user.requireID()
    }
    func verify(using algorithm: some JWTAlgorithm) throws {
        try expiration.verifyNotExpired()
    }
}


