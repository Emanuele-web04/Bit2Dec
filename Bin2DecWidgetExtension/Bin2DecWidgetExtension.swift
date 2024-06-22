//
//  Bin2DecWidgetExtension.swift
//  Bin2DecWidgetExtension
//
//  Created by Emanuele Di Pietro on 21/06/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), conversiontype: .dec2Bit)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), conversiontype: .dec2Bit)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, conversiontype: .dec2Bit)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let conversiontype: ConversionType
}

struct Bin2DecWidgetExtensionEntryView : View {
    var entry: Provider.Entry
    @AppStorage("conversionType", store: UserDefaults(suiteName: "group.com.emanueledipietro.Bit2Dec")) var conversionType: ConversionType!

    var body: some View {
        VStack(alignment: .leading) {
            Text("Conversion").font(.callout).bold()
            VStack(alignment: .center, spacing: 8) {
                switch conversionType {
                case .bit2dec:
                    Text("From Binary").textStyleWidget()
                    Image(systemName: "arrow.down")
                    Text("To Decimal").textStyleWidget()
                case .dec2Bit:
                    Text("From Decimal").textStyleWidget()
                    Image(systemName: "arrow.down")
                    Text("To Binary").textStyleWidget()
                case .dec2hex:
                    Text("From Decimal").textStyleWidget()
                    Image(systemName: "arrow.down")
                    Text("To Hex").textStyleWidget()
                case .dec2ASCII:
                    Text("From Decimal").textStyleWidget()
                    Image(systemName: "arrow.down")
                    Text("To ASCII").textStyleWidget()
                case .none:
                    Text("")
                }
            }
        }
    }
}

struct Bin2DecWidgetExtension: Widget {
    let kind: String = "Bin2DecWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                Bin2DecWidgetExtensionEntryView(entry: entry)
                    .containerBackground(.fill.secondary, for: .widget)
            } else {
                Bin2DecWidgetExtensionEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    Bin2DecWidgetExtension()
} timeline: {
    SimpleEntry(date: .now, conversiontype: .dec2Bit)
}

extension View {
    func textStyleWidget() -> some View {
        self.padding(8).font(.system(size: 14)).frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 8.0).fill(Color.clear)
                    .stroke(.primary, lineWidth: 1)
                
            }
    }
}
