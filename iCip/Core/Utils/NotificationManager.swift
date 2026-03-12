//
//  NotificationManager.swift
//  iCip
//
//  Manages local notifications for the application.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    /// Request authorization for local notifications
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission denied: \(error.localizedDescription)")
            }
        }
    }
    
    /// Schedules daily reminders for up to 7 days starting from the baby's upcoming monthly "birth date".
    /// Example: If baby was born on Jan 15, schedules for Feb 15, 16, 17, 18, 19, 20, 21.
    func scheduleMonthlyGrowthReminders(for baby: Baby) {
        // First, check permission status before scheduling
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard settings.authorizationStatus == .authorized else { return }
            self?.createGrowthSchedules(for: baby)
        }
    }
    
    private func createGrowthSchedules(for baby: Baby) {
        let calendar = Calendar.current
        let now = Date()
        
        let birthDateComponents = calendar.dateComponents([.day], from: baby.dateOfBirth)
        guard let birthDay = birthDateComponents.day else { return }
        
        // Find the next month's birthday occurrence
        var targetMonthDate = calendar.date(bySetting: .day, value: birthDay, of: now)
        
        // If the calculated date is already past in the current month, shift to next month
        if let currentTarget = targetMonthDate, currentTarget <= now {
            targetMonthDate = calendar.date(byAdding: .month, value: 1, to: currentTarget)
        }
        
        guard let finalTargetDate = targetMonthDate else { return }
        
        // Cancel existing pending growth reminders before setting new ones
        cancelGrowthReminders()
        
        // Schedule for 7 consecutive days starting from the finalTargetDate
        for dayOffset in 0..<7 {
            guard let triggerDate = calendar.date(byAdding: .day, value: dayOffset, to: finalTargetDate) else { continue }
            
            // Set the notification time to 09:00 AM
            var triggerComponents = calendar.dateComponents([.year, .month, .day], from: triggerDate)
            triggerComponents.hour = 9
            triggerComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            
            let content = UNMutableNotificationContent()
            content.title = "Waktunya Cek Pertumbuhan!"
            content.body = "Yuk bun, masukkan data Berat dan Tinggi Badan bulan ini untuk memantau tumbuh kembang \(baby.name)."
            content.sound = .default
            
            // Unique ID per day offset to easily manage
            let request = UNNotificationRequest(identifier: "growth_reminder_\(dayOffset)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
        print("Scheduled 7 days of growth reminders starting from: \(finalTargetDate)")
    }
    
    /// Cancels all pending notifications related to growth reminders
    func cancelGrowthReminders() {
        let identifiers = (0..<7).map { "growth_reminder_\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("Cancelled any existing growth reminders.")
    }
}
