/// A badge earned from real usage. Rules live here so views only display them.
struct Achievement: Identifiable {
    let id: String
    let symbol: String
    let title: String
    let detail: String
    let earned: Bool

    static func all(resets: Int, sessions: Int, helped: Int) -> [Achievement] {
        [
            .init(id: "first-reset", symbol: "leaf.fill", title: "First breath", detail: "Do your first reset", earned: resets >= 1),
            .init(id: "five-resets", symbol: "flame.fill", title: "On a roll", detail: "5 resets this week", earned: resets >= 5),
            .init(id: "first-guided", symbol: "heart.fill", title: "Rode the wave", detail: "Finish a guided session", earned: sessions >= 1),
            .init(id: "helped-3", symbol: "star.fill", title: "Know what works", detail: "3 resets that helped", earned: helped >= 3),
            .init(id: "ten-sessions", symbol: "mountain.2.fill", title: "Steady ground", detail: "10 guided sessions", earned: sessions >= 10),
        ]
    }
}
