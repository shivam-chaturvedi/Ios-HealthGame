import SwiftUI
import Combine
import Charts

struct MainAppView: View {
    @EnvironmentObject var vm: AnxietyCalculatorViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeDashboardView(
                    onNeedHelp: { selectedTab = 4 },
                    onCheckIn: { selectedTab = 3 }
                )
            }
            .tabItem { Label("Home", systemImage: "house") }
            .tag(0)

            NavigationStack {
                PhysiologyScreen()
            }
            .tabItem { Label("Physio", systemImage: "waveform.path.ecg") }
            .tag(1)

            NavigationStack {
                LifestyleScreen()
            }
            .tabItem { Label("Lifestyle", systemImage: "heart.text.square") }
            .tag(2)

            NavigationStack {
                CheckInScreen()
            }
            .tabItem { Label("Check-in", systemImage: "square.and.pencil") }
            .tag(3)

            NavigationStack {
                InterventionsScreen()
            }
            .tabItem { Label("Help", systemImage: "sparkles") }
            .tag(4)
        }
        .tint(.blue)
    }
}

// MARK: - Home
struct HomeDashboardView: View {
    @EnvironmentObject var vm: AnxietyCalculatorViewModel
    var onNeedHelp: () -> Void
    var onCheckIn: () -> Void
    @State private var showInsights = false
    @State private var showSettings = false

    private var descriptor: String {
        switch vm.score.finalScore {
        case 0..<34: return "Calm"
        case 34..<67: return "Moderate"
        default: return "High"
        }
    }

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 18) {
                    NavigationLink("", destination: WeeklyInsightsView(), isActive: $showInsights)
                        .hidden()
                    NavigationLink("", destination: SettingsView(), isActive: $showSettings)
                        .hidden()
                    header
                    scoreCard
                    Button {
                        onNeedHelp()
                    } label: {
                        Label("Need Help Now?", systemImage: "sparkles")
                    }
                    .buttonStyle(GradientButtonStyle())

                    contributorsCard
                    quickActions
                    breakdown
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Anxiety Calculator – V1")
                    .font(.title2).bold()
                Text("Your real-time wellness score")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            Spacer()
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .padding(10)
                    .background(Color.white.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private var scoreCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    ConfidenceBadgeView(confidence: vm.score.confidence)
                    Spacer()
                    Text("Updated just now")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                AnxietyRing(score: vm.score.finalScore)
                Text(descriptor)
                    .font(.headline)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Last 12 hours")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Chart(vm.trend) { point in
                        LineMark(
                            x: .value("Time", point.label),
                            y: .value("Score", point.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(AppTheme.primaryGradient)
                    }
                    .frame(height: 90)
                }
            }
        }
    }

    private var contributorsCard: some View {
        GlassCard {
            SectionHeader(title: "Top Contributors Today", subtitle: "What moved your score", icon: "chart.bar.fill")
            VStack(spacing: 10) {
                ForEach(vm.contributors.prefix(4)) { contributor in
                    ContributorRow(contributor: contributor)
                }
            }
        }
    }

    private var quickActions: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                GlassCard {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Insights").font(.headline)
                            Text("Weekly report").font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .onTapGesture { showInsights = true }

                GlassCard {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Check-in").font(.headline)
                            Text("Quick update").font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .onTapGesture { onCheckIn() }
            }
        }
    }

    private var breakdown: some View {
        GlassCard {
            SectionHeader(title: "Score Breakdown", subtitle: "APS, LRS, Check-in", icon: "speedometer")
            HStack(spacing: 12) {
                BreakdownItem(title: "Physiology", value: vm.score.aps, color: .blue)
                BreakdownItem(title: "Lifestyle", value: vm.score.lrs, color: .green)
                BreakdownItem(title: "Check-in", value: vm.score.cs, color: .orange)
            }
            Divider().padding(.vertical, 6)
            HStack {
                Text("α (physiology weight)")
                Spacer()
                Text(String(format: "%.2f", vm.score.alpha))
                    .fontWeight(.semibold)
            }
            HStack {
                Text("Check-in weight (decay 8h)")
                Spacer()
                Text(String(format: "%.2f", vm.score.checkinWeight))
                    .fontWeight(.semibold)
            }
        }
    }
}

private struct ContributorRow: View {
    var contributor: Contributor

    var icon: String {
        switch contributor.name.lowercased() {
        case "sleep": return "moon.zzz.fill"
        case "stimulants": return "cup.and.saucer.fill"
        case "activity": return "figure.walk"
        case "context": return "calendar"
        case "self-care": return "hands.sparkles.fill"
        case "cycle": return "drop.fill"
        case "screen": return "desktopcomputer"
        case "diet": return "fork.knife"
        case "hr": return "heart.fill"
        case "hrv": return "waveform.path.ecg"
        case "rr": return "lungs.fill"
        case "eda": return "bolt.fill"
        case "temp": return "thermometer"
        case "motion": return "move.3d"
        default: return "chart.line.uptrend.xyaxis"
        }
    }

    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(contributor.category == .physiology ? .blue : .green)
                    .padding(10)
                    .background(Color.white.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(contributor.name.capitalized)
                        .font(.headline)
                    Text(contributor.category.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("+\(Int(contributor.impact.rounded()))%")
                    .fontWeight(.semibold)
                    .foregroundColor(contributor.trend == .down ? .green : .red)
                Text(contributor.trend.rawValue.capitalized)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

private struct BreakdownItem: View {
    var title: String
    var value: Double
    var color: Color

    var body: some View {
        VStack {
            Text(String(format: "%.0f", value))
                .font(.title2).bold()
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct AnxietyRing: View {
    var score: Double
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 14)
                .frame(width: 160, height: 160)
            Circle()
                .trim(from: 0, to: min(1, score / 100))
                .stroke(AppTheme.primaryGradient, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 160, height: 160)
                .shadow(color: Color.blue.opacity(0.2), radius: 8, x: 0, y: 6)
            VStack(spacing: 6) {
                Text(String(format: "%.0f", score))
                    .font(.system(size: 44, weight: .bold))
                Text("Current score")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Physiology
struct PhysiologyScreen: View {
    @EnvironmentObject var vm: AnxietyCalculatorViewModel
    @StateObject private var liveVM = PhysioLiveViewModel()
    private let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    @State private var showSettings = false

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 16) {
                    header
                    stateCard
                    liveSignalCard
                    metricsGrid
                    calibrationCard
                }
                .padding()
            }
        }
        .navigationTitle("Physiology")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
        .onReceive(timer) { _ in
            liveVM.refreshAll()
            vm.simulateLiveTick() // keep anxiety score running
        }
    }

    private var header: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 6) {
                Text("Physiology").font(.title2).bold()
                Text("Real-time biometrics").foregroundColor(.secondary)
            }
        }
    }

    private var stateCard: some View {
        GlassCard {
            HStack {
                Image(systemName: liveVM.stateTitle == "Active" ? "figure.run" : "bed.double.fill")
                    .foregroundColor(.green)
                VStack(alignment: .leading, spacing: 4) {
                    Text(liveVM.stateTitle).font(.headline)
                    Text(liveVM.stateDetail).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                ConfidenceBadgeView(confidence: vm.score.confidence)
            }
        }
    }

    private var liveSignalCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Live Signal").font(.headline)
                        Text("Last \(Int(liveVM.minutesWindow)) minutes")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    Picker("", selection: $liveVM.selectedSignal) {
                        ForEach(PhysioLiveViewModel.Signal.allCases, id: \.self) { sig in
                            Text(sig.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                Chart(liveVM.series[liveVM.selectedSignal] ?? []) { point in
                    LineMark(
                        x: .value("Time", point.date),
                        y: .value("Value", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(AppTheme.primaryGradient)
                    AreaMark(
                        x: .value("Time", point.date),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(AppTheme.primaryGradient.opacity(0.25))
                }
                .chartXAxis(.hidden)
                .frame(height: 180)
            }
        }
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(liveVM.cards) { card in
                GlassCard {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: card.icon)
                                .foregroundColor(card.color)
                                .padding(8)
                                .background(card.color.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            Spacer()
                            statusChip(card.status)
                        }
                        Text(card.valueText)
                            .font(.title2).bold()
                        Text(card.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Text("Baseline: \(card.baselineMean) ± \(card.baselineSD)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                            trendIcon(card.trend)
                        }
                    }
                }
            }
        }
    }

    private func statusChip(_ status: PhysioLiveViewModel.MetricCard.Status) -> some View {
        let text: String
        let color: Color
        switch status {
        case .normal: text = "Normal"; color = .green
        case .elevated: text = "Elevated"; color = .orange
        case .low: text = "Low"; color = .blue
        }
        return Text(text)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }

    private func trendIcon(_ trend: PhysioLiveViewModel.MetricCard.Trend) -> some View {
        switch trend {
        case .up: return Image(systemName: "arrow.up.right").foregroundColor(.orange)
        case .down: return Image(systemName: "arrow.down.right").foregroundColor(.green)
        case .stable: return Image(systemName: "minus").foregroundColor(.secondary)
        }
    }

    private var calibrationCard: some View {
        GlassCard {
            SectionHeader(title: "Calibration Status", subtitle: liveVM.calibrationText, icon: "checkmark.seal.fill")
            ProgressView(value: liveVM.calibrationProgress)
                .tint(.blue)
            Text("Your personalized baselines update automatically.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Lifestyle (cards + detail)
struct LifestyleScreen: View {
    @EnvironmentObject var vm: AnxietyCalculatorViewModel
    @State private var selected: LifestyleCategory = .sleep
    @State private var showSettings = false

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 16) {
                    header
                    ForEach(LifestyleCategory.allCases, id: \.self) { category in
                        lifestyleCard(category)
                    }
                    detailCard(for: selected)
                }
                .padding()
            }
        }
        .navigationTitle("Lifestyle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private var header: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 4) {
                Text("Lifestyle").font(.title2).bold()
                Text("Track daily habits").foregroundColor(.secondary)
            }
        }
    }

    private func lifestyleCard(_ category: LifestyleCategory) -> some View {
        let isSelected = category == selected
        return GlassCard {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .foregroundColor(category.color)
                    .padding(12)
                    .background(category.color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.title).font(.headline)
                    Text(summary(for: category))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(category.weight * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isSelected ? Color.blue.opacity(0.55) : Color.clear, lineWidth: 2)
        )
        .onTapGesture { selected = category }
    }

    @ViewBuilder
    private func detailCard(for category: LifestyleCategory) -> some View {
        switch category {
        case .sleep:
            GlassCard {
                SectionHeader(title: "Sleep Tracking", subtitle: "Schedule & debt", icon: "moon.zzz.fill")
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sleep Time").font(.caption).foregroundColor(.secondary)
                        DatePicker("", selection: Binding(
                            get: { vm.lifestyle.sleepStart },
                            set: { newValue in vm.updateLifestyle { data in data.sleepStart = newValue } }
                        ), displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Wake Time").font(.caption).foregroundColor(.secondary)
                        DatePicker("", selection: Binding(
                            get: { vm.lifestyle.wakeTime },
                            set: { newValue in vm.updateLifestyle { data in data.wakeTime = newValue } }
                        ), displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Sleep Efficiency")
                        Spacer()
                        Text("\(Int(vm.lifestyle.sleepEfficiency))%").fontWeight(.semibold)
                    }
                    ProgressView(value: vm.lifestyle.sleepEfficiency / 100).tint(.blue)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Sleep Debt").font(.subheadline).fontWeight(.semibold).foregroundColor(.red)
                    Text("Accumulative deficit").font(.caption).foregroundColor(.secondary)
                    Text("\(vm.lifestyle.sleepDebtHours, specifier: "%.1f") h")
                        .font(.title3).bold().foregroundColor(.red)
                }
            }
        case .stimulants:
            GlassCard {
                SectionHeader(title: "Stimulants", subtitle: "Caffeine, nicotine, alcohol", icon: "cup.and.saucer.fill")
                StepperRow(title: "Caffeine after 2PM", value: binding(\.caffeineMgAfter2pm), step: 20, format: "%.0f mg")
                ToggleRow(title: "Nicotine today", isOn: binding(\.nicotine))
                StepperRow(title: "Alcohol after 8PM", value: Binding(get: { Double(vm.lifestyle.alcoholUnitsAfter8pm) }, set: { newValue in vm.updateLifestyle { data in data.alcoholUnitsAfter8pm = Int(newValue) } }), step: 1, format: "%.0f unit")
            }
        case .activity:
            GlassCard {
                SectionHeader(title: "Activity", subtitle: "Protective movement", icon: "figure.walk")
                StepperRow(title: "Activity minutes", value: binding(\.activityMinutes), step: 5, format: "%.0f min")
                StepperRow(title: "Vigorous minutes", value: binding(\.vigorousMinutes), step: 5, format: "%.0f min")
            }
        case .context:
            GlassCard {
                SectionHeader(title: "Context", subtitle: "Calendar load", icon: "calendar.badge.clock")
                ToggleRow(title: "Exam / deadline today", isOn: binding(\.isExamDay))
                StepperRow(title: "High workload hours", value: binding(\.workloadHours), step: 1, format: "%.0f h")
            }
        case .selfCare:
            GlassCard {
                SectionHeader(title: "Self-Care", subtitle: "Meditation, journaling, breath", icon: "hands.sparkles.fill")
                StepperRow(title: "Minutes today", value: binding(\.selfCareMinutes), step: 5, format: "%.0f min")
            }
        case .cycle:
            GlassCard {
                SectionHeader(title: "Cycle Tracking", subtitle: "Phase selector", icon: "heart.fill")
                ToggleRow(title: "Cycle data available", isOn: binding(\.hasCycleData))
                Picker("Phase", selection: binding(\.cyclePhase)) {
                    ForEach(CyclePhase.allCases, id: \.self) { phase in
                        Text(phase.rawValue).tag(phase)
                    }
                }
                .pickerStyle(.segmented)
            }
        case .screen:
            GlassCard {
                SectionHeader(title: "Screen Time", subtitle: "Late night + daytime", icon: "desktopcomputer")
                StepperRow(title: "After 11PM", value: binding(\.post11pmScreenMinutes), step: 10, format: "%.0f min")
                StepperRow(title: "Daytime", value: binding(\.daytimeScreenHours), step: 0.5, format: "%.1f h")
            }
        case .diet:
            GlassCard {
                SectionHeader(title: "Diet & Hydration", subtitle: "Meals, sugar, water", icon: "fork.knife")
                StepperRow(title: "Skipped meals", value: Binding(get: { Double(vm.lifestyle.skippedMeals) }, set: { newValue in vm.updateLifestyle { data in data.skippedMeals = Int(newValue) } }), step: 1, format: "%.0f")
                StepperRow(title: "Sugary items", value: Binding(get: { Double(vm.lifestyle.sugaryItems) }, set: { newValue in vm.updateLifestyle { data in data.sugaryItems = Int(newValue) } }), step: 1, format: "%.0f")
                StepperRow(title: "Water glasses", value: Binding(get: { Double(vm.lifestyle.waterGlasses) }, set: { newValue in vm.updateLifestyle { data in data.waterGlasses = Int(newValue) } }), step: 1, format: "%.0f")
            }
        }
    }

    private func summary(for category: LifestyleCategory) -> String {
        let l = vm.lifestyle
        switch category {
        case .sleep:
            return "\(timeString(l.sleepStart)) • \(String(format: "%.1f", l.sleepDebtHours))h debt"
        case .stimulants:
            return "\(Int(l.caffeineMgAfter2pm))mg caffeine"
        case .activity:
            return "\(Int(l.activityMinutes * 60)) steps • \(Int(l.activityMinutes))min"
        case .context:
            return l.isExamDay ? "Deadline today" : "Workload \(Int(l.workloadHours))h"
        case .selfCare:
            return "\(Int(l.selfCareMinutes))min today"
        case .cycle:
            return l.hasCycleData ? l.cyclePhase.rawValue : "Not tracking"
        case .screen:
            return "\(String(format: "%.1f", l.daytimeScreenHours))h today"
        case .diet:
            return "\(l.waterGlasses) glasses water"
        }
    }

    private func timeString(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: date)
    }

    private func binding<Value>(_ keyPath: WritableKeyPath<LifestyleData, Value>) -> Binding<Value> {
        Binding(
            get: { vm.lifestyle[keyPath: keyPath] },
            set: { newValue in vm.updateLifestyle { $0[keyPath: keyPath] = newValue } }
        )
    }
}

private enum LifestyleCategory: CaseIterable {
    case sleep, stimulants, activity, context, selfCare, cycle, screen, diet

    var title: String {
        switch self {
        case .sleep: return "Sleep"
        case .stimulants: return "Stimulants"
        case .activity: return "Activity"
        case .context: return "Context"
        case .selfCare: return "Self-Care"
        case .cycle: return "Cycle"
        case .screen: return "Screen Time"
        case .diet: return "Diet & Hydration"
        }
    }

    var icon: String {
        switch self {
        case .sleep: return "moon.zzz.fill"
        case .stimulants: return "cup.and.saucer.fill"
        case .activity: return "figure.walk"
        case .context: return "calendar"
        case .selfCare: return "hands.sparkles.fill"
        case .cycle: return "heart.fill"
        case .screen: return "desktopcomputer"
        case .diet: return "fork.knife"
        }
    }

    var color: Color {
        switch self {
        case .sleep: return .purple
        case .stimulants: return .orange
        case .activity: return .green
        case .context: return .red
        case .selfCare: return .pink
        case .cycle: return .mint
        case .screen: return .blue
        case .diet: return .teal
        }
    }

    var weight: Double {
        switch self {
        case .sleep: return 0.30
        case .stimulants: return 0.20
        case .activity: return 0.10
        case .context: return 0.15
        case .selfCare: return 0.05
        case .cycle: return 0.05
        case .screen: return 0.10
        case .diet: return 0.05
        }
    }
}

private struct StepperRow: View {
    var title: String
    @Binding var value: Double
    var step: Double
    var format: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline)
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            HStack(spacing: 12) {
                Button {
                    value = max(0, value - step)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
                Text(String(format: format, value))
                    .font(.headline)
                Button {
                    value += step
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
        }
    }

    private var subtitle: String {
        switch title {
        case "Caffeine after 2PM":
            return "-1 cup coffee ≈ 100mg"
        case "After 11PM":
            return "Min of late night use"
        default:
            return ""
        }
    }
}

private struct ToggleRow: View {
    var title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(title).font(.subheadline)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

// MARK: - Check-in
struct CheckInScreen: View {
    @EnvironmentObject var vm: AnxietyCalculatorViewModel
    @State private var gad1: Int = 0
    @State private var gad2: Int = 0
    @State private var mood: Int = 2
    @State private var momentNote: String = ""
    @State private var momentIntensity: Double = 0.5
    @State private var showMomentSheet = false
    @State private var showSettings = false

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 16) {
                    SectionHeader(title: "Check-in", subtitle: "Anchor your score", icon: "square.and.pencil")
                    lastCheckinCard
                    gadQuestions
                    submitButton
                    moodSlider
                    momentsList
                    currentScores
                }
                .padding()
            }
        }
        .navigationTitle("Check-in")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            gad1 = vm.checkin.gad2Score / 2
            gad2 = vm.checkin.gad2Score - gad1
            mood = vm.checkin.mood
        }
        .sheet(isPresented: $showMomentSheet) {
            AddMomentSheet(note: $momentNote, intensity: $momentIntensity) {
                vm.addAnxietyMoment(note: momentNote.isEmpty ? "Tagged moment" : momentNote, intensity: momentIntensity)
                momentNote = ""
            }
        }
    }

    private var lastCheckinCard: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last check-in").font(.headline)
                    if let latest = max(vm.checkin.gadUpdated, vm.checkin.moodUpdated) as Date? {
                        Text(latest, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                ConfidenceBadgeView(confidence: vm.score.confidence)
            }
        }
    }

    private var gadQuestions: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("GAD-2 Quick Check").font(.headline)
                        Text("2 questions • takes 30 seconds")
                            .font(.caption).foregroundColor(.secondary)
                    }
                }
                gadOptions(title: "Over the last 2 weeks, how often have you been feeling nervous, anxious, or on edge?", selection: $gad1)
                gadOptions(title: "Over the last 2 weeks, how often have you been unable to stop or control worrying?", selection: $gad2)
            }
        }
    }

    private func gadOptions(title: String, selection: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.subheadline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                optionButton("Not at all", value: 0, selection: selection)
                optionButton("Several days", value: 1, selection: selection)
                optionButton("More than half the days", value: 2, selection: selection)
                optionButton("Nearly every day", value: 3, selection: selection)
            }
        }
    }

    private func optionButton(_ title: String, value: Int, selection: Binding<Int>) -> some View {
        Button {
            selection.wrappedValue = value
        } label: {
            Text(title)
                .font(.caption)
                .foregroundColor(selection.wrappedValue == value ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background {
                    if selection.wrappedValue == value {
                        AppTheme.primaryGradient
                    } else {
                        Color.white.opacity(0.7)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: AppTheme.shadow, radius: 4, x: 0, y: 4)
        }
    }

    private var moodSlider: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Mood Check").font(.headline)
                Text("How are you feeling right now?")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 12) {
                    moodChip(label: "Calm", value: 0, icon: "face.smiling")
                    moodChip(label: "Mild", value: 1, icon: "face.neutral")
                    moodChip(label: "Moderate", value: 2, icon: "face.smiling.inverse")
                    moodChip(label: "Anxious", value: 3, icon: "exclamationmark.triangle.fill")
                    moodChip(label: "Very Anxious", value: 4, icon: "flame.fill")
                }
            }
        }
    }

    private var submitButton: some View {
        Button {
            vm.updateCheckin(gad2: gad1 + gad2, mood: mood)
        } label: {
            Label("Submit Check-in", systemImage: "paperplane.fill")
        }
        .buttonStyle(GradientButtonStyle())
    }

    private var momentsList: some View {
        GlassCard {
            HStack {
                SectionHeader(title: "Anxiety Moments", subtitle: "Mark when you feel anxious", icon: "clock")
                Spacer()
                Button {
                    showMomentSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            if vm.checkin.anxietyMoments.isEmpty {
                Text("No moments tagged yet").foregroundColor(.secondary)
            } else {
                ForEach(vm.checkin.anxietyMoments.prefix(4)) { moment in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(moment.note).font(.headline)
                            Text(moment.timestamp, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(String(format: "%.0f%%", moment.intensity * 100))
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }

    private var currentScores: some View {
        GlassCard {
            SectionHeader(title: "Current Check-in Scores", subtitle: "Latest responses", icon: "chart.bar.fill")
            HStack {
                VStack {
                    Text("\(vm.checkin.gad2Score)/6")
                        .font(.title2).bold().foregroundColor(.blue)
                    Text("GAD-2 Score").font(.caption).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                VStack {
                    Text("\(vm.checkin.mood)/4")
                        .font(.title2).bold().foregroundColor(.green)
                    Text("Mood Level").font(.caption).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func moodChip(label: String, value: Int, icon: String) -> some View {
        Button {
            mood = value
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                Text(label).font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(value == mood ? Color.orange.opacity(0.15) : Color.white.opacity(0.7))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(value == mood ? Color.orange : Color.clear, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

// MARK: - Interventions
struct InterventionsScreen: View {
    @EnvironmentObject var vm: AnxietyCalculatorViewModel
    @State private var feedbackPrompt = false
    @State private var wasAccurate = true
    @State private var selected: Intervention?
    @State private var showSettings = false

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 16) {
                    SectionHeader(title: "Interventions", subtitle: "Calm your nervous system", icon: "sparkles")
                    scoreCard
                    quickRelief
                    allExercises
                }
                .padding()
            }
        }
        .navigationTitle("Help Now")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(item: $selected) { item in
            InterventionDetailSheet(item: item)
        }
        .alert("Thanks for your feedback", isPresented: $feedbackPrompt) {
            Button("Seems right") {
                wasAccurate = true
            }
            Button("Off target") {
                wasAccurate = false
            }
        } message: {
            Text("We'll adjust personalized weights\(wasAccurate ? " positively" : "") in AI Adaptive Mode.")
        }
    }

    private var scoreCard: some View {
        GlassCard {
            HStack(spacing: 14) {
                AnxietyRing(score: vm.score.finalScore)
                    .frame(width: 110, height: 110)
                VStack(alignment: .leading, spacing: 6) {
                    Text("You're doing well! These exercises help maintain calm.")
                        .font(.subheadline)
                    Text("Main factor: \(vm.contributors.first?.name.capitalized ?? "Sleep")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("Was this accurate?") {
                        feedbackPrompt = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                Spacer()
            }
        }
    }

    private var quickRelief: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Relief")
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 12) {
                ForEach(vm.interventions.filter { $0.quickRelief }.prefix(2)) { item in
                    GlassCard {
                        VStack(spacing: 8) {
                            Image(systemName: item.icon)
                                .font(.title3)
                                .foregroundColor(.blue)
                                .padding(12)
                                .background(Color.blue.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            Text(item.title)
                                .font(.headline)
                            Text(item.duration)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .onTapGesture { selected = item }
                }
            }
        }
    }

    private var allExercises: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("All Exercises")
                .font(.caption)
                .foregroundColor(.secondary)
            ForEach(vm.interventions) { item in
                GlassCard {
                    HStack(spacing: 12) {
                        Image(systemName: item.icon)
                            .foregroundColor(color(for: item))
                            .padding(12)
                            .background(color(for: item).opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title).font(.headline)
                            Text(item.subtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock")
                                    .foregroundColor(.secondary)
                                Text("\(item.minutes)m")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill").foregroundColor(.orange).font(.caption)
                                Text(String(format: "%.1f", item.rating))
                                    .font(.caption)
                            }
                        }
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .onTapGesture { selected = item }
            }
        }
    }

    private func color(for item: Intervention) -> Color {
        switch item.category.lowercased() {
        case "breathwork": return .blue
        case "grounding": return .green
        case "movement": return .orange
        case "audio": return .pink
        case "reflection": return .purple
        case "tip": return .yellow
        default: return .blue
        }
    }
}

private struct InterventionDetailSheet: View {
    var item: Intervention
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .padding(10)
                        .background(Color.black.opacity(0.05))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)

            VStack(spacing: 10) {
                Text(item.title)
                    .font(.title3).bold()
                Text(item.effect)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }

            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 140, height: 140)
                .overlay(
                    Circle()
                        .fill(Color.blue.opacity(0.4))
                        .frame(width: 110, height: 110)
                        .overlay(
                            Text("Start")
                                .font(.headline)
                                .foregroundColor(.white)
                        )
                )
            Text("\(item.minutes):00 remaining")
                .foregroundColor(.secondary)
                .font(.caption)

            Spacer()
        }
        .padding(.vertical, 24)
        .background(AppTheme.background)
    }
}

// MARK: - Insights
struct WeeklyInsightsView: View {
    @EnvironmentObject var vm: AnxietyCalculatorViewModel
    @State private var showSettings = false

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 16) {
                    SectionHeader(title: "Weekly Insights", subtitle: "Trends and top contributors", icon: "chart.bar.doc.horizontal")
                    GlassCard {
                        Chart(vm.weekly) { day in
                            BarMark(
                                x: .value("Day", day.date, unit: .day),
                                y: .value("Score", day.score)
                            )
                            .foregroundStyle(AppTheme.primaryGradient)
                        }
                        .frame(height: 220)
                        if let top = vm.contributors.max(by: { $0.impact < $1.impact }) {
                            Text("\(top.name.capitalized) raised anxiety by \(Int(top.impact.rounded()))% this week.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    GlassCard {
                        SectionHeader(title: "Top lifestyle contributors", subtitle: "Risk impact", icon: "list.bullet")
                        ForEach(vm.contributors.filter { $0.category == .lifestyle }.prefix(3)) { item in
                            ContributorRow(contributor: item)
                        }
                    }
                    GlassCard {
                        SectionHeader(title: "Top physiology contributors", subtitle: "Risk impact", icon: "waveform.path.ecg")
                        ForEach(vm.contributors.filter { $0.category == .physiology }.prefix(3)) { item in
                            ContributorRow(contributor: item)
                        }
                    }
                    GlassCard {
                        SectionHeader(title: "Best interventions", subtitle: "Based on feedback", icon: "rosette")
                        ForEach(vm.interventions.prefix(3)) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.title).font(.headline)
                                    Text(item.effect).font(.caption).foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(item.duration).font(.caption)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    GlassCard {
                        SectionHeader(title: "Progress tracker", subtitle: "Streaks and badges", icon: "flame.fill")
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Streak").font(.headline)
                                Text("5 days of consistent check-ins").font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("x5").font(.title2).bold().foregroundColor(.orange)
                        }
                        Divider()
                        HStack {
                            BadgeView(title: "Calm days", value: "3")
                            BadgeView(title: "Breathwork", value: "7")
                            BadgeView(title: "Hydration", value: "8")
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

private struct BadgeView: View {
    var title: String
    var value: String

    var body: some View {
        VStack {
            Text(value)
                .font(.headline)
                .foregroundColor(.blue)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Settings
struct SettingsView: View {
    @EnvironmentObject var vm: AnxietyCalculatorViewModel
    @State private var notificationsOn = true
    @State private var exportRequested = false
    @State private var demoMode = true
    @State private var primaryConcern: String = "panic"
    @State private var alertFrequency: String = "low"

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 16) {
                    GlassCard {
                        SectionHeader(title: "Settings", subtitle: "Customize your experience", icon: "gearshape.fill")
                        GlassCard {
                            HStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppTheme.primaryGradient)
                                    .frame(width: 60, height: 60)
                                    .overlay(Text("AC").foregroundColor(.white).bold())
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Anxiety Calculator").font(.headline)
                                    Text("V1 Demo Mode").font(.caption).foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Text("Primary Concern")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    GlassCard {
                        segmented(["stress", "anxiety", "panic"], selection: $primaryConcern)
                    }

                    Text("Notifications")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    GlassCard {
                        SectionHeader(title: "Alert Frequency", subtitle: "Only urgent alerts when anxiety is very high", icon: "bell.badge.fill")
                        segmented(["low", "medium", "high"], selection: $alertFrequency)
                    }

                    Text("AI Features")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    GlassCard {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.green)
                                .padding(10)
                                .background(Color.green.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Personalized Weights").font(.headline)
                                Text("AI adapts to your patterns").font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $vm.aiAdaptiveMode).labelsHidden()
                        }
                        Text("The app learns which factors affect you most and adjusts weight accordingly. Based on feedback, sleep currently has 35% weight (vs default 30%).")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.top, 6)
                    }

                    GlassCard {
                        settingsRow(icon: "applewatch", title: "Connected Devices", subtitle: "Apple Watch connected")
                        Divider()
                        settingsRow(icon: "arrow.down.doc", title: "Export Data", subtitle: "Download your history") {
                            exportRequested = true
                        }
                        Divider()
                        settingsRow(icon: "lock.shield", title: "Privacy & Security", subtitle: "Manage your data")
                        Divider()
                        settingsRow(icon: "questionmark.circle", title: "Help & Support", subtitle: "FAQs and contact")
                    }

                    GlassCard {
                        VStack(spacing: 4) {
                            Text("Anxiety Calculator").font(.subheadline).bold()
                            Text("Version 1.0.0 (Demo)").font(.caption).foregroundColor(.secondary)
                            Text("© 2024 Wellness Labs").font(.caption2).foregroundColor(.secondary)
                        }
                        Toggle("Demo mode (mock data)", isOn: $demoMode)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Settings")
        .alert("Data export", isPresented: $exportRequested) {
            Button("OK") {}
        } message: {
            Text("Exports would be prepared here. (UI placeholder)")
        }
    }

    private func segmented(_ options: [String], selection: Binding<String>) -> some View {
        HStack(spacing: 10) {
            ForEach(options, id: \.self) { option in
                Button {
                    selection.wrappedValue = option
                } label: {
                    Text(option.capitalized)
                        .font(.subheadline)
                        .foregroundColor(selection.wrappedValue == option ? .white : .primary)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background {
                            if selection.wrappedValue == option {
                                AppTheme.primaryGradient
                            } else {
                                Color.white.opacity(0.7)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    private func settingsRow(icon: String, title: String, subtitle: String, action: (() -> Void)? = nil) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .padding(10)
                .background(Color.blue.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action?()
        }
    }
}
