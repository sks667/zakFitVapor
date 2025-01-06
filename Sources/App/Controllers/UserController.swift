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
        
        // Middleware pour authentification
        let basicAuthMiddleware = User.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let authGroups = users.grouped(basicAuthMiddleware, guardAuthMiddleware)
        
        // Routes protégées
        authGroups.post("login", use: login)  // Connexion
        authGroups.get("profile", use: getProfile)  // Récupération du profil utilisateur connecté
    }
    
    /**
     Récupère tous les utilisateurs enregistrés.
     
     - Parameter req: La requête HTTP entrante.
     - Returns: Une liste de `UserDTO`.
     - Throws: Une erreur en cas d'échec de la requête.
     */
    @Sendable
    func index(req: Request) async throws -> [UserDTO] {
        let users = try await User.query(on: req.db).all()
        return users.map { $0.toDTO() }
    }
    
    /**
     Récupère le profil de l'utilisateur connecté.
     
     - Parameter req: La requête HTTP contenant le token d'authentification.
     - Returns: Le `UserDTO` de l'utilisateur authentifié.
     - Throws: Une erreur si l'utilisateur n'est pas authentifié.
     */
    @Sendable
    func getProfile(req: Request) async throws -> UserDTO {
        req.logger.info("Début de la méthode getProfile")

        guard let user = try? req.auth.require(User.self) else {
            req.logger.error("Utilisateur non authentifié")
            throw Abort(.unauthorized, reason: "User not authenticated.")
        }

        req.logger.info("Utilisateur authentifié : \(user.email), ID : \(user.id?.uuidString ?? "Inconnu")")
        return user.toDTO()
    }
    
    /**
     Crée un nouvel utilisateur.
     
     - Parameter req: La requête contenant les données utilisateur.
     - Returns: Le `UserDTO` de l'utilisateur créé.
     - Throws: Une erreur si l'email est déjà utilisé ou si la création échoue.
     */
    @Sendable
    func create(req: Request) async throws -> UserDTO {
        do {
            let user = try req.content.decode(User.self)
            
            // Vérification de l'email déjà existant
            if let _ = try await User.query(on: req.db).filter(\.$email == user.email).first() {
                throw Abort(.badRequest, reason: "Cet email est déjà utilisé.")
            }
            
            user.mdp = try Bcrypt.hash(user.mdp)  // Hashage du mot de passe
            try await user.save(on: req.db)
            return user.toDTO()
        } catch {
            req.logger.error("Erreur lors de la création de l'utilisateur: \(error.localizedDescription)")
            throw Abort(.internalServerError, reason: "Erreur de création d'utilisateur.")
        }
    }
    
    /**
     Supprime un utilisateur via son ID.
     
     - Parameter req: La requête contenant l'ID de l'utilisateur à supprimer.
     - Returns: Un `HTTPStatus.noContent` en cas de succès.
     - Throws: Une erreur si l'ID est invalide ou si l'utilisateur n'est pas trouvé.
     */
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid user ID.")
        }
        
        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found.")
        }
        
        try await user.delete(on: req.db)
        return .noContent
    }
    
    /**
     Connecte un utilisateur et génère un token JWT.
     
     - Parameter req: La requête contenant les informations d'identification.
     - Returns: Un dictionnaire contenant le token JWT.
     - Throws: Une erreur si les identifiants sont incorrects ou si l'authentification échoue.
     */
    @Sendable
    func login(req: Request) async throws -> [String: String] {
        let user = try req.auth.require(User.self)
        let payload = try TokkenSession(with: user)
        let token = try await req.jwt.sign(payload)
        return ["token": token]
    }
}


    

