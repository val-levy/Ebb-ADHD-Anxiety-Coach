import Foundation
import SwiftUI

/// Enforces daily nudge controls and persists a person's responses to check-ins.
@MainActor
final class NudgeStore: ObservableObject {
    @Published var isShowing = false
    @Published private(set) var dailyCount = 0
    @Published private(set) var nudgeCap: Int
    @Published private(set) var isPausedToday: Bool

    private let service: SupabaseService
    private let scheduler: NudgeScheduler
    private var activeEvent: NudgeEvent?
    private var insertTask: Task<NudgeEvent?, Never>?
    private var responseRecorded = false
    private var plan: [ScheduleItem] = []
    private let defaults: UserDefaults
    private let capKey = "nudgeCap"
    private let pauseDayKey = "nudgePauseDay"
    private let snoozeKey = "nudgeSnoozedUntil"

    init(service: SupabaseService, scheduler: NudgeScheduler = NudgeScheduler(), defaults: UserDefaults = .standard) {
        self.service = service
        self.scheduler = scheduler
        self.defaults = defaults
        let storedCap = defaults.integer(forKey: capKey)
        self.nudgeCap = storedCap == 0 ? 3 : storedCap
        self.isPausedToday = (defaults.object(forKey: pauseDayKey) as? Date)
            .map { Calendar.current.isDateInToday($0) } ?? false

        NotificationCenter.default.addObserver(forName: .plannedNudgeTapped, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.present(origin: .planned) }
        }
    }

    var pauseBinding: Binding<Bool> {
        Binding(get: { self.isPausedToday }, set: { self.setPaused($0) })
    }

    var capBinding: Binding<Int> {
        Binding(get: { self.nudgeCap }, set: { self.setCap($0) })
    }

    func start(plan: [ScheduleItem]) async {
        self.plan = plan
        refreshDay()
        try? await service.ensureSignedIn()
        let startOfDay = Calendar.current.startOfDay(for: .now)
        dailyCount = (try? await service.nudgeEvents(since: startOfDay).count) ?? dailyCount
        await schedule(plan: plan)
    }

    func updatePlan(_ plan: [ScheduleItem]) async {
        self.plan = plan
        refreshDay()
        await schedule(plan: plan)
    }

    func presentPreview() {
        present(origin: .preview)
    }

    func accept() {
        finish(.accepted)
    }

    func dismiss() {
        finish(.dismissed)
    }

    func snooze() {
        defaults.set(Date.now.addingTimeInterval(60 * 60), forKey: snoozeKey)
        finish(.snoozed)
        Task { await schedule(plan: plan) }
    }

    func markFalseAlarm() {
        finish(.falseAlarm)
    }

    func setCap(_ value: Int) {
        nudgeCap = value
        defaults.set(value, forKey: capKey)
        Task { await schedule(plan: plan) }
    }

    func setPaused(_ value: Bool) {
        isPausedToday = value
        if value { defaults.set(Date.now, forKey: pauseDayKey) }
        else { defaults.removeObject(forKey: pauseDayKey) }
        Task { await schedule(plan: plan) }
    }

    private func present(origin: NudgeOrigin) {
        refreshDay()
        guard !isPausedToday, snoozedUntil.map({ $0 <= .now }) ?? true, dailyCount < nudgeCap else { return }
        let event = NudgeEvent(origin: origin, created_at: .now)
        activeEvent = event
        responseRecorded = false
        dailyCount += 1
        isShowing = true
        insertTask = Task {
            try? await service.ensureSignedIn()
            return try? await service.insert(event)
        }
    }

    private func finish(_ outcome: NudgeOutcome) {
        guard !responseRecorded else { return }
        responseRecorded = true
        isShowing = false
        let insertTask = insertTask
        Task {
            guard let id = await insertTask?.value?.id else { return }
            try? await service.setNudgeOutcome(id: id, outcome: outcome)
        }
    }

    private func refreshDay() {
        guard let pauseDay = defaults.object(forKey: pauseDayKey) as? Date,
              !Calendar.current.isDateInToday(pauseDay) else { return }
        defaults.removeObject(forKey: pauseDayKey)
        isPausedToday = false
    }

    private var snoozedUntil: Date? {
        guard let date = defaults.object(forKey: snoozeKey) as? Date else { return nil }
        if date > .now { return date }
        defaults.removeObject(forKey: snoozeKey)
        return nil
    }

    private func schedule(plan: [ScheduleItem]) async {
        await scheduler.reconcile(plan: plan, dailyCap: nudgeCap, paused: isPausedToday, snoozedUntil: snoozedUntil)
    }
}
