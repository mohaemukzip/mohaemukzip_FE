import SwiftUI

enum RecipeDetailFormatters {

    static func formattedViews(_ views: Int) -> String {
        if views < 10_000 { return "\(views)회" }

        let value = Double(views) / 10_000.0
        let rounded = (value * 10).rounded() / 10
        let string = rounded.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(rounded))
            : String(rounded)
        return "\(string)만회"
    }

    static func formattedAmount(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        }
        return String(value)
    }
}

struct DifficultyStarsView: View {
    let filledCount: Int

    var body: some View {
        let filled = max(0, min(5, filledCount))

        return HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: index < filled ? "star.fill" : "star")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(index < filled ? Color.orange : Color(.systemGray4))
            }
        }
    }
}
