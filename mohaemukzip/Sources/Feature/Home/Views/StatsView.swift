//
//  StatsView.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/27/26.
//

import SwiftUI


// MARK: - Stats View (Scaffold)
struct StatsView: View {
    @Binding var isHomePowerInfoPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            statsSummarySection
            monthlyCookingChartSection
            calendarSection
        }
        .padding(.horizontal, 17)
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
                statItem(icon: "statIcon3", title: "냉장고 점수", value: "75", suffix: "/100점")
                statItem(icon: "statIcon3", title: "누적 요리 횟수", value: "42", suffix: "회")
                statItem(icon: "statIcon3", title: "도전 난이도", value: "3.8", suffix: "/5점")
            }
            .padding(16)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.top, 20)
    }
    
    
    func statItem(icon: String, title: String, value: String, suffix: String) -> some View {
        VStack(spacing: 10) {
            Image(icon)
                .frame(width: 60, height: 60)
                .padding(.top, 7)
                .padding(.bottom, 12)
            
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
            
            MonthlyCookingLineChart(points: sampleMonthlyPoints)
                .frame(height: 130)
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    var sampleMonthlyPoints: [MonthlyCookingPoint] {
        [
            .init(month: 1, count: 2),
            .init(month: 2, count: 3),
            .init(month: 3, count: 1),
            .init(month: 4, count: 3),
            .init(month: 5, count: 4),
            .init(month: 6, count: 5),
            .init(month: 7, count: 5),
            .init(month: 8, count: 6),
            .init(month: 9, count: 7),
            .init(month: 10, count: 6),
            .init(month: 11, count: 6),
            .init(month: 12, count: 1)
        ]
    }
    
    var calendarSection: some View {
        // TODO: 서버에서 내려준 날짜 배열을 받아서 아래처럼 Set<Date>로 변환해서 넣으면 됨
        // 예) let stickerDates = CalandarView.makeStickerDates(from: dto.stickerDates)
        let serverDates = ["2026-01-08", "2026-01-09", "2026-01-10", "2026-01-13", "2026-01-14", "2026-01-15"]
        let stickerDates = CalandarView.makeStickerDates(from: serverDates)
        
        return CalandarView(
            initialMonth: Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 1)) ?? Date(),
            stickerDates: stickerDates,
            stickerImageName: "icn_bab"
        )
    }
}

// MARK: - Preview
#Preview {
    StatsView(isHomePowerInfoPresented: .constant(false))
        .background(Color(.systemGroupedBackground))
}
