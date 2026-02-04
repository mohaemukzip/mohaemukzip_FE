//
//  RecipeRequestDTO.swift
//  mohaemukzip
//
//  Created by 고석현 on 2/4/26.
//

import Foundation

// MARK: - RecipeRequestDTO
// 레시피 도메인에서 사용하는 Request DTO
//
// 현재 레시피 API는 대부분 바디 없이 호출되거나(query만 존재) 요청 바디가 없는 형
// 그래도 화면/서비스 계층에서 파라미터를 명확히 관리하기 위해 RequestDTO로 한 번 감싼당
//
// 포함 범위
// 1) /search/recipes                : categoryId (+ page/size 옵션)
// 2) /recipes/{recipeId}/complete   : rating(1~5)
//
// /recipes/{recipeId}/summary, /recipes/{recipeId}/bookmark는 요청 바디가 없다.

enum RecipeRequestDTO {

    // MARK: - Search Recipes
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
