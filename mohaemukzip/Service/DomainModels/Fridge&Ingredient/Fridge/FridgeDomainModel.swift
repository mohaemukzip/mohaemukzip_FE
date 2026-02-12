import SwiftUI

enum StorageType: String, CaseIterable {
    case frozen = "FREEZER"
    case chilled = "REFRIGERATOR"
    case room = "ROOM_TEMPERATURE"
    
    var displayName: String {
        switch self {
        case .frozen: return "냉동"
        case .chilled: return "냉장"
        case .room: return "실온"
        }
    }
}

enum dDayColor: String{
    case RED = "RED"
    case GREEN = "GREEN"
    case ORANGE = "ORANGE"
    
    var displayColor: Color {
        switch self {
        case .RED: return .red
        case .GREEN: return .green
        case .ORANGE: return .main400
        }
    }
}

struct FridgeIngredient: Identifiable {
    let id: Int
    let name: String
    let storage: StorageType
    let color: dDayColor
    let amount: String
    let expiryDate: String
    let dDay: String
}
