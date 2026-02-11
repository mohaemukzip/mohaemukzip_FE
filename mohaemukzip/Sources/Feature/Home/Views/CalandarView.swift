
import SwiftUI
struct CalandarView: View {
    
    // MARK: - Inputs
    
    @State private var displayedMonth: Date
    private let stickerDates: Set<Date>
    private let stickerImageName: String
    
    // MARK: - Init
    
    init(
        initialMonth: Date = Date(),
        stickerDates: Set<Date> = [],
        stickerImageName: String = "icn_bab"
    ) {
        let cal = Calendar.current
        // month의 1일로 정규화
        let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: initialMonth)) ?? initialMonth
        _displayedMonth = State(initialValue: monthStart)
        self.stickerDates = stickerDates
        self.stickerImageName = stickerImageName
    }
    
    // MARK: - Calendar
    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.locale = Locale(identifier: "ko_KR")
        cal.timeZone = .current
        return cal
    }()
    
    private let weekdaySymbols: [String] = ["일", "월", "화", "수", "목", "금", "토"]
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            weekdayRow
            monthGrid
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - UI
private extension CalandarView {
    var header: some View {
        HStack {
            Text(monthTitle(displayedMonth))
                .font(.PretendardMedium16)
                .foregroundStyle(.grey900)
            
            Spacer()
            
            Button {
                displayedMonth = addMonths(displayedMonth, value: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.PretendardMedium16)
                    .foregroundStyle(.grey700)
            }
            .buttonStyle(.plain)
            
            Button {
                displayedMonth = addMonths(displayedMonth, value: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.PretendardMedium16)
                    .foregroundStyle(.grey700)
            }
            .buttonStyle(.plain)
        }
    }
    
    var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { idx, day in
                Text(day)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(weekdayColor(index: idx))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 4)
    }
    
    var monthGrid: some View {
        let days = makeDays(for: displayedMonth)
        return LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
            spacing: 14
        ) {
            ForEach(days) { item in
                DayCell(
                    item: item,
                    stickerImageName: stickerImageName,
                    hasSticker: item.date.map(hasSticker) ?? false
                )
            }
        }
        .padding(.top, 6)
    }
}

// MARK: - Day Cell
private struct DayCell: View {
    let item: CalendarDayItem
    let stickerImageName: String
    let hasSticker: Bool
    
    var body: some View {
        if let day = item.dayNumber {
            ZStack {
                // 1) 날짜 숫자: 셀 아래쪽에 고정
                VStack {
                    Spacer(minLength: 0)
                    Text("\(day)")
                        .font(.PretendardRegular16)
                        .foregroundStyle(.grey900)
                }
                
                // 2) 스티커: 날짜 위에 올리기
                VStack {
                    if hasSticker {
                        Image(stickerImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                            .offset(y: 12)
                    } else {
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    Spacer(minLength: 0)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
        } else {
            Color.clear
                .frame(height: 44)
        }
    }
}

// MARK: - 캘린더 model

private struct CalendarDayItem: Identifiable, Equatable {
    let id: UUID = UUID()
    let date: Date?
    let dayNumber: Int?
}

// MARK: - 캘린더 만들기

private extension CalandarView {
    func monthTitle(_ date: Date) -> String {
        let comps = calendar.dateComponents([.year, .month], from: date)
        let year = comps.year ?? 0
        let month = comps.month ?? 0
        return "\(year)년 \(month)월"
    }
    
    func addMonths(_ date: Date, value: Int) -> Date {
        calendar.date(byAdding: .month, value: value, to: date) ?? date
    }
    
    func weekdayColor(index: Int) -> Color {
        if index == 0 { return .red }
        if index == 6 { return .blue }
        return .gray
    }
    
    func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }
    
    func hasSticker(_ date: Date) -> Bool {
        stickerDates.contains(startOfDay(date))
    }
    
    func makeDays(for month: Date) -> [CalendarDayItem] {
        guard
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
            let range = calendar.range(of: .day, in: .month, for: monthStart)
        else { return [] }
        
        // monthStart의 요일: 1(일)~7(토)
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingBlanks = firstWeekday - 1
        
        var items: [CalendarDayItem] = []
        items.reserveCapacity(leadingBlanks + range.count)
        
        for _ in 0..<leadingBlanks {
            items.append(.init(date: nil, dayNumber: nil))
        }
        
        for day in range {
            var comps = calendar.dateComponents([.year, .month], from: monthStart)
            comps.day = day
            let date = calendar.date(from: comps)
            items.append(.init(date: date, dayNumber: day))
        }
        
        return items
    }
}

extension CalandarView {
    static func makeStickerDates(from serverDateStrings: [String]) -> Set<Date> {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        
        let cal = Calendar.current
        var set: Set<Date> = []
        for s in serverDateStrings {
            if let d = formatter.date(from: s) {
                set.insert(cal.startOfDay(for: d))
            }
        }
        return set
    }
}
