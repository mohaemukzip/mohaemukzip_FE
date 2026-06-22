import Foundation

enum IngredientAmountFormatter {
    static func string(from amount: Double) -> String {
        if amount.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(amount))
        }

        return String(amount)
    }

    static func withUnit(_ amount: Double, unit: String) -> String {
        "\(string(from: amount))\(unit)"
    }
}
