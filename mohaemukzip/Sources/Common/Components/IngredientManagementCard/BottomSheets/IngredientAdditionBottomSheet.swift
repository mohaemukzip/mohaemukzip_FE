import SwiftUI

struct IngredientFormBottomSheet: View {
    let mode: IngredientFormMode
    var ingredient: IngredientFormItem
    var onSubmit: (IngredientFormResult) -> Void
    var onSave: (Int) -> Void
    var onDismiss: () -> Void
    var onRecommend: () async -> Date?
    
    @State private var formValue: IngredientFormInitialValue
    
    @State private var showStorageCase: Bool = false
    @State private var showDatePicker: Bool = false
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd"
        return formatter
    }
    
    // amount에 유효하지 않은 값이 들어온 경우 에러메세지
    @State private var amountErrorMessage: String?
    
    private var parsedAmount: Double? {
        let normalizedAmount = formValue.amount
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard let value = Double(normalizedAmount),
              value.isFinite,
              value > 0 else {
            return nil
        }

        return value
    }
    
    init(
        mode: IngredientFormMode,
        ingredient: IngredientFormItem,
        initialValue: IngredientFormInitialValue,
        onSubmit: @escaping (IngredientFormResult) -> Void,
        onSave: @escaping (Int) -> Void,
        onDismiss: @escaping () -> Void,
        onRecommend: @escaping () async -> Date?
    ) {
        self.mode = mode
        self.ingredient = ingredient
        self.onSubmit = onSubmit
        self.onSave = onSave
        self.onDismiss = onDismiss
        self.onRecommend = onRecommend
        self._formValue = State(initialValue: initialValue)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                HStack {
                    Text(ingredient.name)
                        .foregroundStyle(.grey900)
                        .font(.PretendardSemibold20)
                    Button( action: { onSave(ingredient.id) } ) {
                        Image("icon-star")
                            .foregroundStyle(ingredient.isSaved ? .main300 : .grey300)
                    }
                    
                    Spacer()
                    
                    Button( action: { onDismiss() } ) {
                        Image("icon-x")
                            .foregroundStyle(.grey700)
                    }
                }.padding(.bottom, 32)
                
                HStack {
                    Text("보관장소")
                        .font(.PretendardMedium13)
                        .foregroundStyle(.grey900)
                        .padding(.trailing, -8)
                    Text("*")
                        .font(.PretendardMedium13)
                        .foregroundStyle(.red)
                    Spacer()
                }.padding(.bottom, 6)
                
                VStack(spacing: 1) {
                    Button ( action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showStorageCase.toggle()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(showStorageCase ? .main400 : .grey300)
                                .frame(height: 45)
                            HStack {
                                Text(formValue.storage.displayName)
                                    .font(.PretendardRegular16)
                                    .foregroundStyle(.grey900)
                                    .padding(.leading, 10)
                                Spacer()
                                Image(showStorageCase ? "icon-chevron-up" : "icon-chevron-down")
                                    .foregroundStyle(showStorageCase ? .main400 : .grey500)
                                    .padding(.trailing, 10)
                            }
                        }
                    }
                    
                    if (showStorageCase) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(.grey300)
                                .frame(height: 159)
                            VStack(spacing: 0) {
                                ForEach(StorageType.allCases, id: \.self) { type in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .frame(height: 53)
                                            .foregroundStyle(formValue.storage == type ? .main100 : .clear)
                                        Button( action: {formValue.storage = type;
                                            withAnimation(.easeInOut(duration: 0.3)) { showStorageCase.toggle() } } ) {
                                                HStack {
                                                    Text(type.displayName)
                                                        .font(.PretendardRegular16)
                                                        .foregroundStyle(.grey900)
                                                        .padding(.leading, 10)
                                                    Spacer()
                                                }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }.padding(.bottom, 16) // end of VStack
                
                HStack {
                    Text("재료 소비 기한")
                        .font(.PretendardMedium13)
                        .foregroundStyle(.grey900)
                        .padding(.trailing, -8)
                    Spacer()
                }.padding(.bottom, 6)
                
                HStack(spacing: 12) {
                    Button ( action: { withAnimation { showDatePicker.toggle() } }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .frame(height: 40)
                                .foregroundStyle(.grey100)
                            
                            HStack {
                                Text(dateFormatter.string(from: formValue.expiryDate))
                                    .font(.PretendardRegular16)
                                    .foregroundStyle(.grey500)
                                    .padding(.leading, 10)
                                Spacer()
                            }
                        }
                    }
                    
                    Button ( action: { Task {
                        if let newDate = await onRecommend() {
                            self.formValue.expiryDate = newDate
                        }
                    } } ) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(.main400, lineWidth: 1)
                            Text("자동 추천일")
                                .font(.PretendardRegular16)
                                .foregroundStyle(.main400)
                        }
                    }.frame(width: 104, height: 38)
                }.padding(.bottom, 16)
                
                if (showDatePicker) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.grey300)
                            .frame(height: 400)
                        
                        DatePicker(
                            "",
                            selection: $formValue.expiryDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                        .tint(.grey700)
                        .frame(height: 360)
                        .cornerRadius(8)
                        .onChange(of: formValue.expiryDate, { withAnimation(.easeInOut(duration: 0.3)){showDatePicker.toggle()} })
                    }.padding(.bottom, 16)
                        .padding(.top, -10)
                }
                
                HStack {
                    Text("중량")
                        .font(.PretendardMedium13)
                        .foregroundStyle(.grey900)
                        .padding(.trailing, -8)
                    Spacer()
                }.padding(.bottom, 6)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(height: 40)
                        .foregroundStyle(.grey100)
                    
                    HStack {
                        TextField("0", text: $formValue.amount)
                            .font(.PretendardMedium16)
                            .foregroundStyle(.grey900)
                            .padding(.leading, 10)
                            .keyboardType(.decimalPad)
                        Spacer()
                        Text(ingredient.unit)
                            .font(.PretendardRegular16)
                            .foregroundStyle(.grey500)
                            .padding(.trailing, 10)
                    }
                }
                Spacer().padding(.bottom, 100)
            }.padding(.top, 25)
                .scrollIndicators(.hidden)// end of ScrollView
            
            VStack {
                Spacer()
                Button(action: {
                    
                    // 유효하지 않은 중량인 경우(parsedAmount == nil) 요청 중단
                    guard let parsedAmount else {
                        amountErrorMessage = "올바른 중량을 입력해주세요."
                        return
                    }
                    
                    amountErrorMessage = nil
                    
                    let submitValue = IngredientFormResult(storage: formValue.storage,
                                                           expiryDate: formValue.expiryDate,
                                                           amount: parsedAmount)
                    onSubmit(submitValue)
                }) {
                    OrangeButton(text: mode.modeTitle, size: .big)
                        .frame(height: 57)
                }
            }.padding(.bottom, 25)
        }.padding(.horizontal) // end of ZStack
    } // end of body
}

// 폼 모드 - 추가/수정
enum IngredientFormMode {
    case add
    case edit
    
    var modeTitle: String {
        switch self {
        case .add:
            "추가하기"
        case .edit:
            "수정하기"
        }
    }
}

// 폼 내부 초기값
struct IngredientFormInitialValue {
    var storage: StorageType
    var expiryDate: Date
    var amount: String
}

// 폼 내부에서 만들어진 최종 결과값
struct IngredientFormResult {
    var storage: StorageType
    var expiryDate: Date
    var amount: Double
}

#Preview {
    let mockIngredient = IngredientFormItem(
        id: 101,
        name: "대파",
        unit: "g",
        isSaved: true
    )
    IngredientFormBottomSheet(
        mode: .add,
        ingredient: mockIngredient,
        initialValue: IngredientFormInitialValue(
            storage: .chilled,
            expiryDate: Date(),
            amount: "100"
        ),
        onSubmit: { result in
            print("추가 요청: \(result.storage.displayName), 날짜: \(result.expiryDate), 중량: \(result.amount)g")
        },
        onSave: { id in
            print("즐겨찾기 토글 ID: \(id)")
        },
        onDismiss: {
            print("시트 닫기 요청")
        },
        onRecommend: {
            try? await Task.sleep(nanoseconds: 500_000_000)
            return Calendar.current.date(byAdding: .day, value: 7, to: Date())
        }
    )
}
