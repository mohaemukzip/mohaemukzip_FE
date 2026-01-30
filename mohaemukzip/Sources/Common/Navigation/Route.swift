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
}
