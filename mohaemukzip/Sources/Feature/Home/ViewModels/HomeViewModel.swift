//
//  HomeViewModel.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/26/26.
//
//

import SwiftUI

@MainActor
@Observable
final class HomeViewModel {
    var home: HomeModel?
    var isLoading: Bool = false
    var errorMessage: String?
    private let homeService = HomeService()
    private var loadTask: Task<Void, Never>?
    
    func load() async {
        loadTask?.cancel()

        loadTask = Task { [weak self] in
            guard let self else { return }

            self.isLoading = true
            self.errorMessage = nil
            defer { self.isLoading = false }

            do {
                let resultDTO = try await self.homeService.fetchHomeDashboard()
                guard !Task.isCancelled else { return }
                self.home = resultDTO.toModel()
            } catch {
                guard !Task.isCancelled else { return }
                self.errorMessage = "홈 정보를 불러오지 못했어요."
            }
        }
        await loadTask?.value
    }
}
