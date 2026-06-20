import SwiftUI
import Combine
@Observable
class FridgeViewModel: ObservableObject {
    let service = FridgeService()
    
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
            let dateString = dateFormatter.string(from: date)
            
            try await service.addIngredient(id: id, ty: ty, date: dateString, amount: amount)
            await fetchList()
            
            print("재료 추가 성공")
        } catch {
            print("재료 추가 실패: \(error)")
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
