//
//  OTPInput.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 20/8/24.
//

import SwiftUI
import UIKit
import UserNotifications

struct OTPInput: View {
    let numberOfFields: Int
    @Binding var otpCode: String
    @StateObject private var smsDetector = SMSDetector()
    @State private var enterValue: [String]
    @FocusState private var fieldFocus: Int?
    @State private var showPermissionAlert = false

    init(numberOfFields: Int, otpCode: Binding<String>) {
        self.numberOfFields = numberOfFields
        self._otpCode = otpCode
        self._enterValue = State(initialValue: Array(repeating: "", count: numberOfFields))
    }

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                ForEach(0..<numberOfFields, id: \.self) { index in
                    TextField("", text: $enterValue[index])
                        .keyboardType(.numberPad)
                        .frame(width: 48, height: 48)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(5)
                        .multilineTextAlignment(.center)
                        .focused($fieldFocus, equals: index)
                        .onChange(of: enterValue[index]) { newValue in
                            handleInputChange(at: index, with: newValue)
                        }
                        .onTapGesture {
                            fieldFocus = index
                        }
                }
            }
        }
        .onChange(of: enterValue) { _ in
            otpCode = enterValue.joined()
        }
        .onChange(of: smsDetector.smsOTPCode) { newCode in
            if newCode.count == numberOfFields {
                // Actualizar los campos con el código recibido
                for (index, char) in newCode.enumerated() {
                    enterValue[index] = String(char)
                }
                otpCode = newCode
            }
        }
        .onAppear {
            fieldFocus = 0
            checkNotificationPermissions()
        }
        .alert("Permisos Necesarios", isPresented: $showPermissionAlert) {
            Button("Configuración", role: .none) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Para detectar automáticamente el código SMS, necesitamos permiso para recibir notificaciones. Por favor, habilita los permisos en la configuración.")
        }
    }

    private func handleInputChange(at index: Int, with newValue: String) {
        if newValue.count > 1 {
            enterValue[index] = String(newValue.last!)
        }

        if !enterValue[index].isEmpty {
            if index < numberOfFields - 1 {
                fieldFocus = index + 1
            }
        } else if fieldFocus == index && index > 0 && enterValue[index].isEmpty {
            fieldFocus = index - 1
            enterValue[index] = ""
        }
    }
    
    private func checkNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    // Solicitar permisos
                    smsDetector.registerSMSObserver()
                case .denied:
                    // Mostrar alerta para ir a configuración
                    showPermissionAlert = true
                case .authorized, .provisional, .ephemeral:
                    // Ya tenemos permisos, registrar el observador
                    smsDetector.registerSMSObserver()
                @unknown default:
                    break
                }
            }
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
