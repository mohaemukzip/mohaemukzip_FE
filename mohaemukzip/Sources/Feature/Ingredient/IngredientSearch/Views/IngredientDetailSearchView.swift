import SwiftUI

struct IngredientDetailSearchView: View {
    @Environment(IngredientSearchViewModel.self) var viewModel
    @Environment(FridgeViewModel.self) var fridgeVM
    @Environment(NavigationRouter.self) var router
    @State var isShowingSheet: Bool = false
    // MARK: 바텀시트 UX 개선을 위해 바텀시트에 전달할 item을 뷰에서 상태변수로 관리
    @State var sheetItem: IngredientForAddition?
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        ZStack(alignment: .bottom) {
            VStack {
                HStack {
                    Button( action: { router.pop(); viewModel.searchText = "" } ) {
                        Image("icon-back-big")
                            .foregroundStyle(.grey700)
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 44)
                            .foregroundStyle(.grey100)
                        
                        
                        HStack {
                            TextField("재료명을 입력하세요.", text: $viewModel.searchText)
                                .font(.PretendardRegular16)
                                .foregroundStyle(.grey900)
                                .padding(.leading, 14)
                            
                            Spacer()
                            Image("icon-search")
                                .foregroundStyle(.grey500)
                                .padding(.trailing, 14)
                        }
                    }
                }.padding()
                
                // 검색 텍스트 없는 경우
                if (viewModel.searchText.isEmpty) {
                    VStack {
                        HStack {
                            Text("최근 검색어")
                                .font(.PretendardSemibold18)
                                .foregroundStyle(.grey900)
                            Spacer()
                        }
                        if (viewModel.recentSearchTexts.isEmpty) {
                            Text("최근 검색어가 없어요.")
                                .font(.PretendardRegular16)
                                .foregroundStyle(.grey500)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(viewModel.recentSearchTexts) { ingredient in
                                        RecentSearch(text: ingredient.keyword,
                                                     onTap: { viewModel.searchText = ingredient.keyword},
                                                     onDelete: { viewModel.deleteRecentSearch(for: ingredient.id);
                                                                 Task { await viewModel.deleteRecent(name: ingredient.keyword) } })
                                    }
                                }
                            }.padding(.vertical, 16)
                        }
                        
                        HStack {
                            Text("즐겨찾기")
                                .font(.PretendardSemibold18)
                                .foregroundStyle(.grey900)
                            Spacer()
                        }.padding(.top, 30)
                        if (viewModel.savedIngredients.isEmpty) {
                            ZStack {
                                Rectangle()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .foregroundStyle(.clear)
                                Text("즐겨찾기한 재료가 없어요.")
                                    .font(.PretendardRegular16)
                                    .foregroundStyle(.grey500)
                            }
                        } else {
                            IngredientList(ingredients: viewModel.savedIngredients,
                                           onSaveTap: { id in Task { await viewModel.toggleSaved(id: id)} },
                                           onPlusTap: { item in self.sheetItem = item },
                                           onRequest: { self.isShowingSheet = true })
                        }
                        
                    }.padding(.horizontal)
                } else { // 검색 텍스트 있는 경우
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
                                   onSaveTap: { id in Task { await viewModel.toggleSaved(id: id)} },
                                   onPlusTap: { item in self.sheetItem = item })
                    .padding(.horizontal)
                }
            } // end of VStack
            
            if viewModel.savedIngredients.isEmpty {
                Button ( action: { isShowingSheet = true } ) {
                    IngredientRequestButton()
                        .padding(.horizontal)
                        .padding(.bottom, 35)
                }
            }
        }.sheet(isPresented: $isShowingSheet) {
            RequestBottomSheet(isShowingSheet: $isShowingSheet,
                               onRequest: { requestedText in
                Task { await viewModel.ingredientRequest(name: requestedText) }
                viewModel.searchText = ""
            }).presentationDetents([.fraction(0.45), .large])
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
                    viewModel.searchText = ""
                    router.navigateToRoot()
                }
            },
                                          onSave: { id in
                self.sheetItem?.isSaved.toggle()
                Task { await viewModel.toggleSaved(id: id) }
            },
                                          onDismiss: {
                self.sheetItem = nil
                viewModel.searchText = ""
            },
                                          onRecommend: {
                return await viewModel.getRecommendedDate(id: ingredient.id)
            }).presentationDetents([.fraction(0.98)])
        }.navigationBarBackButtonHidden() // end of ZStack
            .task(id: viewModel.searchText.isEmpty) {
                if viewModel.searchText.isEmpty {
                    await viewModel.fetchSavedList()
                    await viewModel.getRecent()
                }
            }
            .task(id: searchQuery(text: viewModel.searchText, category: viewModel.selectedCategory)) {
                
                // MARK: 검색어가 입력되는 동안 불필요한 api 호출을 없애기 위한 0.5초 디바운싱
                // MARK: 검색어 입력이 멈추고 0.5초 이후 api 호출
                if !viewModel.searchText.isEmpty {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                }
                
                if !Task.isCancelled {
                    Task {await viewModel.resetAndFetchIngredients()}
                }
            }
    } // end of body
}

#Preview {
    IngredientDetailSearchView()
        .environment(NavigationRouter())
        .environment(FridgeViewModel())
        .environment(IngredientSearchViewModel())
}
