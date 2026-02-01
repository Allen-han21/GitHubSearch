import Foundation

extension Date {

    var relativeString: String {
        let now = Date()
        let interval = now.timeIntervalSince(self)

        // 미래 시간 처리
        if interval < 0 {
            return "방금 전"
        }

        let seconds = Int(interval)
        let minutes = seconds / 60
        let hours = minutes / 60
        let days = hours / 24

        if seconds < 60 {
            return "방금 전"
        } else if minutes < 60 {
            return "\(minutes)분 전"
        } else if hours < 24 {
            return "\(hours)시간 전"
        } else if days < 7 {
            return "\(days)일 전"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M월 d일"
            return formatter.string(from: self)
        }
    }
}
