import Fluent
import FluentPostgresDriver
import Vapor
import Redis

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.routes.defaultMaxBodySize = "10mb"
    app.directory.publicDirectory = "./"
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)

    // Only add this if you want to enable the default per-route logging
    let routeLogging = RouteLoggingMiddleware(logLevel: .info)

    // Add the default error middleware
    let error = ErrorMiddleware.default(environment: app.environment)
    // Clear any existing middleware.
    app.middleware = .init()
    app.middleware.use(cors)
    app.middleware.use(routeLogging)
    app.middleware.use(error)
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.databases.use(.postgres(
        hostname: "localhost",
        port: PostgresConfiguration.ianaPortNumber,
        username:"vapor_username",
        password: "vapor_password",
        database:"vapor_database"
    ), as: .psql)
    
    
    app.migrations.add(CreateUsers())
    app.migrations.add(CreateTokens())

    // register routes
    try routes(app)
}
