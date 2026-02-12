import SwiftUI

struct ChatBubble: Shape {
    let direction: ChatDirection
    enum ChatDirection { case left, right }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius: CGFloat = 10
        let tipRadius: CGFloat = 2
          
        path.move(to: CGPoint(x: radius, y: 0))
        path.addLine(to: CGPoint(x: rect.width - radius, y: 0))
        path.addArc(center: CGPoint(x: rect.width - radius, y: radius), radius: radius,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        
        // 사용자 말풍선 (오른쪽)
        if direction == .right {
            path.addLine(to: CGPoint(x: rect.width, y: 10))
            path.addArc(tangent1End: CGPoint(x: rect.width + 20, y: 20),
                        tangent2End: CGPoint(x: rect.width, y: 30),
                        radius: tipRadius)
            path.addLine(to: CGPoint(x: rect.width, y: 30))
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - radius))
        path.addArc(center: CGPoint(x: rect.width - radius, y: rect.height - radius), radius: radius,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: radius, y: rect.height))
        path.addArc(center: CGPoint(x: radius, y: rect.height - radius), radius: radius,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
          
        // 요선생 말풍선 (왼쪽)
        if direction == .left {
            path.addLine(to: CGPoint(x: 0, y: 30))
            path.addArc(tangent1End: CGPoint(x: -20, y: 20),
                        tangent2End: CGPoint(x: 0, y: 10),
                        radius: tipRadius)
            path.addLine(to: CGPoint(x: 0, y: 10))
        }
        
        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addArc(center: CGPoint(x: radius, y: radius), radius: radius,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
          
        return path
    }
}

// 요선생 말풍선 (왼쪽)
struct YoTeacherBubble: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.PretendardMedium16)
            .foregroundColor(.grey900)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .lineSpacing(1.5)
            .multilineTextAlignment(.center)
            .background(
                ChatBubble(direction: .left)
                    .fill(.white)
            )
            .overlay(
                ChatBubble(direction: .left)
                    .stroke(.grey200, lineWidth: 1)
            )
    }
}

// 사용자 말풍선 (오른쪽)
struct UserBubble: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.PretendardMedium16)
            .foregroundColor(.grey900)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .lineSpacing(1.5)
            .background(
                ChatBubble(direction: .right)
                    .fill(.grey100)
            )
    }
}

#Preview {
    VStack(spacing: 20) {
        UserBubble(text: "안녕하세요")
        YoTeacherBubble(text: "오늘은 어떤 요리가 좋을지\n요선생에게 다 말해봐!")
    }
    .padding()
}
