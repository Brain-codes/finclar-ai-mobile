import SwiftUI
import WidgetKit

enum FinclarWidgetLinks {
    static let spending = URL(string: "finclar://widget/spending")!
    static let addExpense = URL(string: "finclar://widget/add-expense")!
}

struct SpendingEntry: TimelineEntry {
    let date: Date
    let data: FinclarWidgetData
}

struct SpendingProvider: TimelineProvider {
    func placeholder(in context: Context) -> SpendingEntry {
        SpendingEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (SpendingEntry) -> Void) {
        let data = context.isPreview ? FinclarWidgetData.placeholder : FinclarWidgetData.load()
        completion(SpendingEntry(date: Date(), data: data))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SpendingEntry>) -> Void) {
        let entry = SpendingEntry(date: Date(), data: .load())
        // The app pushes fresh numbers on every dashboard refresh; this reload is
        // only a fallback so a widget left alone overnight still re-reads the store.
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct SpendingProgressBar: View {
    let data: FinclarWidgetData

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(FinclarTheme.track)
                Capsule()
                    .fill(data.isOverspent ? FinclarTheme.error : FinclarTheme.primary)
                    .frame(width: max(geo.size.width * data.spentFraction, data.totalExpense > 0 ? 6 : 0))
            }
        }
        .frame(height: 8)
    }
}

struct SpendingEmptyView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Finclar")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(FinclarTheme.primary)
            Text("Open the app to see this month's spending here.")
                .font(.system(size: 12))
                .foregroundStyle(FinclarTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct SpendingSmallView: View {
    let data: FinclarWidgetData

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Spent · \(data.monthLabel)")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(FinclarTheme.textSecondary)
                .lineLimit(1)

            Spacer(minLength: 4)

            Text(data.formatted(data.totalExpense))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(FinclarTheme.textPrimary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Spacer(minLength: 8)

            if data.monthlyIncome > 0 {
                SpendingProgressBar(data: data)
                Text(data.isOverspent
                     ? "Over by \(data.formatted(abs(data.balance)))"
                     : "\(data.formatted(data.balance)) left")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(data.isOverspent ? FinclarTheme.error : FinclarTheme.textSecondary)
                    .lineLimit(1)
                    .padding(.top, 6)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct SpendingMediumView: View {
    let data: FinclarWidgetData

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Spent · \(data.monthLabel)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(FinclarTheme.textSecondary)
                    .lineLimit(1)

                Spacer(minLength: 4)

                Text(data.formatted(data.totalExpense))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(FinclarTheme.textPrimary)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Spacer(minLength: 8)

                if data.monthlyIncome > 0 {
                    SpendingProgressBar(data: data)
                    Text(data.isOverspent
                         ? "Over budget by \(data.formatted(abs(data.balance)))"
                         : "\(data.formatted(data.balance)) left of \(data.formatted(data.monthlyIncome))")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(data.isOverspent ? FinclarTheme.error : FinclarTheme.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.top, 6)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                if let category = data.topCategoryName {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Top category")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(FinclarTheme.textSecondary)
                        Text(category)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(FinclarTheme.textPrimary)
                            .lineLimit(1)
                        Text(data.formatted(data.topCategoryAmount))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(FinclarTheme.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 0)

                Link(destination: FinclarWidgetLinks.addExpense) {
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                        Text("Add expense")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(FinclarTheme.primary))
                }
            }
            .frame(width: 108, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct SpendingCircularView: View {
    let data: FinclarWidgetData

    var body: some View {
        Gauge(value: data.spentFraction) {
            Image(systemName: "creditcard.fill")
        } currentValueLabel: {
            Text("\(Int(data.spentFraction * 100))%")
        }
        .gaugeStyle(.accessoryCircularCapacity)
    }
}

struct FinclarSpendingWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SpendingEntry

    var body: some View {
        content
            .containerBackground(for: .widget) {
                if family == .accessoryCircular || family == .accessoryRectangular {
                    Color.clear
                } else {
                    FinclarTheme.background
                }
            }
            .widgetURL(FinclarWidgetLinks.spending)
    }

    @ViewBuilder
    private var content: some View {
        if !entry.data.hasData {
            SpendingEmptyView()
        } else {
            switch family {
            case .accessoryCircular:
                SpendingCircularView(data: entry.data)
            case .systemMedium:
                SpendingMediumView(data: entry.data)
            default:
                SpendingSmallView(data: entry.data)
            }
        }
    }
}

struct FinclarSpendingWidget: Widget {
    let kind = "FinclarSpendingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SpendingProvider()) { entry in
            FinclarSpendingWidgetView(entry: entry)
        }
        .configurationDisplayName("Monthly spending")
        .description("How much you've spent this month and what's left.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
    }
}

@main
struct FinclarWidgetBundle: WidgetBundle {
    var body: some Widget {
        FinclarSpendingWidget()
    }
}
