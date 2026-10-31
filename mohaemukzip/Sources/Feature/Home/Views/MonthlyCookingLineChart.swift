import SwiftUI
import Charts

struct MonthlyCookingPoint: Identifiable, Equatable {
    let month: Int   // 1...12
    let count: Int
    var id: Int { month }
}

struct MonthlyCookingLineChart: View {
    let points: [MonthlyCookingPoint]
    private let lineColor = Color(red: 1, green: 0.55, blue: 0.14)

    init(points: [MonthlyCookingPoint] = []) {
        self.points = points
    }

    var body: some View {
        // Refresh the month when the screen stays open across a date change.
        TimelineView(.periodic(from: .now, by: 60)) { context in
            chart(currentMonth: Calendar.current.component(.month, from: context.date))
        }
    }

    private func chart(currentMonth: Int) -> some View {
        let months = (1...12).map { month in
            MonthlyCookingPoint(month: month, count: points.first { $0.month == month }?.count ?? 0)
        }
        let maxY = Double(max(months.map(\.count).max() ?? 0, 1))

        return VStack(alignment: .trailing, spacing: 8) {
            Text("단위: 월")
                .font(.custom("Pretendard-Regular", size: 12))
                .foregroundStyle(.grey500)
                .padding(.trailing, 4)

            GeometryReader { geometry in
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(spacing: 10) {
                            Chart {
                                ForEach([0.0, maxY / 2, maxY], id: \.self) { value in
                                    RuleMark(y: .value("기준", value))
                                        .foregroundStyle(Color.grey300)
                                        .lineStyle(StrokeStyle(lineWidth: 0.5))
                                }
                                ForEach(months) { point in
                                    LineMark(x: .value("월", point.month), y: .value("요리 횟수", point.count))
                                        .interpolationMethod(.linear)
                                        .lineStyle(StrokeStyle(lineWidth: 1))
                                        .foregroundStyle(lineColor)
                                    PointMark(x: .value("월", point.month), y: .value("요리 횟수", point.count))
                                        .symbolSize(28)
                                        .foregroundStyle(lineColor)
                                        .annotation(position: .top, spacing: 10) {
                                            if point.month == currentMonth {
                                                countBubble(point.count)
                                            }
                                        }
                                        .accessibilityLabel("\(point.month)월")
                                        .accessibilityValue("\(point.count)회")
                                }
                            }
                            .chartXScale(domain: 0.5...12.5)
                            .chartYScale(domain: 0...maxY)
                            .chartXAxis(.hidden)
                            .chartYAxis(.hidden)
                            .chartLegend(.hidden)
                            .frame(height: 57)
                            .padding(.top, 30)

                            HStack(spacing: 0) {
                                ForEach(months) { point in
                                    Text("\(point.month)")
                                        .font(.PretendardRegular13)
                                        .foregroundStyle(.grey700)
                                        .frame(width: geometry.size.width / 6)
                                        .id(point.month)
                                }
                            }
                        }
                        .frame(width: geometry.size.width * 2)
                        .padding(.bottom, 2)
                    }
                    .onAppear { scrollProxy.scrollTo(currentMonth, anchor: .trailing) }
                    .onChange(of: currentMonth) { _, month in
                        scrollProxy.scrollTo(month, anchor: .trailing)
                    }
                }
            }
            .frame(height: 115)
        }
    }

    private func countBubble(_ count: Int) -> some View {
        Text("\(count)회")
            .font(.PretendardMedium12)
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color(white: 0.43), in: RoundedRectangle(cornerRadius: 6))
            .overlay(alignment: .bottom) {
                Triangle()
                    .fill(Color(white: 0.43))
                    .frame(width: 8, height: 5)
                    .offset(y: 5)
            }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

