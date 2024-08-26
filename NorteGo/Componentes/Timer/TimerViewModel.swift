//
//  TimerViewModel.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 21/8/24.
//

import Foundation
import SwiftUI

class TimerViewModel: ObservableObject {
    @Published var tiempoSegundo: Int
    @Published var timerIsRunning: Bool = false

    private var timer: Timer?

    init(initialTime: Int) {
        self.tiempoSegundo = initialTime
    }

    func startTimer() {
        stopTimer() // Detener cualquier temporizador previo
        timerIsRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            if let self = self {
                if self.tiempoSegundo > 0 {
                    self.tiempoSegundo -= 1
                } else {
                    self.stopTimer()
                }
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timerIsRunning = false
    }

    func resetTimer(to time: Int) {
        stopTimer()
        tiempoSegundo = time // Reinicia el tiempo a un valor personalizado
        startTimer() // Inicia el temporizador nuevamente
    }
}
