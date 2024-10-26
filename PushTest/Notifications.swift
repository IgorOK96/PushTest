//
//  Notifications.swift
//  Notifications
//
//  Created by user246073 on 10/25/24.
//  Copyright © 2024 Alexey Efimov. All rights reserved.
//

import UIKit
import UserNotifications

class Notifications: NSObject, UNUserNotificationCenterDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        { granted, error in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        notificationCenter.getNotificationSettings { settings in
            print("Notification settings: \(settings)")
        }
    }
    
    func scheduleNotification(notificationType: String) {
        let content = UNMutableNotificationContent()
        let userAction = "UserActionCategory"
        
        content.title = notificationType
        content.body = "This is an example for \(notificationType)"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = userAction
        
        if let image = UIImage(named: "hellowHat") {
            let tempDirectory = NSTemporaryDirectory()
            let imageFileIdentifier = "hellowHat.png"
            let imageURL = URL(
                fileURLWithPath: tempDirectory
            ).appendingPathComponent(imageFileIdentifier)

            if let imageData = image.jpegData(compressionQuality: 1.0) {
                do {
                    try imageData.write(to: imageURL)
                    let attachment = try UNNotificationAttachment(
                        identifier: imageFileIdentifier,
                        url: imageURL,
                        options: nil
                    )
                    content.attachments = [attachment]
                } catch {
                    print("Failed to create attachment: \(error)")
                }
            } else {
                print("Failed to retrieve image data")
            }
        } else {
            print("Image not found in Assets.xcassets")
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )
        let identifier = "LocalNotification"
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        let snoozeAction = UNNotificationAction(
            identifier: "Snooze",
            title: "Snooze",
            options: []
        )
        let deleteAction = UNNotificationAction(
            identifier: "Delete",
            title: "Delete",
            options: [.destructive]
        )
        
        let category = UNNotificationCategory(
            identifier: userAction,
            actions: [snoozeAction, deleteAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier == "LocalNotification" {
            print("Handling notification with the local Notification Identifier")
        }
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default Action")
        case "Snooze":
            print("Snooze Action")
            scheduleNotification(notificationType: "Reminder")
        case "Delete":
            print("Delete Action")
        default:
            print("Unknown action")
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }
}
