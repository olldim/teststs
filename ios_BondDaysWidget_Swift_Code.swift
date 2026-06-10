import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct BondDaysEntry: TimelineEntry {
    let date: Date
    let trackerData: TrackerWidgetData?
    let errorMessage: String?
}

// MARK: - Tracker Data Model
struct TrackerWidgetData: Codable {
    let type: String
    let trackerId: String
    let title: String
    let daysTogether: String?
    let daysPassed: String?
    let formattedTime: String
    let color: String
    let person1Name: String?
    let person2Name: String?
    let person1ImagePath: String?
    let person2ImagePath: String?
    let iconPath: String?
    let startDate: String
}

// MARK: - Timeline Provider
struct BondDaysProvider: TimelineProvider {
    func placeholder(in context: Context) -> BondDaysEntry {
        return BondDaysEntry(
            date: Date(),
            trackerData: nil,
            errorMessage: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (BondDaysEntry) -> Void) {
        let entry = BondDaysEntry(
            date: Date(),
            trackerData: loadTrackerData(),
            errorMessage: nil
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BondDaysEntry>) -> Void) {
        var entries: [BondDaysEntry] = []
        
        let trackerData = loadTrackerData()
        
        let currentEntry = BondDaysEntry(
            date: Date(),
            trackerData: trackerData,
            errorMessage: trackerData == nil ? "Виберіть трекер" : nil
        )
        entries.append(currentEntry)
        
        let updateDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        
        let timeline = Timeline(entries: entries, policy: .after(updateDate))
        completion(timeline)
    }
    
    private func loadTrackerData() -> TrackerWidgetData? {
        guard let userDefaults = UserDefaults(suiteName: "group.com.bondtracker.app") else {
            print("❌ Error: Cannot access App Group UserDefaults")
            return nil
        }
        
        if let data = userDefaults.data(forKey: "active_widget_tracker") {
            let decoder = JSONDecoder()
            if let trackerData = try? decoder.decode(TrackerWidgetData.self, from: data) {
                return trackerData
            }
        }
        
        return nil
    }
}

// MARK: - Widget View
struct BondDaysWidgetEntryView: View {
    var entry: BondDaysProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        ZStack {
            Color(red: 0.043, green: 0.047, blue: 0.063)
                .ignoresSafeArea()
            
            if let trackerData = entry.trackerData {
                if trackerData.type == "pair" {
                    PairTrackerWidgetView(tracker: trackerData)
                } else if trackerData.type == "single" {
                    SingleTrackerWidgetView(tracker: trackerData)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    Text("Виберіть трекер")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("в додатку BondDays")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - Pair Tracker Widget View
struct PairTrackerWidgetView: View {
    let tracker: TrackerWidgetData
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(tracker.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: tracker.color))
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            HStack(spacing: 8) {
                VStack(spacing: 6) {
                    PersonAvatarView(imagePath: tracker.person1ImagePath)
                    
                    Text(tracker.person1Name ?? "Людина 1")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                VStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: "#8B0000"))
                    
                    VStack(spacing: 2) {
                        Text(tracker.daysTogether ?? "0")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "#00D4FF"))
                        
                        Text("днів")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                VStack(spacing: 6) {
                    PersonAvatarView(imagePath: tracker.person2ImagePath)
                    
                    Text(tracker.person2Name ?? "Людина 2")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 12)
            
            Text(tracker.formattedTime)
                .font(.system(size: 9))
                .foregroundColor(.gray)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.125, green: 0.17, blue: 0.2).opacity(0.6),
                    Color(red: 0.1, green: 0.13, blue: 0.15).opacity(0.6),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.05),
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .cornerRadius(12)
        .padding(8)
    }
}

// MARK: - Single Tracker Widget View
struct SingleTrackerWidgetView: View {
    let tracker: TrackerWidgetData
    
    var body: some View {
        VStack(spacing: 12) {
            Text(tracker.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: tracker.color))
                .lineLimit(2)
            
            Spacer()
            
            if let iconPath = tracker.iconPath {
                if let uiImage = UIImage(contentsOfFile: iconPath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .cornerRadius(8)
                } else {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
            } else {
                Image(systemName: "heart.slash")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(tracker.daysPassed ?? "0")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color(hex: tracker.color))
                
                Text("днів")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(tracker.formattedTime)
                .font(.system(size: 9))
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.125, green: 0.17, blue: 0.2).opacity(0.6),
                    Color(red: 0.1, green: 0.13, blue: 0.15).opacity(0.6),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.05),
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .cornerRadius(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Person Avatar View
struct PersonAvatarView: View {
    let imagePath: String?
    
    var body: some View {
        if let imagePath = imagePath,
           let uiImage = UIImage(contentsOfFile: imagePath) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(hex: "#00D4FF"), lineWidth: 1.5))
        } else {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                )
        }
    }
}

// MARK: - Color Extension (HEX)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Widget Bundle
@main
struct BondDaysWidgetBundle: WidgetBundle {
    var body: some Widget {
        BondDaysWidget()
    }
}

// MARK: - Main Widget
struct BondDaysWidget: Widget {
    let kind: String = "BondDaysWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: BondDaysProvider()
        ) { entry in
            BondDaysWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("BondDays Трекер")
        .description("Відслідкуйте важливі моменти вашого життя")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    BondDaysWidget()
} timeline: {
    BondDaysEntry(
        date: Date(),
        trackerData: TrackerWidgetData(
            type: "pair",
            trackerId: "test123",
            title: "Ми разом",
            daysTogether: "365",
            daysPassed: nil,
            formattedTime: "1 років, 0 місяців, 0 днів",
            color: "#FF006E",
            person1Name: "Максим",
            person2Name: "Софія",
            person1ImagePath: nil,
            person2ImagePath: nil,
            iconPath: nil,
            startDate: Date().description
        ),
        errorMessage: nil
    )
}
