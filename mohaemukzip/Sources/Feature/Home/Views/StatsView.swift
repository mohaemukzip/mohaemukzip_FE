
import SwiftUI

struct StatsView: View {
    @Binding var isHomePowerInfoPresented: Bool
    @State private var viewModel = StatsViewModel()
    private var loadsRemoteData = true

    init(isHomePowerInfoPresented: Binding<Bool>, loadsRemoteData: Bool = true) {
        _isHomePowerInfoPresented = isHomePowerInfoPresented
        self.loadsRemoteData = loadsRemoteData
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            statsSummarySection
                .padding(.bottom, 20)
            monthlyCookingChartSection
            calendarSection
        }
        .task {
            if loadsRemoteData {
                await viewModel.load()
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .background(.grey100)
    }
}

private extension StatsView {
    var statsSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text("나의 집밥력")
                    .font(.PretendardSemibold20)
                    .foregroundStyle(.grey900)
                Button {
                    isHomePowerInfoPresented = true
                } label: {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 14))
                        .foregroundStyle(.grey400)
                }
                .buttonStyle(.plain)
            }
            
            HStack(spacing: 12) {
                statItem(icon: "statIcon1", title: "냉장고 점수", value: "\(viewModel.fridgeScore)", suffix: "/100점")
                statItem(icon: "statIcon2", title: "누적 요리 횟수", value: "\(viewModel.totalCookingCount)", suffix: "회")
                statItem(icon: "statIcon3", title: "도전 난이도", value: viewModel.averageDifficultyText, suffix: "/5점")
            }
            .padding(16)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.top, 20)
    }
    
    
    func statItem(icon: String, title: String, value: String, suffix: String) -> some View {
        VStack(spacing: 6) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .padding(.bottom, 6)
            
            Text(title)
                .font(.PretendardMedium14)
                .foregroundStyle(.grey900)
            
            HStack(spacing: 2) {
                Text(value)
                    .font(.PretendardSemibold18)
                    .foregroundStyle(.grey900)
                Text(suffix)
                    .font(.PretendardMedium14)
                    .foregroundStyle(.grey500)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    var monthlyCookingChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("월별 집밥 횟수")
                .font(.PretendardSemibold20)
                .foregroundStyle(.grey900)
            
            MonthlyCookingLineChart(points: viewModel.monthlyPoints)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    var calendarSection: some View {
        CalandarView(
            initialMonth: viewModel.initialMonthDate,
            stickerDates: viewModel.stickerDates,
            stickerImageName: "icn_bab"
        )
        .padding(.bottom, 20)
    }
}

#Preview("통계 · 신규 사용자") {
    ScrollView {
        StatsView(isHomePowerInfoPresented: .constant(false), loadsRemoteData: false)
    }
    .background(Color.grey100)
}
