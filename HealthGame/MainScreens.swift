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

            NavigationStack {
                AccountView()
            }
            .tabItem { Label("Account", systemImage: "person.crop.circle") }
            .tag(5)
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
        guard vm.hasHealthData else { return "No data" }
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
                    refreshRow
                    cloudSyncRow
                    if vm.hasHealthData {
                        scoreCard
                    } else {
                        GlassCard {
                            Text("No data from HealthKit yet.")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Button {
                        onNeedHelp()
                    } label: {
                        Label("Need Help Now?", systemImage: "sparkles")
                    }
                    .buttonStyle(GradientButtonStyle())

                    quickActions
                    breakdown
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image("HomeLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 88, height: 88)
                .shadow(color: AppTheme.shadow, radius: 8, x: 0, y: 6)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Anxiety Calculator")
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
    }

    private var refreshRow: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Live data")
                        .font(.headline)
                    Text("Pull latest from watch & HealthKit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    vm.simulateLiveTick()
                } label: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .padding(10)
                        .background(Color.blue.opacity(0.12))
                        .clipShape(Circle())
                }
            }
        }
    }

    private var cloudSyncRow: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cloud sync")
                        .font(.headline)
                    if let last = vm.lastCloudSync {
                        Text("Last synced \(last, style: .time)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Not synced yet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Button {
                    Task { await vm.syncWithCloud() }
                } label: {
                    Label("Sync now", systemImage: "arrow.triangle.2.circlepath")
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
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
                    if vm.trend.isEmpty {
                        Text("No data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
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
    }

    private var quickActions: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                GlassCard {
                    HStack {
                        if vm.hasPhysioData || vm.hasLifestyleData {
                            VStack(alignment: .leading) {
                                Text("Insights").font(.headline)
                                Text("Weekly report").font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        } else {
                            Text("No data")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
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
            Label("Watch data", systemImage: "applewatch")
                .font(.caption)
                .foregroundColor(.secondary)
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
    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    @State private var showSettings = false

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 16) {
                    header
                    stateCard
                    liveSignalCard
                    if liveVM.cards.isEmpty {
                        GlassCard {
                            Text("No data")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        metricsGrid
                    }
                    calibrationCard
                }
                .padding()
            }
        }
        .navigationTitle("Physiology")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        liveVM.refreshAll()
                        vm.simulateLiveTick()
                    } label: {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .foregroundColor(.blue)
                    }
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.blue)
                    }
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
                Text("Sync with Health or log manually — everything counts.")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
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
                    HStack(spacing: 6) {
                        Image(systemName: vm.hasLifestyleData ? "checkmark.circle.fill" : "pencil.and.outline")
                            .foregroundColor(vm.hasLifestyleData ? .green : .secondary)
                        Text(vm.hasLifestyleData ? "Data captured" : "Tap to log")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
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
                VStack(alignment: .leading, spacing: 12) {
                    DatePicker("Sleep time", selection: binding(\.sleepStart), displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.compact)
                    DatePicker("Wake time", selection: binding(\.wakeTime), displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.compact)
                    StepperRow(
                        title: "Sleep debt",
                        subtitle: "Hours short of your 8h target",
                        value: binding(\.sleepDebtHours),
                        step: 0.5,
                        format: "%.1f h"
                    )
                    StepperRow(
                        title: "Bedtime shift",
                        subtitle: "Deviation vs usual schedule",
                        value: binding(\.bedtimeShiftMinutes),
                        step: 15,
                        format: "%.0f min"
                    )
                    StepperRow(
                        title: "Sleep efficiency",
                        subtitle: "Aim for 85%+",
                        value: binding(\.sleepEfficiency),
                        step: 5,
                        format: "%.0f %", minValue: 0, maxValue: 100
                    )
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
                VStack(alignment: .leading, spacing: 12) {
                    StepperRow(
                        title: "Active minutes",
                        subtitle: "Walking, cycling, light movement",
                        value: binding(\.activityMinutes),
                        step: 5,
                        format: "%.0f min"
                    )
                    StepperRow(
                        title: "Vigorous minutes",
                        subtitle: "Runs, HIIT, sports",
                        value: binding(\.vigorousMinutes),
                        step: 5,
                        format: "%.0f min"
                    )
                    HStack {
                        Text("Estimated steps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(vm.lifestyle.activityMinutes * 100)) steps")
                            .font(.caption.weight(.semibold))
                    }
                    .padding(.top, 2)
                }
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
        if !vm.hasLifestyleData {
            return "Tap to log your day"
        }
        let l = vm.lifestyle
        switch category {
        case .sleep:
            return "\(timeString(l.sleepStart))–\(timeString(l.wakeTime)) • \(String(format: "%.1f", l.sleepDebtHours))h debt"
        case .stimulants:
            var parts: [String] = []
            if l.caffeineMgAfter2pm > 0 { parts.append("\(Int(l.caffeineMgAfter2pm))mg caffeine") }
            if l.alcoholUnitsAfter8pm > 0 { parts.append("\(l.alcoholUnitsAfter8pm) after 8PM") }
            if l.nicotine { parts.append("nicotine") }
            return parts.isEmpty ? "No stimulants logged" : parts.joined(separator: " • ")
        case .activity:
            return "\(Int(l.activityMinutes)) min active • \(Int(l.vigorousMinutes)) min vigorous"
        case .context:
            let hours = Int(l.workloadHours)
            return l.isExamDay ? "Deadline day • \(hours)h focus" : "\(hours)h workload"
        case .selfCare:
            return "\(Int(l.selfCareMinutes)) min self-care"
        case .cycle:
            return l.hasCycleData ? l.cyclePhase.rawValue : "Not tracking yet"
        case .screen:
            return "\(Int(l.post11pmScreenMinutes))m late • \(String(format: "%.1f", l.daytimeScreenHours))h day"
        case .diet:
            return "\(l.skippedMeals) skipped • \(l.sugaryItems) sugary • \(l.waterGlasses) water"
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
    var subtitle: String? = nil
    @Binding var value: Double
    var step: Double
    var format: String
    var minValue: Double = 0
    var maxValue: Double? = nil

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline)
                if let resolvedSubtitle {
                    Text(resolvedSubtitle).font(.caption).foregroundColor(.secondary)
                }
            }
            Spacer()
            HStack(spacing: 12) {
                Button {
                    value = max(minValue, value - step)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
                Text(String(format: format, value))
                    .font(.headline)
                Button {
                    let newValue = value + step
                    if let maxValue {
                        value = min(maxValue, newValue)
                    } else {
                        value = newValue
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var resolvedSubtitle: String? {
        if let subtitle { return subtitle }
        switch title {
        case "Caffeine after 2PM":
            return "-1 cup coffee ≈ 100mg"
        case "After 11PM":
            return "Min of late night use"
        default:
            return nil
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
                let moodSymbol = "face.smiling"
                HStack(spacing: 12) {
                    moodChip(label: "Calm", value: 0, icon: moodSymbol)
                    moodChip(label: "Mild", value: 1, icon: moodSymbol)
                    moodChip(label: "Moderate", value: 2, icon: moodSymbol)
                    moodChip(label: "Anxious", value: 3, icon: moodSymbol)
                    moodChip(label: "Very Anxious", value: 4, icon: moodSymbol)
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
    @State private var guide: InterventionGuide = .empty
    @State private var currentStepIndex: Int = 0
    @State private var secondsRemaining: Int = 0
    @State private var isRunning = false
    @State private var hasCompletedCycle = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 16) {
            topBar
            intro
            if guide.steps.isEmpty {
                Text("Guide not available for this exercise yet.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                breathCoach
                stepList
                controls
            }
            Spacer()
        }
        .padding(.vertical, 24)
        .background(AppTheme.background)
        .onAppear {
            configureGuide()
        }
        .onReceive(timer) { _ in
            guard isRunning, currentStep != nil else { return }
            tick()
        }
    }

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.title3).bold()
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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
    }

    private var intro: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 6) {
                Text(guide.summary)
                    .font(.subheadline)
                Text(item.effect)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }

    private var breathCoach: some View {
        let progress = guide.totalSeconds > 0 ? Double(elapsedSeconds) / Double(guide.totalSeconds) : 0
        return VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.15), lineWidth: 16)
                    .frame(width: 200, height: 200)
                Circle()
                    .trim(from: 0, to: min(1, progress))
                    .stroke(AppTheme.primaryGradient, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 200, height: 200)
                VStack(spacing: 6) {
                    Text(currentStep?.instruction ?? "Ready")
                        .font(.title3).bold()
                    Text("\(secondsRemaining)s")
                        .font(.largeTitle.weight(.semibold))
                    if let cue = currentStep?.cue {
                        Text(cue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Text(guide.title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .onTapGesture {
            if isRunning {
                isRunning = false
            } else {
                startGuide()
            }
        }
    }

    private var stepList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Flow")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            ForEach(Array(guide.steps.enumerated()), id: \.offset) { index, step in
                GlassCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.instruction)
                                .font(.subheadline).bold()
                            Text(step.cue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(step.duration)s")
                            .font(.caption.weight(.semibold))
                            .padding(8)
                            .background(index == currentStepIndex ? Color.blue.opacity(0.12) : Color.black.opacity(0.04))
                            .clipShape(Capsule())
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(index == currentStepIndex ? Color.blue.opacity(0.6) : Color.clear, lineWidth: 1)
                )
            }
        }
    }

    private var controls: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Button {
                    if isRunning {
                        isRunning = false
                    } else {
                        startGuide()
                    }
                } label: {
                    Label(isRunning ? "Pause" : "Start", systemImage: isRunning ? "pause.fill" : "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(GradientButtonStyle())

                Button {
                    resetGuide()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            if hasCompletedCycle {
                Text("Cycle complete — restart to repeat")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            Text("Tap Start or the circle to play/pause the sequence.")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }

    private var currentStep: InterventionGuide.Step? {
        guard guide.steps.indices.contains(currentStepIndex) else { return nil }
        return guide.steps[currentStepIndex]
    }

    private var elapsedSeconds: Int {
        let completedBefore = guide.steps.prefix(currentStepIndex).reduce(0) { $0 + $1.duration }
        let spentInStep = (currentStep?.duration ?? 0) - secondsRemaining
        return max(0, completedBefore + max(0, spentInStep))
    }

    private func configureGuide() {
        guide = InterventionGuide.make(for: item)
        resetGuide()
    }

    private func startGuide() {
        guard !guide.steps.isEmpty else { return }
        hasCompletedCycle = false
        isRunning = true
    }

    private func resetGuide() {
        currentStepIndex = 0
        secondsRemaining = guide.steps.first?.duration ?? 0
        isRunning = false
        hasCompletedCycle = false
    }

    private func tick() {
        guard !guide.steps.isEmpty else { return }
        if secondsRemaining > 0 {
            secondsRemaining -= 1
            return
        }
        advanceStep()
    }

    private func advanceStep() {
        if currentStepIndex + 1 < guide.steps.count {
            currentStepIndex += 1
            secondsRemaining = guide.steps[currentStepIndex].duration
        } else {
            isRunning = false
            hasCompletedCycle = true
            currentStepIndex = 0
            secondsRemaining = guide.steps.first?.duration ?? 0
        }
    }
}

private struct InterventionGuide {
    struct Step: Identifiable {
        let id = UUID()
        let instruction: String
        let duration: Int
        let cue: String
    }

    var title: String
    var summary: String
    var steps: [Step]

    var totalSeconds: Int {
        steps.reduce(0) { $0 + $1.duration }
    }

    static let empty = InterventionGuide(title: "", summary: "", steps: [])

    static func make(for item: Intervention) -> InterventionGuide {
        switch item.title {
        case _ where item.title.contains("4-7-8"):
            return InterventionGuide(
                title: "4-7-8 Breathing",
                summary: "Inhale quietly for 4s, hold for 7s, slow exhale for 8s.",
                steps: [
                    .init(instruction: "Inhale", duration: 4, cue: "Belly expands"),
                    .init(instruction: "Hold", duration: 7, cue: "Keep shoulders relaxed"),
                    .init(instruction: "Exhale", duration: 8, cue: "Pursed lips, slow release")
                ]
            )
        case _ where item.title.contains("Box"):
            return InterventionGuide(
                title: "Box Breathing",
                summary: "Steady 4-4-4-4 rhythm to reset your nervous system.",
                steps: [
                    .init(instruction: "Inhale", duration: 4, cue: "Count 1-2-3-4"),
                    .init(instruction: "Hold", duration: 4, cue: "Keep chest soft"),
                    .init(instruction: "Exhale", duration: 4, cue: "Slow and even"),
                    .init(instruction: "Hold", duration: 4, cue: "Stay still")
                ]
            )
        case _ where item.title.contains("5-4-3-2-1"):
            return InterventionGuide(
                title: "Grounding (5-4-3-2-1)",
                summary: "Name five senses items to anchor attention.",
                steps: [
                    .init(instruction: "5 things you see", duration: 20, cue: "Scan the room"),
                    .init(instruction: "4 things you feel", duration: 20, cue: "Feet on the floor"),
                    .init(instruction: "3 things you hear", duration: 20, cue: "Near and far sounds"),
                    .init(instruction: "2 things you smell", duration: 20, cue: "Deep breaths"),
                    .init(instruction: "1 thing you taste", duration: 20, cue: "Notice lingering taste")
                ]
            )
        case _ where item.title.contains("Walk"):
            return InterventionGuide(
                title: "Short Walk",
                summary: "Reset with gentle movement; breathe through the nose.",
                steps: [
                    .init(instruction: "Stand & stretch", duration: 20, cue: "Roll shoulders"),
                    .init(instruction: "Easy pace", duration: 60, cue: "Nose breathing"),
                    .init(instruction: "Notice surroundings", duration: 60, cue: "Name colors/shapes")
                ]
            )
        case _ where item.title.contains("Anxiety Dump"):
            return InterventionGuide(
                title: "Anxiety Dump",
                summary: "Write without editing to clear mental backlog.",
                steps: [
                    .init(instruction: "Write freely", duration: 90, cue: "No filtering"),
                    .init(instruction: "Circle priorities", duration: 40, cue: "Pick 1-2 items"),
                    .init(instruction: "Choose one action", duration: 40, cue: "Small next step")
                ]
            )
        case _ where item.title.contains("Soundscape"):
            return InterventionGuide(
                title: "Calming Soundscape",
                summary: "Low tempo audio to downshift arousal.",
                steps: [
                    .init(instruction: "Press play", duration: 15, cue: "Volume low"),
                    .init(instruction: "Close eyes", duration: 45, cue: "Slow exhales"),
                    .init(instruction: "Notice breath", duration: 60, cue: "Match beat")
                ]
            )
        default:
            return InterventionGuide(
                title: item.title,
                summary: "Follow the prompts to complete this exercise.",
                steps: [
                    .init(instruction: "Start", duration: 30, cue: "Stay present"),
                    .init(instruction: "Finish", duration: 30, cue: "Notice how you feel")
                ]
            )
        }
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
                        if !vm.hasHealthData {
                            Text("Waiting for Apple Health / Watch data...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if vm.weekly.isEmpty {
                            Text("No weekly data yet. Keep sharing check-ins and wearing your device.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Chart(vm.weekly) { day in
                                BarMark(
                                    x: .value("Day", day.date, unit: .day),
                                    y: .value("Score", day.score)
                                )
                                .foregroundStyle(AppTheme.primaryGradient)
                            }
                            .frame(height: 220)
                        }
                    }
                    GlassCard {
                        SectionHeader(title: "Top lifestyle contributors", subtitle: "Risk impact", icon: "list.bullet")
                        let lifestyleContribs = vm.contributors.filter { $0.category == .lifestyle }
                        if !vm.hasLifestyleData {
                            Text("Waiting for Apple Health / Watch data...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if lifestyleContribs.isEmpty {
                            Text("No lifestyle contributor data yet.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(lifestyleContribs.prefix(3)) { item in
                                ContributorRow(contributor: item)
                            }
                        }
                    }
                    GlassCard {
                        SectionHeader(title: "Top physiology contributors", subtitle: "Risk impact", icon: "waveform.path.ecg")
                        let physioContribs = vm.contributors.filter { $0.category == .physiology }
                        if !vm.hasPhysioData {
                            Text("Waiting for Apple Health / Watch data...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if physioContribs.isEmpty {
                            Text("No physiology contributor data yet.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(physioContribs.prefix(3)) { item in
                                ContributorRow(contributor: item)
                            }
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

// MARK: - Settings
struct SettingsView: View {
    @EnvironmentObject var vm: AnxietyCalculatorViewModel
    @AppStorage("google_logged_in") private var googleLoggedIn = false
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @AppStorage("auth_access_token") private var accessToken: String?
    @AppStorage("auth_refresh_token") private var refreshToken: String?
    @State private var exportRequested = false
    @State private var primaryConcern: String = "panic"
    @AppStorage("alert_frequency") private var alertFrequency: String = "low"
    @State private var watchConnected = true
    @State private var shareAnalytics = true
    @State private var personalizeData = true
    @State private var storeOnDeviceOnly = false
    @State private var activeSheet: SettingsSheet?
    @State private var showLogoutConfirm = false

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
                                    Text("Version 1.0.0").font(.caption).foregroundColor(.secondary)
                                }
                                Spacer()
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
                        settingsRow(
                            icon: "applewatch",
                            title: "Connected Devices",
                            subtitle: watchConnected ? "Apple Watch connected" : "No device connected"
                        ) {
                            activeSheet = .devices
                        }
                        Divider()
                        settingsRow(icon: "arrow.down.doc", title: "Export Data", subtitle: "Download your history") {
                            exportRequested = true
                        }
                        Divider()
                        settingsRow(icon: "lock.shield", title: "Privacy & Security", subtitle: "Manage your data") {
                            activeSheet = .privacy
                        }
                        Divider()
                        settingsRow(icon: "questionmark.circle", title: "Help & Support", subtitle: "FAQs and contact") {
                            activeSheet = .support
                        }
                        Divider()
                        settingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Log out", subtitle: "Sign out") {
                            showLogoutConfirm = true
                        }
                    }

                    GlassCard {
                        VStack(spacing: 4) {
                            Text("Anxiety Calculator").font(.subheadline).bold()
                            Text("Version 1.0.0").font(.caption).foregroundColor(.secondary)
                            Text("© 2025 Wellness Labs").font(.caption2).foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Settings")
        .alert("Data export", isPresented: $exportRequested) {
            Button("OK") {}
        } message: {
            Text("Exports are prepared from your on-device data.")
        }
        .alert("Log out?", isPresented: $showLogoutConfirm) {
            Button("Log out", role: .destructive) {
                googleLoggedIn = false
                onboardingComplete = false
                accessToken = nil
                refreshToken = nil
                Task { await SupabaseAuthService.shared.signOut() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You will be signed out on this device.")
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .devices:
                deviceSheet
            case .privacy:
                privacySheet
            case .support:
                supportSheet
            }
        }
    }

    private var deviceSheet: some View {
        NavigationStack {
            List {
                Section("Connected Device") {
                    HStack {
                        Image(systemName: "applewatch")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Apple Watch")
                                .font(.headline)
                            Text(watchConnected ? "Live sync enabled" : "Not connected")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Circle()
                            .fill(watchConnected ? Color.green : Color.red.opacity(0.7))
                            .frame(width: 10, height: 10)
                    }
                    Button(watchConnected ? "Disconnect" : "Connect") {
                        watchConnected.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section("Manage") {
                    Button("Pair new device") { }
                    Button("Reconnect manually") { }
                    Button("Forget all devices", role: .destructive) { watchConnected = false }
                }

                Section("Data Sources") {
                    Label("Heart rate, HRV, RR", systemImage: "heart.fill")
                    Label("Motion & activity", systemImage: "figure.run")
                    Label("Notifications & interventions", systemImage: "bell.badge.fill")
                }
            }
            .navigationTitle("Connected Devices")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { activeSheet = nil }
                }
            }
        }
    }

    private var privacySheet: some View {
        NavigationStack {
            List {
                Section("Data Controls") {
                    Toggle("Share check-in analytics", isOn: $shareAnalytics)
                    Toggle("Use data for personalization", isOn: $personalizeData)
                    Toggle("Store data on device only", isOn: $storeOnDeviceOnly)
                }
                Section("Security") {
                    Label("Encrypted in transit and at rest", systemImage: "lock.shield")
                    Label("Biometric lock supported", systemImage: "faceid")
                }
            }
            .navigationTitle("Privacy & Security")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { activeSheet = nil }
                }
            }
        }
    }

    private var supportSheet: some View {
        NavigationStack {
            List {
                Section("Contact") {
                    Label("support@wellnesslabs.app", systemImage: "envelope")
                    Label("Live chat (Mon–Fri)", systemImage: "message")
                }
                Section("Resources") {
                    Label("FAQ & troubleshooting", systemImage: "questionmark.circle")
                    Label("Emergency resources", systemImage: "phone.fill")
                }
                Section("Feedback") {
                    Button("Report a bug") { }
                    Button("Request a feature") { }
                }
            }
            .navigationTitle("Help & Support")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { activeSheet = nil }
                }
            }
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

private enum SettingsSheet: Identifiable {
    case devices, privacy, support
    var id: String {
        switch self {
        case .devices: return "devices"
        case .privacy: return "privacy"
        case .support: return "support"
        }
    }
}
