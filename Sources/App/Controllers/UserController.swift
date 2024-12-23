//
//  File.swift
//  zakFitVapor
//
//  Created by Apprenant 178 on 05/12/2024.
//

import Foundation
import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let users = routes.grouped("user")

                // Middleware JWT pour protéger les routes privées
            let tokenAuthMiddleware = TokkenSession.authenticator()
            let guardtokenhMiddleware = TokkenSession.guardMiddleware()
            let authGroups = users.grouped(tokenAuthMiddleware, guardtokenhMiddleware)

                users.post(use: create) // Création d’un utilisateur
                users.post("login", use: login) // Connexion
                authGroups.get("me", use: me) // Récupérer l'utilisateur connecté
                users.get(use: index) // Liste de tous les utilisateurs
                authGroups.delete(":userID", use: delete) // Suppression d’un utilisateur
    }
    
    @Sendable
    func index(req: Request) async throws -> [UserDTO] {
        let users = try await User.query(on: req.db).all()
        return users.map{$0.toDTO()}
    }
    
    
    @Sendable
    func me(req: Request) async throws -> UserDTO {
        let user = try req.auth.require(User.self)
        return user.toDTO()
    }
    
    @Sendable
    func create(req: Request) async throws -> UserDTO {
        do {
            let user = try req.content.decode(User.self)
            user.mdp = try Bcrypt.hash(user.mdp) // hachage du mdp
            try await user.save(on: req.db)
            return user.toDTO()
        } catch {
            print("Erreur lors de la création de l'utilisateur:", error)
            throw Abort(.internalServerError, reason: "Erreur de création d'utilisateur.")
        }
    }
    
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid user ID.")
        }
        
        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "user not found.")
        }
        
        try await user.delete(on: req.db)
        return .noContent
    }
    
    
    
    @Sendable
    func login(req: Request) async throws -> [String:String] {
        // Récupération des logins/mdp
        let user = try req.auth.require(User.self)
        // Création du payload en fonction des informations du user
        let payload = try TokkenSession(with: user)
        // Création d'un token signé à partir du payload
        let token = try await req.jwt.sign(payload)
        // Envoi du token à l'utilisateur sous forme de dictionnaire return ["token":
        return ["token": token]
        
    }
}


    

