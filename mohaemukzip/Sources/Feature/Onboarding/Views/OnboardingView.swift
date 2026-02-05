//
//  OnboardingView.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/28/26.
//

import SwiftUI

struct OnboardingView: View {

    // MARK: - Types
    struct Page: Identifiable, Hashable {
        let id: Int
        let imageName: String
        let title: String
        let subtitle: String?

        var hasSubtitle: Bool { (subtitle?.isEmpty == false) }
    }

    // MARK: - Data
    private let pages: [Page] = [
        .init(
            id: 0,
            imageName: "onboarding1",
            title: "뭐해먹집에서 집밥을 게임처럼",
            subtitle: "요리할 때마다 경험치를 쌓고 퀘스트를 깨며 성장해요!"
        ),
        .init(
            id: 1,
            imageName: "onboarding2",
            title: "지금 나에게 맞는 레시피를 한 번에",
            subtitle: "취향, 난이도, 재료, 상태까지 반영하여 레시피를 검색해요."
        ),
        .init(
            id: 2,
            imageName: "onboarding3",
            title: "간단하게 확인하는 나의 냉장고",
            subtitle: "보유 재료와 유통기한을 한눈에 확인할 수 있어요."
        ),
        .init(
            id: 3,
            imageName: "onboarding4",
            title: "요선생이 도와주는 요리 생활",
            subtitle: "메뉴부터 레시피 요약까지, 요선생이 전 과정을 도와줘요."
        )
    ]

    // MARK: - State
    @State private var selection: Int = 0
    @EnvironmentObject private var router: AuthRouter
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(pages) { page in
                OnboardingPageView(page: page)
                    .tag(page.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(.white)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomControls
        }
        .navigationBarBackButtonHidden()
    }
    

    private var bottomControls: some View {
        // 고정 값 (디자인 스펙)
        let indicatorTop: CGFloat = 16
        let buttonTopGap: CGFloat = 34
        let buttonHeight: CGFloat = 57

        return VStack(spacing: 0) {
            PageIndicator(total: pages.count, current: selection)
                .padding(.top, indicatorTop)

            Spacer().frame(height: buttonTopGap)

            // ✅ 버튼 영역도 항상 같은 높이를 차지하게 (있을 때/없을 때 동일)
            if selection == pages.count - 1 {
                Button {
                    router.push(.start)
                } label: {
                    Text("다음으로")
                        .font(.PretendardSemibold18)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: buttonHeight)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.main400)
                        )
                }
                .buttonStyle(.plain)
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            router.push(.start)
                        } label: {
                            Text("건너뛰기")
                                .font(.PretendardRegular16)
                                .foregroundStyle(.grey500)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, 12) // safeAreaInset(38) + 12 = 50
                }
                .frame(height: buttonHeight)
            }
        }
        .padding(.horizontal, 17)
        .background(.white)
    }
}

// MARK: - 페이지 뷰

private struct OnboardingPageView: View {
    let page: OnboardingView.Page

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, 75)
                .padding(.horizontal, 17)
                .padding(.bottom, 60)

            Image(page.imageName)
                .resizable()
                .scaledToFit()

            Spacer(minLength: 0)
        }
        // ✅ TabView가 페이지를 세로 중앙 정렬하지 않도록, 화면을 꽉 채우고 top 정렬
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(page.title)
                .font(.PretendardSemibold24)
                .foregroundStyle(.grey900)
                .frame(maxWidth: .infinity, alignment: .leading)

            if page.hasSubtitle {
                Text(page.subtitle ?? "")
                    .font(.PretendardRegular16)
                    .foregroundStyle(.grey500)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineSpacing(2)
            }
        }
    }
}

// MARK: - 페이지 인디케이터

private struct PageIndicator: View {
    let total: Int
    let current: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                if index == current {
                    Capsule()
                        .frame(width: 16, height: 6)
                        .foregroundStyle(.grey900)
                } else {
                    Circle()
                        .frame(width: 6, height: 6)
                        .foregroundStyle(.grey300)
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(NavigationRouter())
}
