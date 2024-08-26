//
//  OTPInput.swift
//  NorteGo
//
//  Created by Jonathan  Moran on 20/8/24.
//

import SwiftUI

struct OTPInput: View {
    
    let numberOfFields: Int
    @Binding var otpCode: String
    
    @State private var enterValue: [String]
    @FocusState private var fieldFocus: Int?
    @State private var oldValue = ""
    
    init(numberOfFields: Int, otpCode: Binding<String>) {
        self.numberOfFields = numberOfFields
        self._otpCode = otpCode
        self._enterValue = State(initialValue: Array(repeating: "", count: numberOfFields))
    }
    
    var body: some View {
        
        HStack {
            ForEach(0..<numberOfFields, id: \.self) { index in
                TextField("", text: $enterValue[index], onEditingChanged: { editing in
                    if editing {
                        oldValue = enterValue[index]
                    }
                })
                .keyboardType(.numberPad)
                .frame(width: 48, height: 48)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(5)
                .multilineTextAlignment(.center)
                .focused($fieldFocus, equals: index)
                .tag(index)
                .onChange(of: enterValue[index]) { _ in
                    if enterValue[index].count > 1 {
                        enterValue[index] = String(enterValue[index].suffix(1))
                    }
                    
                    if !enterValue[index].isEmpty {
                        if index == numberOfFields - 1 {
                            fieldFocus = nil
                        } else {
                            fieldFocus = (fieldFocus ?? 0) + 1
                        }
                    } else {
                        fieldFocus = (fieldFocus ?? 0) - 1
                    }
                    
                    checkIfOTPIsComplete()
                }
            }
        }
        .onChange(of: enterValue) { _ in
            checkIfOTPIsComplete()
        }
    }
    
    
    private func checkIfOTPIsComplete() {
       // let isComplete = enterValue.allSatisfy { !$0.isEmpty }
        //if isComplete {
            otpCode = enterValue.joined()
        //}
    }
    
    
}


