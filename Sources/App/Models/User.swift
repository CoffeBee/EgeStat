import Fluent
import Vapor

final class User: Model {
    struct Public: Content {
        let username: String
        let id: UUID
    }
    
    static let schema = "users"
    
    @ID(key: "id")
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
   
    @Field(key: "is_admin")
    var isAdmin: Bool
    
    init() {}
    
    init(id: UUID? = nil, username: String, passwordHash: String) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
        self.isAdmin = false
    }
}

extension User {
    static func create(from userSignup: UserSignup) throws -> User {
        User(username: userSignup.username, passwordHash: try Bcrypt.hash(userSignup.password))
    }
    
    func createToken(source: SessionSource, remember: Bool = false) throws -> Token {
        let calendar = Calendar(identifier: .gregorian)
        let expiryDate = calendar.date(byAdding: .day, value: remember ? 7 : 1, to: Date())
        return try Token(userId: requireID(),
                         token: [UInt8].random(count: 16).base64, source: source, expiresAt: expiryDate)
    }
    
    func asPublic(req: Request) throws -> EventLoopFuture<Public> {
        return req.eventLoop.makeSucceededFuture(Public(username: self.username, id: try self.requireID()))
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$passwordHash
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}
