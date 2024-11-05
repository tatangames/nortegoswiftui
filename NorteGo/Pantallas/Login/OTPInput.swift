//
//  OTPInput.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 20/8/24.
//

import SwiftUI
import UIKit
import UserNotifications

public struct OTPInput: View {
    
    private var activeIndicatorColor: Color
    private var inactiveIndicatorColor: Color
    private let doSomething: (String) -> Void
    private let length: Int
    
    @State private var otpText = ""
    @FocusState private var isKeyboardShowing: Bool
    
    public init(activeIndicatorColor: Color, inactiveIndicatorColor: Color, length: Int, doSomething: @escaping (String) -> Void) {
        self.activeIndicatorColor = activeIndicatorColor
        self.inactiveIndicatorColor = inactiveIndicatorColor
        self.length = length
        self.doSomething = doSomething
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<length, id: \.self) { index in
                OTPTextBox(index)
            }
        }
        .background {
            TextField("", text: $otpText)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isKeyboardShowing)
                .onChange(of: otpText) { newValue in
                    limitTextFieldInput(newValue)
                }
                .onAppear {
                    DispatchQueue.main.async {
                        isKeyboardShowing = true
                    }
                }
                .frame(width: 1, height: 1) // Ocultar el TextField
                .opacity(0.01)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isKeyboardShowing = true
        }
    }
    
    @ViewBuilder
    func OTPTextBox(_ index: Int) -> some View {
        ZStack {
            if otpText.count > index {
                let char = otpText[otpText.index(otpText.startIndex, offsetBy: index)]
                Text(String(char))
            } else {
                Text(" ")
            }
        }
        .frame(width: 45, height: 45)
        .background {
            let isActive = isKeyboardShowing && otpText.count == index
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(isActive ? activeIndicatorColor : inactiveIndicatorColor, lineWidth: 2)
                .animation(.easeInOut(duration: 0.2), value: isActive)
        }
    }
    
    private func limitTextFieldInput(_ newValue: String) {
        if newValue.count > length {
            otpText = String(newValue.prefix(length))
        } else {
            otpText = newValue
        }
        
        if otpText.count == length {
            doSomething(otpText)
        }
    }
}



class SMSDetector: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    @Published var smsOTPCode: String = ""

    func registerSMSObserver() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    let center = UNUserNotificationCenter.current()
                    center.delegate = self
                }
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let smsText = notification.request.content.body.components(separatedBy: ":").last else {
            return
        }

        DispatchQueue.main.async {
            self.smsOTPCode = smsText.trimmingCharacters(in: .whitespaces)
        }
        completionHandler([.banner, .sound])
    }
    
    // Para manejar notificaciones cuando la app está en background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let smsText = response.notification.request.content.body.components(separatedBy: ":").last {
            DispatchQueue.main.async {
                self.smsOTPCode = smsText.trimmingCharacters(in: .whitespaces)
            }
        }
        completionHandler()
    }
}
