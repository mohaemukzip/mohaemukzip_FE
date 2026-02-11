import SwiftUI

struct IngredientManagementCard: View {
    let ingredientInfo: FridgeIngredient
    let color: Color
    @Binding var isEditing: Bool
    let onDelete: () -> Void
    
        
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(.grey50)
                .frame(width: 76, height: 80)
            VStack {
                Text(ingredientInfo.name)
                    .font(.PretendardMedium13)
                    .foregroundStyle(.grey900)
                Spacer().frame(height: 4)
                Text(ingredientInfo.amount)
                    .font(.PretendardMedium13)
                    .foregroundStyle(.grey600)
                Spacer().frame(height: 6)
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                        .foregroundStyle(Color.clear)
                        .frame(width: 44, height: 18)
                    
                    Text(ingredientInfo.dDay)
                        .font(.PretendardMedium13)
                        .foregroundStyle(color)
                }
            }
        }.overlay(alignment: .topTrailing) {
            if isEditing {
                Button( action: onDelete ) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.grey500)
                        .padding(4)
                }.offset(x: 8, y: -8)
            }
        }
        .onLongPressGesture { withAnimation { isEditing.toggle() } }
    }
}
