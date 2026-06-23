import Foundation

enum IngredientDateFormatter {
    private static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func date(from string: String) -> Date? {
        apiDateFormatter.date(from: string)
    }

    static func apiString(from date: Date) -> String {
        apiDateFormatter.string(from: date)
    }
}
