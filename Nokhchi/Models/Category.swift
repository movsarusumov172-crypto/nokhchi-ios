import Foundation

enum BusinessCategory: String, CaseIterable, Codable, Identifiable {
    case restaurants
    case halal
    case autoService
    case tires
    case carWash
    case construction
    case beauty
    case medicine
    case legal
    case education
    case transport
    case technology
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .restaurants: "Рестораны и кафе"
        case .halal: "Халяль еда и магазины"
        case .autoService: "Автосервис"
        case .tires: "Шиномонтаж"
        case .carWash: "Автомойка"
        case .construction: "Стройка и ремонт"
        case .beauty: "Красота и барбершоп"
        case .medicine: "Медицина"
        case .legal: "Юридические услуги"
        case .education: "Образование и Коран"
        case .transport: "Транспорт и доставка"
        case .technology: "IT и дизайн"
        case .other: "Другое"
        }
    }

    var symbol: String {
        switch self {
        case .restaurants: "fork.knife"
        case .halal: "cart"
        case .autoService: "wrench.and.screwdriver"
        case .tires: "circle.circle"
        case .carWash: "drop"
        case .construction: "hammer"
        case .beauty: "scissors"
        case .medicine: "cross.case"
        case .legal: "doc.text"
        case .education: "book"
        case .transport: "shippingbox"
        case .technology: "laptopcomputer"
        case .other: "square.grid.2x2"
        }
    }
}
