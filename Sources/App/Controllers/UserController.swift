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
        

        users.get(use: index)
        users.post(use: create)
        users.delete(":userID", use: delete)
        

        let basicAuthMiddleware = User.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let authGroups = users.grouped(basicAuthMiddleware, guardAuthMiddleware)
        
        authGroups.post("login", use: login)
        authGroups.get("profile", use: getProfile)
    }
    
    @Sendable
    func index(req: Request) async throws -> [UserDTO] {
        let users = try await User.query(on: req.db).all()
        return users.map{$0.toDTO()}
    }
    
    
    @Sendable
    func getProfile(req: Request) async throws -> UserDTO {
        // Log initial
        req.logger.info("Début de la méthode getProfile")

        // Vérifie si un utilisateur est authentifié
        guard let user = try? req.auth.require(User.self) else {
            req.logger.error("Utilisateur non authentifié")
            throw Abort(.unauthorized, reason: "User not authenticated.")
        }

        // Log utilisateur authentifié
        req.logger.info("Utilisateur authentifié : \(user.email), ID : \(user.id?.uuidString ?? "Inconnu")")

        // Retourne le DTO
        return user.toDTO()
    }
    
    
    @Sendable
        func create(req: Request) async throws -> UserDTO {
            do {
                let user = try req.content.decode(User.self)
                
                // Vérifie l'email
                if let _ = try await User.query(on: req.db).filter(\.$email == user.email).first() {
                    throw Abort(.badRequest, reason: "Cet email est déjà utilisé.")
                }
                
                user.mdp = try Bcrypt.hash(user.mdp) // Hashage du mot de passe
                try await user.save(on: req.db)
                return user.toDTO()
            } catch {
                req.logger.error("Erreur lors de la création de l'utilisateur: \(error.localizedDescription)")
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
        func login(req: Request) async throws -> [String: String] {
            let user = try req.auth.require(User.self)
            let payload = try TokkenSession(with: user)
            let token = try await req.jwt.sign(payload)
            return ["token": token]
        }
}


    

