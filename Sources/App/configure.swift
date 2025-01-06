import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor
import JWTKit
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "root",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "zakFit"
    ), as: .mysql)
    
    
    // register routes
    try routes(app)
    
    
    guard let secret = Environment.get("SECRET_KEY") else {
        fatalError("JWT ca marche pas sahbi")
    }
    
    let hmacKey = HMACKey(from: Data(secret.utf8))
    await app.jwt.keys.add(hmac: hmacKey, digestAlgorithm: .sha256)

    let corsConfiguration =  CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .DELETE],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith],
        cacheExpiration: 800
    )
    
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(corsMiddleware)
    
    


 
}
