import Foundation

struct FridgeListDTO: Decodable {
    let fridgeList: [IngredientDTO]
}

struct IngredientDTO: Decodable {
    let memberIngredientId: Int
    let ingredientId: Int
    let name: String
    let storageType: String
    let expiryDate: String
    let weight: Double
    let unit: String
    let statusColor: String
    let isFavorite: Bool
    let dday: String
    
    func toDomain() -> FridgeIngredient {
        return FridgeIngredient(id: self.memberIngredientId,
                                ingredientId: self.ingredientId,
                                name: self.name,
                                storage: StorageType(rawValue: self.storageType) ?? .room,
                                color: dDayColor(rawValue: self.statusColor) ?? .GREEN,
                                amount: self.weight,
                                unit: self.unit,
                                expiryDate: self.expiryDate,
                                isSaved: self.isFavorite,
                                dDay: self.dday)
    }
}

struct AddIngredientRequestDTO: Encodable {
    let ingredientId: Int
    let storageType: String
    let expireDate: String
    let weight: Double
}

struct UpdateIngredientRequestDTO: Encodable {
    let storageType: String
    let expireDate: String
    let weight: Double
}
