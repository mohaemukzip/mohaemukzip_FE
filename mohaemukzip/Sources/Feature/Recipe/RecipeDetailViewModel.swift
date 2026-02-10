//
// MARK: - RecipeDetailViewModel
// 레시피 상세 화면(RecipeDetailView)을 위한 전용 ViewModel
// 목록 화면용 ViewModel과 분리되어 있지만, 동일한 RecipeVideo 모델을 사용함

//  RecipeDetailViewModel.swift
//  mohaemukzip
//
//  Created by 고석현 on 1/23/26.
//

import Foundation
import Combine


// MARK: - SummaryGenerationCoordinator
// 여러 ViewModel 인스턴스가 동시에 생성되더라도(예: SwiftUI 재렌더/네비게이션),
// 동일 recipeId에 대한 요약 생성 POST(/summary)은 앱 전체에서 1번만 날아가도록 보장한다.
private actor SummaryGenerationCoordinator {
    static let shared = SummaryGenerationCoordinator()

    private var inFlight: [Int: Task<(summaryExists: Bool, stepCount: Int), Never>] = [:]

    func task(recipeId: Int, service: RecipeService) -> Task<(summaryExists: Bool, stepCount: Int), Never> {
        if let existing = inFlight[recipeId] {
            return existing
        }

        let task = Task { [service] in
            await service.generateSummary(recipeId: recipeId)
        }

        inFlight[recipeId] = task

        Task { [weak self] in
            _ = await task.value
            await self?.remove(recipeId: recipeId)
        }

        return task
    }

    private func remove(recipeId: Int) {
        inFlight[recipeId] = nil
    }

    func cancel(recipeId: Int) {
        inFlight[recipeId]?.cancel()
        inFlight[recipeId] = nil
    }
}




@MainActor
final class RecipeDetailViewModel: ObservableObject {

    // MARK: - 상태 값 (View에서 구독)

    /// 현재 상세 화면에서 보여줄 레시피 데이터
    @Published private(set) var recipe: RecipeVideo?
    /// 상세 정보 로딩 여부
    @Published private(set) var isLoading: Bool = false
    /// 에러 발생 시 사용자에게 보여줄 메시지
    @Published private(set) var errorMessage: String?
    /// 북마크 요청 중복 방지를 위한 처리 상태
    @Published private(set) var isBookmarkUpdating: Bool = false

    /// 요리 완료(평점 등록) 요청 중복 방지를 위한 처리 상태
    @Published private(set) var isCompletingCooking: Bool = false

    /// 요리 완료 성공 시, 화면 dismiss 트리거 (View에서 onChange로 감지)
    @Published var shouldDismissAfterComplete: Bool = false

    /// 마지막으로 전송한 별점(디버깅/필요 시 UI 표시용)
    @Published private(set) var lastSubmittedRating: Int?

    /// 요리 완료 결과(점수/레벨업 등) - 필요 시 UI에서 사용
    @Published private(set) var completeResult: RecipeResponseDTO.CompleteRecipeResponse?

    /// 요리 완료 응답의 레벨(소수)을 UI에서 쓰기 좋은 형태로 변환한 값
    /// - Note: 서버는 recipeLevel을 소수로 내려줄 수 있다(예: 3.666...).
    ///         UI에서는 반올림한 정수 레벨을 사용한다.
    var roundedRecipeLevel: Int? {
        guard let level = completeResult?.recipeLevel else { return nil }
        return Int(level.rounded())
    }

    /// 필요 시 소수 1자리까지 표현하는 레벨(예: 3.7)
    var recipeLevelOneDecimal: Double? {
        guard let level = completeResult?.recipeLevel else { return nil }
        return (level * 10).rounded() / 10
    }

    /// 요약(스텝) 생성 진행 여부 (summaryExists == false일 때 사용)
    @Published private(set) var isGeneratingSummary: Bool = false

    /// 요약(스텝) 생성 실패 메시지 (필요 시 View에서 노출)
    @Published private(set) var summaryErrorMessage: String?

    // MARK: - 초기화

    private let service: RecipeService

    /// 상세 로딩 중복 호출 방지용 Task
    private var loadTask: Task<Void, Never>?

    /// 동일 recipeId에 대해 summary 생성 API 중복 호출 방지
    private var lastSummaryRequestedRecipeId: Int?

    /// summary 생성 이후 상세 재조회(steps 반영) 폴링 Task
    private var summaryPollingTask: Task<Void, Never>?


    /// 동일 recipeId 로딩 중 onAppear 등으로 중복 호출되는 것을 막기 위한 값
    private var currentLoadingRecipeId: Int?

    /// 서비스 주입용 init
    /// - Note:
    ///   - Swift 6에서는 기본 파라미터로 `RecipeService()`를 생성하면
    ///     nonisolated 컨텍스트에서 MainActor init을 호출하는 에러가 날 수 있다.
    init(
        recipe: RecipeVideo? = nil,
        service: RecipeService
    ) {
        self.recipe = recipe
        self.service = service
    }

    /// 기본 생성용 init
    /// - Note:
    ///   - RecipeService() 생성은 MainActor에서만 수행한다.
    @MainActor
    convenience init(recipe: RecipeVideo? = nil) {
        self.init(recipe: recipe, service: RecipeService())
    }

    // MARK: - 외부에서 호출하는 기능

    /// 상세 화면 진입 시 호출
    /// - recipeId: 상세 조회할 레시피 ID (Path Variable)
    /// - base: 목록 화면에서 전달받은 기본 레시피 정보 (선택)
    ///         없을 경우 최소 정보만으로 더미 데이터 구성
    func load(recipeId: Int, base: RecipeVideo? = nil) {
        // 중복 로드 방지
        // - 같은 recipeId를 로딩 중인데 onAppear 등으로 다시 호출되는 경우는 무시
        if currentLoadingRecipeId == recipeId, loadTask != nil {
            #if DEBUG
            print("[RecipeDetailVM] ⚠️ load ignored | already loading recipeId=\(recipeId)")
            #endif
            return
        }

        // 이전 레시피 로딩/요약 작업이 남아있는데 다른 recipeId로 진입하면 정리한다.
        if let inFlightId = currentLoadingRecipeId, inFlightId != recipeId {
            loadTask?.cancel()
        summaryPollingTask?.cancel()
        } else {
            // 같은 recipeId로 재진입(onAppear 중복 등)인 경우:
            // - 진행 중인 생성/폴링 Task를 살려두고, 아래의 loadTask 중복 방지 가드로 막는다.
        }

        currentLoadingRecipeId = recipeId

        isLoading = true
        isGeneratingSummary = false
        summaryErrorMessage = nil
        errorMessage = nil
        shouldDismissAfterComplete = false
        lastSubmittedRating = nil
        completeResult = nil

        // 목록에서 전달된 base가 있으면, 네트워크 로딩 동안 화면에 먼저 보여준다.
        if let base {
            recipe = base
        }

        loadTask = Task { [weak self] in
            guard let self else { return }
            defer {
                // 이 load 작업이 완전히 끝난 뒤에만 로딩 상태를 해제한다.
                if self.currentLoadingRecipeId == recipeId {
                    self.currentLoadingRecipeId = nil
                }
                self.loadTask = nil
            }

            do {
                let categoryId = self.categoryId(from: base)

                // 1) 상세 조회 먼저
                let detail = try await self.service.fetchRecipeDetail(
                    recipeId: recipeId,
                    categoryId: categoryId
                )

                // 상세 정보는 즉시 반영해서 UI를 먼저 띄운다.
                self.recipe = detail
                self.isLoading = false

                #if DEBUG
                print("[RecipeDetailVM] ✅ detail fetched | recipeId=\(recipeId) steps=\(detail.steps?.count ?? 0) summaryExists=\(detail.summaryExists ?? false)")
                #endif

                // 2) summaryExists == false이면 요약 생성(중복 방지) → steps 반영될 때까지 백오프 폴링
                guard detail.summaryExists == false else { return }

                self.isGeneratingSummary = true
                self.summaryErrorMessage = nil

                // 동일 recipeId에 대한 요약 생성은 앱 전체에서 1번만 호출되도록(coordinator) 보장한다.
                // - SwiftUI에서 View/VM이 중복 생성되더라도 POST가 2번 나가지 않게 함
                let generationTask = await SummaryGenerationCoordinator.shared.task(
                    recipeId: recipeId,
                    service: self.service
                )

                #if DEBUG
                print("[RecipeDetailVM] ⏳ await generateSummary (coalesced) | recipeId=\(recipeId)")
                #endif

                let summary = await generationTask.value

                // generateSummary는 실패 시 (false, 0)을 반환한다.
                // 응답에서 summaryExists=true가 확인된 경우에만 상세 재조회(폴링)로 넘어간다.
                guard summary.summaryExists == true else {
                    self.isGeneratingSummary = false
                    self.summaryErrorMessage = "해당 영상은 자막을 제공하지 않아 요약할 수 없어요!"

                    #if DEBUG
                    print("[RecipeDetailVM] ❌ summary generate failed | recipeId=\(recipeId) stepCount=\(summary.stepCount)")
                    #endif
                    return
                }

                #if DEBUG
                print("[RecipeDetailVM] ✅ summary generated | recipeId=\(recipeId) stepCount=\(summary.stepCount)")
                #endif

                // 요약 생성 응답에서 summaryExists=true가 확인되면,
                // steps가 실제로 붙을 때까지 상세 조회를 짧게 백오프로 재시도한다.
                do {
                    let refreshed = try await self.pollDetailUntilStepsReady(
                        recipeId: recipeId,
                        categoryId: categoryId
                    )

                    self.recipe = refreshed
                    self.isGeneratingSummary = false

                    #if DEBUG
                    print("[RecipeDetailVM] ✅ detail refreshed after polling | recipeId=\(recipeId) steps=\(refreshed.steps?.count ?? 0) summaryExists=\(refreshed.summaryExists ?? false)")
                    #endif
                } catch is CancellationError {
                    #if DEBUG
                    print("[RecipeDetailVM] ⚠️ polling cancelled | recipeId=\(recipeId)")
                    #endif
                    self.isGeneratingSummary = false
                    return
                } catch {
                    self.isGeneratingSummary = false
                    self.summaryErrorMessage = "요약이 아직 반영되지 않았습니다. 잠시 후 다시 시도해주세요."

                    #if DEBUG
                    print("[RecipeDetailVM] ❌ polling failed | recipeId=\(recipeId) error=\(error)")
                    #endif
                }
            } catch is CancellationError {
                // 취소는 무시
                #if DEBUG
                print("[RecipeDetailVM] ⚠️ load cancelled | recipeId=\(recipeId)")
                #endif
                // defer에서 공통 정리
                return
            } catch {
                #if DEBUG
                print("[RecipeDetailVM] ❌ load fail | recipeId=\(recipeId) error=\(error)")
                #endif
                self.isLoading = false
                self.isGeneratingSummary = false
                self.errorMessage = "레시피 상세를 불러오지 못했습니다."
                // defer에서 공통 정리
            }
        }
    }

    /// 상세 화면에서 북마크 버튼 클릭 시 호출
    /// - Note:
    ///   - 목록 화면과 동일하게 서버 응답 기준으로만 상태를 갱신한다.
    ///   - optimistic update를 제거하여 UI/상태 불일치를 방지한다.
    func toggleBookmark() {
        guard let current = recipe else {
            #if DEBUG
            print("[RecipeDetailVM] ❌ toggleBookmark ignored | recipe is nil")
            #endif
            return
        }

        // 중복 요청 방지 (리스트와 동일한 수준의 최소 제어)
        guard !isBookmarkUpdating else {
            #if DEBUG
            print("[RecipeDetailVM] ⚠️ toggleBookmark ignored | already updating")
            #endif
            return
        }

        let recipeId = current.id
        isBookmarkUpdating = true

        Task {
            do {
                let serverState = try await service.toggleBookmark(recipeId: recipeId)

                // 서버 응답 기준으로만 상태 반영
                self.updateBookmarkState(serverState)
                self.isBookmarkUpdating = false

                #if DEBUG
                print("[RecipeDetailVM] ✅ bookmark toggled | recipeId=\(recipeId) isBookmarked=\(serverState)")
                #endif
            } catch {
                self.isBookmarkUpdating = false
                self.errorMessage = "북마크 처리에 실패했습니다. 네트워크 상태를 확인해주세요."

                #if DEBUG
                print("[RecipeDetailVM] ❌ bookmark toggle fail | recipeId=\(recipeId) error=\(error)")
                #endif
            }
        }
    }

    /// 요리 완료(평점 등록) 버튼 클릭 시 호출
    /// - Parameters:
    ///   - rating: 사용자가 선택한 별점(1~5)
    /// - Note:
    ///   - 성공 시 completeResult에 서버 결과를 저장한다.
    func completeCooking(rating: Int) {
        guard !isCompletingCooking else { return }
        guard let current = recipe else { return }

        // 별점 범위 안전 처리
        let safeRating = max(1, min(5, rating))
        lastSubmittedRating = safeRating

        isCompletingCooking = true
        errorMessage = nil
        completeResult = nil

        Task {
            do {
                let result = try await service.completeRecipe(recipeId: current.id, rating: safeRating)
                self.completeResult = result
                self.isCompletingCooking = false
                self.shouldDismissAfterComplete = true

                #if DEBUG
                print("[RecipeDetailVM] ✅ complete success | recipeId=\(current.id) rating=\(safeRating) reward=\(result.rewardScore) leveledUp=\(result.leveledUp)")
                #endif
            } catch {
                self.isCompletingCooking = false
                self.shouldDismissAfterComplete = false
                self.errorMessage = "요리 완료 처리에 실패했습니다. 네트워크 상태를 확인해주세요."

                #if DEBUG
                print("[RecipeDetailVM] ❌ complete fail | recipeId=\(current.id) rating=\(safeRating) error=\(error)")
                #endif
            }
        }
    }

    /// 현재 recipe의 북마크 상태만 안전하게 갱신
    private func updateBookmarkState(_ isBookmarked: Bool) {
        guard var current = recipe else { return }
        current.isBookmarked = isBookmarked
        recipe = current
    }

    // MARK: - Summary Polling

    /// 요약 생성 직후 상세 조회를 바로 하면 steps가 아직 반영되지 않을 수 있어,
    /// 짧은 백오프(점진적 지연)로 제한 횟수만 재시도한다.
    private func pollDetailUntilStepsReady(
        recipeId: Int,
        categoryId: Int?
    ) async throws -> RecipeVideo {
        // 너무 공격적으로 호출하지 않도록 점진적 백오프 적용
        let delays: [UInt64] = [800_000_000, 1_200_000_000, 2_000_000_000, 3_000_000_000, 4_000_000_000]

        // 첫 시도는 즉시 1회
        var latest = try await service.fetchRecipeDetail(recipeId: recipeId, categoryId: categoryId)
        if (latest.steps?.isEmpty == false) || (latest.summaryExists == true) {
            return latest
        }

        for (idx, ns) in delays.enumerated() {
            try Task.checkCancellation()
            try await Task.sleep(nanoseconds: ns)

            latest = try await service.fetchRecipeDetail(recipeId: recipeId, categoryId: categoryId)

            #if DEBUG
            print("[RecipeDetailVM] 🔄 polling detail | attempt=\(idx + 2) recipeId=\(recipeId) steps=\(latest.steps?.count ?? 0) summaryExists=\(latest.summaryExists ?? false)")
            #endif

            if (latest.steps?.isEmpty == false) || (latest.summaryExists == true) {
                return latest
            }
        }

        // 여기까지 왔는데도 steps가 없으면 타임아웃으로 처리
        return latest
    }

    // MARK: - CategoryId Mapping

    /// 상세 API에는 categoryId가 없어서, 목록에서 전달된 base를 기준으로 categoryId를 복원한다.
    private func categoryId(from base: RecipeVideo?) -> Int? {
        guard let base else { return nil }

        switch base.cuisine {
        case .korean:
            guard let sub = base.koreanSubCategory else { return nil }
            switch sub {
            case .soupStew: return 1
            case .rice: return 2
            case .noodle: return 3
            case .stirFry: return 4
            case .braised: return 5
            case .pancake: return 6
            case .grill: return 7
            case .mixed: return 8
            case .sideDish: return 9
            case .kimchi: return 10
            }

        case .chinese:
            guard let sub = base.chineseSubCategory else { return nil }
            switch sub {
            case .noodle: return 11
            case .friedRice: return 12
            case .riceBowl: return 13
            case .stirFry: return 14
            case .deepFried: return 15
            case .soup: return 16
            case .mara: return 17
            case .meat: return 18
            case .seafood: return 19
            case .dumpling: return 20
            }

        case .japanese:
            guard let sub = base.japaneseSubCategory else { return nil }
            switch sub {
            case .riceBowl: return 21
            case .noodle: return 22
            case .soup: return 23
            case .stirFry: return 24
            case .braised: return 25
            case .deepFried: return 26
            case .grill: return 27
            case .lunchBox: return 28
            case .seafood: return 29
            case .egg: return 30
            }

        case .western:
            guard let sub = base.westernSubCategory else { return nil }
            switch sub {
            case .pasta: return 31
            case .risotto: return 32
            case .stirFry: return 33
            case .steak: return 34
            case .oven: return 35
            case .salad: return 36
            case .soup: return 37
            case .brunch: return 38
            case .pizza: return 39
            case .cheese: return 40
            }

        case .southeastAsian:
            guard let sub = base.southeastAsianSubCategory else { return nil }
            switch sub {
            case .rice: return 41
            case .riceNoodle: return 42
            case .noodle: return 43
            case .soup: return 44
            case .stirFry: return 45
            case .deepFried: return 46
            case .curry: return 47
            case .meat: return 48
            case .seafood: return 49
            case .salad: return 50
            }
        case .none:
            return nil
        }
    }
}
