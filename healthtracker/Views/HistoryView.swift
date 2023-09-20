//
//  HistoryView.swift
//  healthtracker


import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var healthData: HealthData
    @Binding var selectedTab: Int
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView{
            VStack {
                
                Text("History")
                    .font(.largeTitle)
                    .foregroundColor(Color.black)
                    .offset(x: -100, y: 70)
                
                Spacer()
                Spacer()
                
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding(.horizontal)
                    .scaleEffect(0.85)
                    .onChange(of: selectedDate) { newDate in
                        healthData.getSleepHours(for: newDate)
                    }
                
                VStack {
                    HStack {
                        NavigationLink(destination: SleepLogScreen(selectedDate: $selectedDate).environmentObject(healthData),label: {
                            DataSquareView(title: "Sleep", data: String(format: "%.1f", healthData.sleepHours) + " hrs", backgroundColor: Color.indigo)
                        })

                        
                        NavigationLink(destination: WorkoutLogScreen(selectedDate: $selectedDate).environmentObject(healthData),label: {
                            DataSquareView(title: "Workout", data: String( HealthData.getDataForDate(date: selectedDate, dataList: healthData.workoutList)) + " mins", backgroundColor: Color.green)
                        })
                    }
                    
                    HStack {
                        NavigationLink(destination: WaterLogScreen(selectedDate: $selectedDate).environmentObject(healthData),label: {
                            DataSquareView(title: "Water", data: String( HealthData.getDataForDate(date: selectedDate, dataList: healthData.waterList)) + " oz", backgroundColor: Color.blue)
                        })
                        
                        NavigationLink(destination: MealLogScreen(selectedDate: $selectedDate).environmentObject(healthData),label: {
                            DataSquareView(title: "Meal", data: String( HealthData.getDataForDate(date: selectedDate, dataList: healthData.dietList)) + " calories", backgroundColor: Color.orange)
                        })
                    }
                }.padding(.bottom)
                
                Spacer()
            }
        }
    }
}

struct DataSquareView: View {
    var title: String
    var data: String
    var backgroundColor: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
               .foregroundColor(backgroundColor.opacity(0.8))
               .frame(width: 150.0, height: 100.0)
               .overlay(
                    VStack{
                        Text(title)
                            .font(.headline)
                        Text(data)
                            .font(.title2)
                    }
               )
                       .foregroundColor(Color.black)
                       .cornerRadius(20)
    }
}
