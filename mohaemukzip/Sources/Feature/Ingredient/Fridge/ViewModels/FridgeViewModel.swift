import SwiftUI
import Combine
@Observable
class FridgeViewModel: ObservableObject {
    let service = FridgeService()
    let ingredientService = IngredientService()
    
    var allIngredients: [FridgeIngredient] = []
    
    // MARK: 냉동, 냉장, 실온 -> 서버에서 받은 allIngredient를 분기처리할 것
    var frozenIngredients: [FridgeIngredient] {
        allIngredients.filter { $0.storage == .frozen }
    }
    var chilledIngredients: [FridgeIngredient] {
        allIngredients.filter { $0.storage == .chilled }
    }
    var roomIngredients: [FridgeIngredient] {
        allIngredients.filter { $0.storage == .room }
    }
    
    func fetchList() async {
        do {
            self.allIngredients = try await service.getIngredients()
        } catch {
            print("재료 목록을 불러올 수 없음: \(error)")
        }
    }
    
    func deleteIngredient(at id: Int) async {
        do {
            try await service.deleteIngredient(id: id)
            await fetchList()
            
            print("재료 삭제 성공")
        } catch {
            print("재료 삭제 실패: \(error)")
        }
    }
    
    func addIngredient(id: Int, ty: String, date: Date, amount: Double) async {
        do {
            let dateString = IngredientDateFormatter.apiString(from: date)
            
            try await service.addIngredient(id: id, ty: ty, date: dateString, amount: amount)
            await fetchList()
            
            print("재료 추가 성공")
        } catch {
            print("재료 추가 실패: \(error)")
        }
    }
    
    // 냉장고 재료 수정 바텀시트에서 북마크 토글 API 호출 함수
    // 여기 쓰이는 id는 ingredientId
    func toggleSaved(id: Int) async {
        do {
            try await ingredientService.addSaved(id: id)
            await fetchList()
        } catch {
            print("즐겨찾기 변경 실패: \(error)")
        }
    }
    
    // 냉장고 재료 수정 바텀시트에서 소비기한 추천 API 호출 함수
    // 여기 쓰이는 id는 ingredientId
    func getRecommendedDate(id: Int) async -> Date? {
        do {
            let dateString = try await ingredientService.getRecommendedDate(id: id)
            return IngredientDateFormatter.date(from: dateString)
        } catch {
            print("추천 날짜 조회 실패: \(error)")
            return nil
        }
    }
    
    // 냉장고 재료 수정 바텀시트에서 재료 수정 API 호출 함수
    // 여기에 쓰이는 id는 memberIngredientId
    func updateIngredient(id: Int, ty: String, date: Date, amount: Double) async {
        do {
            let dateString = IngredientDateFormatter.apiString(from: date)

            try await service.updateIngredient(
                id: id,
                ty: ty,
                date: dateString,
                amount: amount
            )

            await fetchList()
        } catch {
            print("재료 수정 실패: \(error)")
        }
    }
}
