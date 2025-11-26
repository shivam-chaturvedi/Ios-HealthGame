import SwiftUI

@MainActor
struct ContentView: View {
    @StateObject private var vm: HealthDataViewModel

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    init(vm: HealthDataViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    init() {
        self.init(vm: HealthDataViewModel())
    }

    var body: some View {
        NavigationView {
            ZStack {
                background
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header

                        if vm.authorized {
                            ForEach(HealthCategory.allCases, id: \.rawValue) { category in
                                let items = vm.metrics(for: category)
                                if !items.isEmpty {
                                    MetricSection(category: category, metrics: items, columns: columns)
                                }
                            }
                        } else {
                            permissionCard
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Health Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        vm.refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .tint(.white)
                }
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.07, green: 0.10, blue: 0.20),
                Color(red: 0.08, green: 0.18, blue: 0.35),
                Color(red: 0.16, green: 0.12, blue: 0.26)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Apple Watch")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Health Snapshot")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.white)

            if let sync = vm.lastSync {
                Text("Updated \(relativeSyncString(from: sync))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Pulling your latest Health data…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var permissionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "hand.raised.fill")
                .font(.title)
                .foregroundStyle(.yellow)
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text("Health access needed")
                .font(.headline)
            Text("Enable Health permissions on your iPhone to sync Apple Watch data.")
                .foregroundStyle(.secondary)
                .font(.subheadline)

            Button {
                vm.requestAuthorization()
            } label: {
                Label("Grant Health Access", systemImage: "lock.open.fill")
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
            .background(LinearGradient(colors: [.pink, .orange], startPoint: .leading, endPoint: .trailing))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func relativeSyncString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

private struct MetricSection: View {
    let category: HealthCategory
    let metrics: [HealthMetric]
    let columns: [GridItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(category.rawValue)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)
                Spacer()
                RoundedRectangle(cornerRadius: 4)
                    .fill(category.accent)
                    .frame(width: 46, height: 4)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(metrics) { metric in
                    MetricCard(metric: metric)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(category.tint.opacity(0.3), lineWidth: 1)
        )
    }
}

private struct MetricCard: View {
    let metric: HealthMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle()
                    .fill(metric.category.accent)
                    .frame(width: 34, height: 34)
                    .opacity(0.9)
                    .overlay(
                        Image(systemName: metric.systemImage)
                            .font(.headline)
                            .foregroundStyle(.white)
                    )

                Spacer()

                Text(metric.category.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(metric.category.tint.opacity(0.15))
                    .clipShape(Capsule())
                    .foregroundStyle(.white.opacity(0.8))
            }

            Text(metric.title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(metric.value)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)

            Text(metric.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(metric.category.tint.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ContentView(vm: .preview)
}
