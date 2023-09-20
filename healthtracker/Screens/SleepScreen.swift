//
//  SleepScreen.swift
//  healthtracker

import SwiftUI
import Charts

struct SleepScreen: View {
    @EnvironmentObject var healthData: HealthData
    @State private var addItemPopup = false
    @State private var setDefaultPopup = false
    @State private var selectedSleepData: SleepData?
    @State private var sleepGoalPopup = false
    @State private var goalValue = 8
    @State private var sleepHours: Double = 0.0
    @State private var weeklySleepData: [[SleepData]] = Array(repeating: [], count: 7)

    
    var currentDate = Date()
    var flattenedWeeklySleepData: [SleepData] {
        return weeklySleepData.flatMap { $0 }.filter { $0.duration > 0 }
    }

    let formatter = DateFormatter()
    
    func loadSleepHours() {
        healthData.getSleepHours(for: currentDate) { hours in
            print("Fetched hours: \(hours)")
            self.sleepHours = hours
        }
    }
    
    func loadChartData() {
        for i in 0...6 {
            let date = Date().getDayBefore(num: i)
            healthData.getSleepEntriesDateDefault(for: date) { fetchedData in
                weeklySleepData[i] = fetchedData
            }
        }
    }


    let sleepView: [SleepChart] = [
        //SleepChart(weekday: Date().dayBefore6, sleepTime: Int)
    ]
    
    var body: some View {

        ZStack {
            Color.gray
                .brightness(0.4)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            VStack {
                Text("Sleep Tracker")
                    .font(.title)
                    .foregroundColor(.indigo)
                    .bold()
                
                Chart{
                    RuleMark(
                        y:.value("Goal",goalValue)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .annotation(position: .top, alignment: .leading){
                        Text("Goal: \(goalValue,format:.number)")
                            .font(.body)
                            .foregroundStyle(.blue)
                    }
                    
                    ForEach((0...6).reversed(), id: \.self) { i in
                        ForEach(weeklySleepData[i], id: \.date) { j in
                            BarMark(
                                x: .value("Date", j.date.formatted(.dateTime.weekday(.abbreviated))),
                                y: .value("Duration", j.duration)
                            )
                            .opacity(0.3)
                        }
                    }

                }
                .frame(width: 350.0, height: 250.0)
                .background(.white)
                .onAppear {
                    for i in 0...6 {
                        let date = Date().getDayBefore(num: i)
                        healthData.getSleepEntriesDateDefault(for: date) { fetchedData in
                            weeklySleepData[i] = fetchedData
                        }
                    }
                }
            
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.white)
                        .frame(width: 350.0, height: 100.0)
                        .overlay(
                            VStack {
                                HStack {
                                    Text("Today")
                                        .font(.title)
                                        .foregroundColor(.indigo)
                                        .bold()
                                        .offset(x: -55, y: -5)
                                    
                                    Text(currentDate, style: .date)
                                        .font(.body)
                                        .foregroundColor(.black)
                                        .bold()
                                        .offset(x: -55, y: -3)
                                }
                
                                HStack {
                
                                    VStack {
                                        HStack {
                                            Text("\(sleepHours, specifier: "%.1f")")
                                                .font(.custom("Arial Rounded MT Bold", size: 25))
                                                .foregroundColor(.indigo)
                                                .offset(x: 0, y: 10)
                                            
                                            Text("hours")
                                                .font(.custom("Arial Rounded MT Bold", size: 20))
                                                .foregroundColor(.black)
                                                .offset(x: 0, y: 10)
                                        }
                                    }
                                }
                            }
                        )
                }.onAppear(perform: loadSleepHours)
                    
                
                
                List {
                    Section(header: Spacer(minLength: 0)) {
                        ForEach(flattenedWeeklySleepData) { data in
                            HStack {
                                Button(action: {
                                    selectedSleepData = data
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .foregroundColor(.white)
                                            .frame(width: 370.0, height: 80.0)
                                            .overlay(
                                                VStack {
                                                    HStack {
                                                        VStack {
                                                            Text("Start Time:")
                                                                .font(.custom("Arial Rounded MT Bold", size: 16))
                                                                .foregroundColor(.black)
                                                            
                                                            HStack {
                                                                Text("\(data.startTime, formatter: timeFormatter)")
                                                                    .font(.custom("Arial Rounded MT Bold", size: 22))
                                                                    .foregroundColor(.indigo)
                                                                    .offset(x: -8, y: 0)
                                                            }
                                                            
                                                        }
                                                        
                                                        VStack {
                                                            Text("End Time:")
                                                                .font(.custom("Arial Rounded MT Bold", size: 16))
                                                                .foregroundColor(.black)
                                                                .offset(x: -3, y: 0)
                                                            
                                                            HStack {
                                                                Text("\(data.endTime, formatter: timeFormatter)")
                                                                    .font(.custom("Arial Rounded MT Bold", size: 22))
                                                                    .foregroundColor(.indigo)
                                                                    .offset(x: -3, y: 0)
                                                            }
                                                        }
                                                        
                                                        
                                                        VStack {
                                                            Text("Duration:")
                                                                .font(.custom("Arial Rounded MT Bold", size: 16))
                                                                .foregroundColor(.black)
                                                                .offset(x: 3, y: 1)
                                                            
                                                            HStack {
                                                                Text("\(data.duration, specifier: "%.1f")")
                                                                    .font(.custom("Arial Rounded MT Bold", size: 22))
                                                                    .foregroundColor(.indigo)
                                                                    .offset(x: 3, y: 0)
                                                                
                                                                Text("hrs")
                                                                    .font(.custom("Arial Rounded MT Bold", size: 20))
                                                                    .foregroundColor(.black)
                                                                    .offset(x: 3, y: 0)
                                                                
                                                            }
                                                        }
                                                        
                                                        
                                                        Image(systemName: "trash")
                                                            .foregroundColor(.red)
                                                            .offset(x: 12)
                                                            .onTapGesture {
                                                                if let dayIndex = weeklySleepData.firstIndex(where: { dayData in
                                                                    dayData.contains { $0.id == data.id }
                                                                }), let entryIndex = weeklySleepData[dayIndex].firstIndex(where: { $0.id == data.id }) {
                                                                    weeklySleepData[dayIndex].remove(at: entryIndex)
                                                                    healthData.deleteSleepData(withID: data.id, for: data.date)
                                                                    
                                                                    loadSleepHours()
                                                                    
                                                                } else {
                                                                    print("Data not found in weeklySleepData")
                                                                }
                                                            }


                                                    }
                                                }
                                            )
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }

                }
                .listStyle(PlainListStyle())
                .onAppear {
                    healthData.getSleepEntriesDateDefault(for: currentDate) { fetchedData in
                        healthData.sleepList = fetchedData
                    }
                }


            }
            
            VStack {
                Spacer()
                
                HStack {
                    
                    Button(action: {
                        sleepGoalPopup.toggle()
                    }) {
                        Image(systemName: "note.text")
                            .font(.system(size: 55))
                            .padding()
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        addItemPopup.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 55))
                            .padding()
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
        .sheet(isPresented: $addItemPopup) {
            SleepDataEntryView { sleepData in
                healthData.addSleepData(newEntry: sleepData)
                addItemPopup = false
                loadChartData()
                loadSleepHours()
            }
            .presentationDetents([.medium])
        }
        .fullScreenCover(item: $selectedSleepData) { sleepData in
            SleepDataDetailView(sleepData: sleepData)
        }
        .sheet(isPresented: $sleepGoalPopup) {
                SleepGoalEntryView { goalValue in
                    self.goalValue = goalValue
                    sleepGoalPopup = false
                }
        .presentationDetents([.medium])
        }
    }
    
}

struct SleepGoalEntryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var goal: String = ""
    
    var onSubmit: (Int) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter sleep goal (hours)", text: $goal)
                    .keyboardType(.numberPad)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            .navigationTitle("Set Sleep Goal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        if let goalInt = Int(goal) {
                            onSubmit(goalInt)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct SleepDataDetailView: View {
    var sleepData: SleepData
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Date: \(sleepData.date, formatter: dateFormatter)")
                Text("Start Time: \(sleepData.startTime, formatter: timeFormatter)")
                Text("End Time: \(sleepData.endTime, formatter: timeFormatter)")
                Text("Duration: \(sleepData.duration, specifier: "%.1f") hours")
            }
            .padding()
            .navigationTitle("Sleep Details")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SleepDataEntryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var date = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    
    var onSubmit: (SleepData) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                
                DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                
                DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
            }
            .navigationTitle("Add Sleep Data")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        onSubmit(SleepData(date: date, startTime: startTime, endTime: endTime))
                        dismiss()
                    }
                }
            }
        }
    }
    
    func calculateDuration(startTime: Date, endTime: Date) -> TimeInterval {
        var duration = endTime.timeIntervalSince(startTime) / 3600
        if duration < 0 {
            duration += 24
        }
        return duration
    }
    
}

struct SleepChart: Identifiable{
    let weekday: Date
    let sleepTime: Int
    
    var id: Date { weekday }
}

struct SleepScreen_Previews: PreviewProvider {
    static var previews: some View {
        SleepScreen()
            .environmentObject(HealthData())
    }
}

