//: Please build the scheme 'GlossPlayground' first
import XCPlayground
import Decodable

let jsonPath = NSBundle.mainBundle().pathForResource("Data", ofType: "json")
let jsonData = NSFileManager.defaultManager().contentsAtPath(jsonPath!)
let jsonArray = try! NSJSONSerialization.JSONObjectWithData(
    jsonData!,
    options: NSJSONReadingOptions(rawValue: 0)
    ) as! [[String : AnyObject]]

protocol Deserializable: Decodable {
    static var typeIdentifier: String { get }
}

struct User: Deserializable {
    static let typeIdentifier = "user"

    let name: String
    let age: Int

    static func decode(json: AnyObject) throws -> User {
        return try User(
            name: json => "name",
            age: json => "age"
        )
    }
}

struct Car: Deserializable {
    static let typeIdentifier = "car"

    let color: String

    static func decode(json: AnyObject) throws -> Car {
        return try Car(
            color: json => "color"
        )
    }
}

struct Phone: Deserializable {
    static let typeIdentifier = "phone"

    let model: String

    static func decode(json: AnyObject) throws -> Phone {
        return try Phone(
            model: json => "model"
        )
    }
}

struct Deserializer {
    private var modelLookupTable: [String : Deserializable.Type] = [:]

    init(models: [Deserializable.Type]) {
        // Store all types in lookup table
        for model in models {
            self.modelLookupTable[model.typeIdentifier] = model
        }
    }

    func deserialize(json: [[String : AnyObject]]) -> [Deserializable] {
        var parsedModels: [Deserializable] = []

        // Iterate over each entity in the JSON array
        for jsonEntity in json {
            // Find metatype for this entity
            guard let type = jsonEntity["type"] as? String else { continue }
            guard let modelMetatype = modelLookupTable[type] else { continue }

            // Call initializer on the metatype
            if let model = try? modelMetatype.decode(jsonEntity) {
                parsedModels.append(model)
            }
        }

        return parsedModels
    }
}

let deserializer = Deserializer(models: [User.self, Car.self, Phone.self])
let models = deserializer.deserialize(jsonArray)

print(models)




