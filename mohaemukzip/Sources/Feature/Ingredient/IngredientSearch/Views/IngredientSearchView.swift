import SwiftUI

struct IngredientSearchView: View {
    @Environment(IngredientSearchViewModel.self) var viewModel
    @Environment(FridgeViewModel.self) var fridgeVM
    @Environment(NavigationRouter.self) var router
    // MARK: 바텀시트 UX 개선을 위해 바텀시트에 전달할 item을 뷰에서 상태변수로 관리
    @State var sheetItem: IngredientForAddition?
    
    var body: some View {
        @Bindable var viewModel = viewModel
        VStack {
            HStack {
                Button( action: { router.pop() } ) {
                    Image("icon-back-big")
                        .foregroundStyle(.grey700)
                }
                
                Button ( action: { router.push(.ingredientDetailSearch) } ) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 44)
                            .foregroundStyle(.grey100)
                        
                        HStack {
                            Text("재료명을 입력하세요.")
                                .font(.PretendardRegular16)
                                .foregroundStyle(.grey400)
                                .padding(.leading, 14)
                            Spacer()
                            Image("icon-search")
                                .foregroundStyle(.grey500)
                                .padding(.trailing, 14)
                        }
                    }
                }
            }.padding()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Category.allCases, id: \.self) { category in
                        VStack {
                            Button( action: { viewModel.selectedCategory = category } ) {
                                Text(category.rawValue)
                                    .foregroundStyle(viewModel.selectedCategory == category ? .grey900 : .grey400)
                                    .font(.PretendardSemibold18)
                            }.padding(.bottom, 4)
                            
                            Rectangle()
                                .frame(width: 63, height: 2)
                                .foregroundStyle(viewModel.selectedCategory == category ? .grey900 : .clear)
                        }.padding(.leading)
                    }
                }
            }.padding(.vertical, 10)
            
            IngredientList(ingredients: viewModel.filteredIngredients,
                           onSaveTap: { id in
                Task { await viewModel.toggleSaved(id: id) }},
                           onPlusTap: { item in self.sheetItem = item},
                           // MARK: 무한스크롤 구현 - 마지막 item 나타나면 fetchNextPage() 호출
                           onLastAppear: { item in
                                            if item.id == viewModel.filteredIngredients.last?.id {
                                                Task { await viewModel.fetchNextPage() } }})
            .padding(.horizontal)
        }
        // MARK: 재료 추가 바텀시트
        .sheet(item: $sheetItem) { ingredient in
            IngredientFormBottomSheet(mode: .add,
                                      ingredient: IngredientFormItem(ingredient),
                                      initialValue: IngredientFormInitialValue(
                                              storage: .chilled,
                                              expiryDate: Date(),
                                              amount: ""
                                          ),
                                          onSubmit: { result in
                Task {
                    await fridgeVM.addIngredient(id: ingredient.id,
                                                 ty: result.storage.rawValue,
                                                 date: result.expiryDate,
                                                 amount: result.amount)
                    self.sheetItem = nil
                    router.navigateToRoot()
                    viewModel.searchText = ""
                }
            },
                                          onSave: { id in
                Task { await viewModel.toggleSaved(id: id) }
                self.sheetItem?.isSaved.toggle()
            },
                                          onDismiss: {
                self.sheetItem = nil
                viewModel.searchText = ""
            },
                                          onRecommend: {
                return await viewModel.getRecommendedDate(id: ingredient.id)
            }).presentationDetents([.fraction(0.98)])
        }
        .navigationBarBackButtonHidden()
        .task(id: viewModel.selectedCategory) {
            await viewModel.resetAndFetchIngredients()
        }.id(viewModel.viewId)
        
    }
}

#Preview {
    IngredientSearchView()
        .environment(NavigationRouter())
        .environment(FridgeViewModel())
        .environment(IngredientSearchViewModel())
}
