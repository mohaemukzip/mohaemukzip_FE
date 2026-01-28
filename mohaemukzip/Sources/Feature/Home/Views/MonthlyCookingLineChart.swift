//
//  MonthlyCookingLineChart.swift
//  mohaemukzip
//
//  Created by 이서현 on 1/28/26.
//


import SwiftUI
import Charts

struct MonthlyCookingPoint: Identifiable, Equatable {
    let month: Int   // 1...12
    let count: Int
    var id: Int { month }
}

struct MonthlyCookingLineChart: View {
    let points: [MonthlyCookingPoint]
    
    init(points: [MonthlyCookingPoint]) {
        self.points = points
    }
    
    /// Preview / placeholder initializer
    init() {
        self.points = [
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
    
    private var maxY: Int {
        max(points.map(\.count).max() ?? 0, 1)
    }
    
    var body: some View {
        Chart {
            ForEach(points) { p in
                LineMark(
                    x: .value("Month", p.month),
                    y: .value("Count", p.count)
                )
                .interpolationMethod(.linear)
                .lineStyle(.init(lineWidth: 2.5))
                .foregroundStyle(Color.orange)
                
                PointMark(
                    x: .value("Month", p.month),
                    y: .value("Count", p.count)
                )
                .symbolSize(28)
                .foregroundStyle(Color.orange)
            }
        }
        .chartXScale(domain: 1...12)
        .chartXScale(range: .plotDimension(padding: 16))
        .chartYScale(domain: 0...maxY + 1)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .chartXAxis {
            AxisMarks(values: Array(1...12)) { value in
                AxisValueLabel {
                    if let m = value.as(Int.self) {
                        Text("\(m)월")
                            .font(.PretendardRegular13)
                            .foregroundStyle(.grey700)
                    }
                }
            }
        }
        .chartPlotStyle { plotArea in
            plotArea.background(Color.clear)
        }
    }
}



#Preview {
    MonthlyCookingLineChart()
}
