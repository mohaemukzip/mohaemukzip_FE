//
//  IngredientAdditionBottomSheet.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/23/26.
//

import SwiftUI

struct IngredientAdditionBottomSheet: View {
    var ingredient: IngredientForAddition
    @State private var storageLocation: StorageType = .chilled
    @State private var expiryDate: Date = Date()
    @State private var amount: String = ""
    var onAdd: (StorageType, Date, Int) -> Void
    var onSave: (Int) -> Void
    var onDismiss: () -> Void
    var onRecommend: () async -> Date?
    
    @State private var showStorageCase: Bool = false
    @State private var showDatePicker: Bool = false
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd"
        return formatter
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
                                Text(storageLocation.displayName)
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
                                            .foregroundStyle(storageLocation == type ? .main100 : .clear)
                                        Button( action: {storageLocation = type;
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
                                Text(dateFormatter.string(from: expiryDate))
                                    .font(.PretendardRegular16)
                                    .foregroundStyle(.grey500)
                                    .padding(.leading, 10)
                                Spacer()
                            }
                        }
                    }
                    
                    Button ( action: { Task {
                        if let newDate = await onRecommend() {
                            self.expiryDate = newDate
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
                            selection: $expiryDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                        .tint(.grey700)
                        .frame(height: 360)
                        .cornerRadius(8)
                        .onChange(of: expiryDate, { withAnimation(.easeInOut(duration: 0.3)){showDatePicker.toggle()} })
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
                        TextField("0", text: $amount)
                            .font(.PretendardMedium16)
                            .foregroundStyle(.grey900)
                            .padding(.leading, 10)
                            .keyboardType(.numberPad)
                        Spacer()
                        Text("g")
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
                Button ( action: { onAdd(storageLocation, expiryDate, Int(amount) ?? 0) } ) {
                    OrangeButton(text: "추가하기", size: .big)
                        .frame(height: 57)
                }
            }.padding(.bottom, 25)
        }.padding(.horizontal) // end of ZStack
    } // end of body
}

#Preview {
    let mockIngredient = IngredientForAddition(
        id: 101,
        name: "대파",
        category: .vegetable,
        unit: "g",
        amount: 0,
        isSaved: true
    )
    IngredientAdditionBottomSheet(
        ingredient: mockIngredient,
        onAdd: { storage, date, amount in
            print("추가 요청: \(storage.displayName), 날짜: \(date), 중량: \(amount)g")
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
