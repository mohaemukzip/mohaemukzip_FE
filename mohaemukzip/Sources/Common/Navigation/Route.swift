//
//  Route.swift
//  mohaemukzip
//
//  Created by 이한결 on 1/26/26.
//

import Foundation

enum Route: Hashable {
    case ingredientSearch
    case ingredientDetailSearch
    case yoTeacher
    case recipeDetail(RecipeVideo)
    case recipeSearch
    case home
    //MARK: - 마이페이지 추가
    case profileSettings
    case profileChange
    case recentlyViewedRecipes
    case bookmarkedRecipes
//    case recipeDetailNoComplete(RecipeDetail)
    //목록에서 상세화면 넘어가는거 필요할떄, 레시피 아이디만 이렇게 넘겨주면 돼요~
    case recipeDetailById(Int)
 

    
}
