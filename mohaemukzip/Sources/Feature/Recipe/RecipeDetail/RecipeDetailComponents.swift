import SwiftUI

struct RecipeIngredientChip: View {

    let ingredient: RecipeIngredient

    var body: some View {
        VStack(spacing: 4) {
            Text(ingredient.name)
                .font(
                    Font.custom("Pretendard", size: 14)
                        .weight(.medium)
                )

            Text("분량 (\(RecipeDetailFormatters.formattedAmount(ingredient.amount))\(ingredient.unit))")
                .font(Font.custom("Pretendard", size: 13))
                .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
        }
        .frame(width: 88, height: 64)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
        )
    }

   var backgroundColor: Color {
        ingredient.hasIngredient
            ? Color(red: 0.98, green: 0.98, blue: 0.98)
            : Color("grey200")
    }
}

struct RecipeStepCard: View {

    let step: RecipeStep
    let onTapTimestamp: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("STEP \(step.stepNumber)")
                        .font(.custom("Pretendard-Medium", size: 14))
                        .foregroundStyle(Color.orange)

                    Text(step.title)
                        .font(.custom("Pretendard-SemiBold", size: 16))
                        .foregroundStyle(.primary)
                }

                Spacer()

                Button {
                    onTapTimestamp(step.videoTime)
                } label: {
                    HStack(spacing: 0) {
                        Image("play.arrow.filled")
                        Text(formattedTime(step.videoTime))
                            .font(.custom("Pretendard-Medium", size: 14))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
                .padding(.leading, 4)
                .padding(.trailing, 8)
                .padding(.vertical, 2)
                .background(Color(red: 0.29, green: 0.28, blue: 0.28))
                .cornerRadius(30)
            }

            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 1)
                .background(Color(red: 0.9, green: 0.9, blue: 0.9))

            Text(step.description)
                .font(.custom("Pretendard-Regular", size: 16))
                .foregroundStyle(.primary)
                .lineSpacing(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }

 func formattedTime(_ seconds: Int) -> String {
        let m = max(0, seconds) / 60
        let s = max(0, seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}
