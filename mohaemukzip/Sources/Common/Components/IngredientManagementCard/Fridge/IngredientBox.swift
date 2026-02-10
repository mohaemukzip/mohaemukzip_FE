//
//  IngredientBox.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/16/26.
//

import SwiftUI

struct IngredientBox: View {
    @State private var isExpanded: Bool = false
    @Binding var isEditing: Bool
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    let text: String
    let ingredients: [FridgeIngredient]
    var onDelete: (Int) -> Void
    
    // 4열 그리드를 만들기 위한 배열을 4개씩 묶어주는 헬퍼
    private var chunkedIngredients: [[FridgeIngredient?]] {
        let displayCount = isExpanded ? max(ingredients.count, 8) : 8
        var items: [FridgeIngredient?] = Array(ingredients.prefix(displayCount))
        
        while items.count < displayCount {
            items.append(nil)
        }
        
        return stride(from: 0, to: items.count, by: 4).map {
            Array(items[$0..<min($0 + 4, items.count)])
        }
    }
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .frame(width: 359)
                .foregroundStyle(.white)
            
            VStack {
                HStack {
                    Text(text)
                        .font(.PretendardSemibold16)
                        .foregroundStyle(.grey700)
                    Spacer().frame(width: 278)
                    Button(action: { withAnimation { isExpanded.toggle() } } ) {
                        Image(isExpanded ? "icon-chevron-down" : "icon-chevron-up")
                            .foregroundStyle(.grey700)
                    }
                }
                
                Spacer().frame(height: 20)
                
                // LazyVGrid 사용 시 FridgeView에서 스크롤이 동작할 때 렌더링이 늦어져 순간적으로 재료가 안보이는 버그
                // MARK: VStack과 HStack을 합쳐서 Grid 구현해 UI 안정성 확보
                VStack(spacing: 16) {
                    ForEach(0..<chunkedIngredients.count, id: \.self) { rowIndex in
                        HStack(spacing: 7.5) {
                            ForEach(0..<4, id: \.self) { colIndex in
                                if colIndex < chunkedIngredients[rowIndex].count,
                                   let item = chunkedIngredients[rowIndex][colIndex] {
                                    IngredientManagementCard(ingredientInfo: item,
                                                             color: item.color.displayColor,
                                                             isEditing: $isEditing,
                                                             onDelete: { onDelete(item.id) })
                                } else {
                                    Rectangle()
                                        .frame(width: 76, height: 80)
                                        .foregroundStyle(.clear)
                                }
                            }
                        }
                    }
                }
            }.frame(width: 327)
                .padding()
        }.onDisappear {
            self.isExpanded = false
        }
        
    }
}


#Preview {
    @Previewable
    @State var x = false
    IngredientBox(isEditing: $x, text: "냉장", ingredients: [FridgeIngredient(id: 1, name: "대파", storage: .chilled, color: .GREEN, amount: "100", expiryDate: "2025-03-11", dDay: "d-300"),
                                                           FridgeIngredient(id: 1, name: "대파", storage: .chilled, color: .GREEN, amount: "100", expiryDate: "2025-03-11", dDay: "d-300"),
                                                           FridgeIngredient(id: 1, name: "대파", storage: .chilled, color: .GREEN, amount: "100", expiryDate: "2025-03-11", dDay: "d-300"),
                                                           FridgeIngredient(id: 1, name: "대파", storage: .chilled, color: .GREEN, amount: "100", expiryDate: "2025-03-11", dDay: "d-300"),
                                                           FridgeIngredient(id: 1, name: "대파", storage: .chilled, color: .GREEN, amount: "100", expiryDate: "2025-03-11", dDay: "d-300"),
                                                           FridgeIngredient(id: 1, name: "대파", storage: .chilled, color: .GREEN, amount: "100", expiryDate: "2025-03-11", dDay: "d-300"),
                                                           FridgeIngredient(id: 1, name: "대파", storage: .chilled, color: .GREEN, amount: "100", expiryDate: "2025-03-11", dDay: "d-300"),
                                                           FridgeIngredient(id: 1, name: "대파", storage: .chilled, color: .GREEN, amount: "100", expiryDate: "2025-03-11", dDay: "d-300"),
                                                           FridgeIngredient(id: 1, name: "대파", storage: .chilled, color: .GREEN, amount: "100", expiryDate: "2025-03-11", dDay: "d-300")], onDelete: { _ in })
}
