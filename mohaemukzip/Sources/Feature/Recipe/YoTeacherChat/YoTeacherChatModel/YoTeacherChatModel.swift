import Foundation

struct ChatMessages: Identifiable {
    let id: UUID = UUID()
    let text: String
    var chatBotTitle: String? = nil
    var chatBotText: String? = nil
    var chatBotResponse: [YoTeacherMessage]? = nil
}
