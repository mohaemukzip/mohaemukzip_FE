import Foundation


enum RecipeRequestDTO {


    struct SearchRecipesRequest: Encodable {

        /// 서버에서 정의한 세부 카테고리 ID
        let categoryId: Int

        /// (선택) 페이지 인덱스
        let page: Int?

        /// (선택) 페이지 사이즈
        let size: Int?

        init(
            categoryId: Int,
            page: Int? = nil,
            size: Int? = nil
        ) {
            self.categoryId = categoryId
            self.page = page
            self.size = size
        }
    }

    // MARK: - Complete Recipe
    struct CompleteRecipeRequest: Encodable {

        /// 사용자가 선택한 별점(1~5)
        let rating: Int

        init(rating: Int) {
            self.rating = rating
        }
    }

    // MARK: - Empty Body
    /// 바디 없이 호출하는 POST 요청을 의미적으로 표현하기 위한 빈 DTO
    /// - 예) /recipes/{recipeId}/summary, /recipes/{recipeId}/bookmark
    struct EmptyRequest: Encodable {
        init() {}
    }
}
