//
//  JWTAuthMiddleware.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 02/01/2025.
//

import JWT
import Vapor
import JWTKit

struct JWTAuthMiddleware: JWTAuthenticator {
    typealias Payload = TokkenSession

    func authenticate(jwt: Payload, for request: Request) async throws {
        guard let user = try await User.find(jwt.userId, on: request.db) else {
            throw Abort(.unauthorized, reason: "Utilisateur introuvable ou token invalide.")
        }
        request.auth.login(user)
    }
}
