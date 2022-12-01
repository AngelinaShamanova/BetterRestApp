//
//  ContentView.swift
//  BetterRestApp
//
//  Created by Ангелина Шаманова on 1.12.22..
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    
    private var sleepTime: Date? {
        do {
            let configuration = MLModelConfiguration()
            let model = try SleepCalculator(configuration: configuration)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            return wakeUp - prediction.actualSleep
        }
        catch {
            return Date()
        }
    }
    
    private static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    private var perfectBedtime: String? {
        sleepTime?.formatted(date: .omitted, time: .shortened)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .padding([.top, .bottom])
                } header: {
                    Text("When do you want to wake up?")
                }
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        .padding([.top, .bottom])
                } header: {
                    Text("Desired amount of sleep")
                }
                Section {
                    Picker("Number of cups", selection: $coffeeAmount) {
                        ForEach(1...20, id: \.self) { cups in
                            Text("\(cups)")
                        }
                    }
                    .padding([.top, .bottom])
                } header: {
                    Text("Daily coffee intake")
                }
                Section {
                } footer: {
                    HStack(spacing: 5) {
                        Text("Your perfect bedtime at")
                        Text(perfectBedtime ?? "")
                            .foregroundColor(.indigo)
                    }
                    .font(.title3.bold())
                    .padding(.top)
                }
            }
            .navigationTitle("BetterRest")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
