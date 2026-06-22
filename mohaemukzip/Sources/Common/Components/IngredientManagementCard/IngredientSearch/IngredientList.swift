import SwiftUI

struct IngredientList: View {
    @Environment(IngredientSearchViewModel.self) var vm
    var ingredients: [IngredientForAddition]
    var onSaveTap: (Int) -> Void
    var onPlusTap: (IngredientForAddition) -> Void
    var onLastAppear: ((IngredientForAddition) -> Void)?
    var onRequest: (() -> Void)?
    
    var body: some View {
        if (ingredients.isEmpty) {
            ZStack {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(.clear)
                VStack {
                    Image("icon-noingredient")
                        .frame(width: 100)
                        .padding(.bottom, 5)
                    Text("재료가 없어요")
                        .foregroundStyle(.grey500)
                        .font(.PretendardRegular14)
                    Text("직접 재료를 등록해보세요")
                        .foregroundStyle(.grey500)
                        .font(.PretendardRegular14)
                }
            }
        }
        
        else {
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack {
                        // 스크롤을 상단으로 옮기기 위한 anchor
                        Color.clear.frame(height: 0).id("TOP")
                        ForEach(ingredients) { ingredient in
                            IngredientListComponent(
                                name: ingredient.name,
                                amount: IngredientAmountFormatter.withUnit(
                                    ingredient.amount,
                                    unit: ingredient.unit
                                ),
                                category: ingredient.category.rawValue,
                                isSaved: ingredient.isSaved,
                                onSaveTap: {onSaveTap(ingredient.id)},
                                onPlusTap: {onPlusTap(ingredient)}
                            )
                            .onAppear {
                                onLastAppear?(ingredient)
                            }
                        }
                        
                        if let onTap = onRequest {
                            Button ( action: { onTap() } ) {
                                IngredientRequestButton()
                            }.padding(.bottom)
                        }
                    }.onChange(of: vm.selectedCategory) {
                        proxy.scrollTo("TOP", anchor: .top)
                    }
                }
            }.scrollIndicators(.hidden)
        }
    }
}


#Preview("데이터 있음") {
    let mockIngredients = [
        IngredientForAddition(id: 1, name: "대파", category: .vegetable, unit: "g", amount: 100, isSaved: true),
        IngredientForAddition(id: 2, name: "양파", category: .vegetable, unit: "개", amount: 2, isSaved: false),
        IngredientForAddition(id: 3, name: "삼겹살", category: .dairy, unit: "g", amount: 600, isSaved: false),
        IngredientForAddition(id: 4, name: "우유", category: .dairy, unit: "ml", amount: 500, isSaved: true)
    ]
    
    IngredientList(
        ingredients: mockIngredients,
        onSaveTap: { id in
            print("⭐ 즐겨찾기 탭됨 - ID: \(id)")
        },
        onPlusTap: { ingredient in
            print("➕ 추가 버튼 탭됨 - 재료명: \(ingredient.name)")
        },
        onLastAppear: { ingredient in
            print("👀 마지막 아이템 노출(무한스크롤용) - ID: \(ingredient.id)")
        },
        onRequest: { print("") }
    )
}
