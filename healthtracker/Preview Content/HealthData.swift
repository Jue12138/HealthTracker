//
//  HealthData.swift
//  healthtracker


import Foundation
import SwiftUI
import FirebaseDatabase

enum HealthDataType{
    case sleep
    case workout
    case water
    case diet
}


enum ActivityLevel: String, CaseIterable, Identifiable{
    case sedentary = "Sedentary (little or no exercise)"
    case light = "Lightly Active (1-3 days/week)"
    case moderate = "Moderately Active (3-5 days/week)"
    case active = "Very Active (6-7 days/week)"
    case extra = "Extra Active (vigorous exercise daily)"
    
    var id: Self { self }
}

enum Gender: String,CaseIterable, Identifiable{
    case female = "Female"
    case male = "Male"
    case other = "Other"
    
    var id: Self { self }
    
}


enum MealType: String,CaseIterable, Identifiable, Codable{
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case brunch = "Brunch"
    case snack = "Snack"
    case fruit = "Fruit"
    
    var id: Self { self }
    
}

struct SleepData: Identifiable, CustomStringConvertible, Codable {
    var id = UUID()
    var date: Date
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval {
        var timeInterval = endTime.timeIntervalSince(startTime) / 3600
        if (timeInterval < 0) {
            timeInterval += 24
        }
        return timeInterval
    }
    var description: String {
        return "{Date: \(dateFormatter.string(from: date)) Duration: \(duration)}"
    }
}

struct WorkoutData: Identifiable, CountableData, Codable {
    var id = UUID()
    var date: Date
    var type: String
    var data: Int
}

struct WaterData: Identifiable, CountableData, Codable {
    
    var id = UUID()
    var date: Date
    var data: Int
}

struct DietData: Identifiable, CountableData, Codable {
    var id = UUID()
    var date: Date
    var type: MealType
    var food: String
    var data: Int
}

protocol CountableData {
    var data: Int { get set }
    var date: Date { get set }
}


class HealthData: ObservableObject {
    @Published var sleepList: [SleepData] = []
    @Published var sleepEntriesForSelectedDate: [SleepData] = []
    @Published var sleepHours: Double = 0.0
    var fetchedSleepData: [SleepData] = []
    
    @Published var workoutList: [WorkoutData] = []
    @Published var waterList: [WaterData] = []
    @Published var dietList: [DietData] = []
    @Published var test: String = "hello"
    let root = Database.database().reference()
    
    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    
    //Sleep Data on firebase
    func addSleepData(newEntry: SleepData) {
        do {
            let jsonData = try JSONEncoder().encode(newEntry)
            if let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                let dateString = formattedDate(from: newEntry.date)
                root.child("sleep").child(dateString).child(newEntry.id.uuidString).setValue(json)
            }
        } catch {
            print("Error encoding SleepData: \(error)")
        }
    }

    
    func deleteSleepData(withID id: UUID, for date: Date) {
        let dateString = formattedDate(from: date) // Assuming you have a method to get formatted date string
        let dataRef = root.child("sleep").child(dateString).child(id.uuidString)

        dataRef.removeValue { (error, _) in
            if let error = error {
                print("Error deleting sleep data: \(error)")
            } else {
                print("Successfully deleted sleep data with ID: \(id.uuidString)")
            }
        }
    }
    
    func fetchSleepData(for date: Date, completion: @escaping ([SleepData]) -> Void) {
        let dateString = formattedDate(from: date)
        root.child("sleep").child(dateString).getData { (error, snapshot) in
            if let error = error {
                print("Error getting sleep data: \(error)")
                completion([])
                return
            }

            guard let dataDictionary = snapshot?.value as? [String: Any] else {
                print("No data or unexpected data format for date: \(dateString)")
                completion([])
                return
            }

            var sleepDataArray: [SleepData] = []

            for (_, value) in dataDictionary {
                if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []),
                   let sleepData = try? JSONDecoder().decode(SleepData.self, from: jsonData) {
                    sleepDataArray.append(sleepData)
                }
            }

            completion(sleepDataArray)
        }
    }

        
    func getSleepHours(for date: Date, completion: ((Double) -> Void)? = nil) {
        fetchSleepData(for: date) { sleepData in
            let totalDuration = sleepData.reduce(0) { $0 + $1.duration }
            DispatchQueue.main.async {
                self.sleepHours = totalDuration
                completion?(totalDuration)
            }
        }
    }

    func getSleepEntriesDateDefault(for date: Date, completion: @escaping ([SleepData]) -> Void) {
        fetchSleepData(for: date) { fetchedData in
            DispatchQueue.main.async {
                if fetchedData.isEmpty {
                    let defaultData = [SleepData(date: date, startTime: Date.now, endTime: Date.now)]
                    self.sleepList = defaultData  // Update the sleepList with default data
                    completion(defaultData)
                } else {
                    self.sleepList = fetchedData  // Update the sleepList with fetched data
                    completion(fetchedData)
                }
            }
        }
    }


    func getSleepEntriesDate(for date: Date, completion: @escaping ([SleepData]) -> Void) {
        fetchSleepData(for: date) { fetchedData in
            DispatchQueue.main.async {
                self.sleepList = fetchedData  // Here's the update to sleepList
                completion(fetchedData)
            }
        }
    }

    // rest data
    func addWorkoutData(newEntry: WorkoutData) {
        workoutList.append(newEntry)
        do {
                let jsonData = try JSONEncoder().encode(newEntry)
                if let json = String(data: jsonData, encoding: .utf8) {
                    let dateString = formattedDate(from: newEntry.date)
                    root.child("workout").child(dateString).setValue(json)
                }
            } catch {
                print("Error encoding SleepData: \(error)")
            }
    }
    
    func addWaterList(newEntry: WaterData) {
        waterList.append(newEntry)
        do {
                let jsonData = try JSONEncoder().encode(newEntry)
                if let json = String(data: jsonData, encoding: .utf8) {
                    let dateString = formattedDate(from: newEntry.date)
                    root.child("water").child(dateString).setValue(json)
                }
            } catch {
                print("Error encoding SleepData: \(error)")
            }
    }
    
    func addDietList(newEntry: DietData) {
        dietList.append(newEntry)
        do {
                let jsonData = try JSONEncoder().encode(newEntry)
                if let json = String(data: jsonData, encoding: .utf8) {
                    let dateString = formattedDate(from: newEntry.date)
                    root.child("diet").child(dateString).setValue(json)
                }
            } catch {
                print("Error encoding SleepData: \(error)")
            }
    }

    
    func getMealCalorie(date:Date) -> Int {
        var totalCalories = 0
        
        for dietData in dietList {
            if Calendar.current.isDate(dietData.date, equalTo: date, toGranularity: .day) {
                totalCalories += dietData.data
            }
        }
        return totalCalories
    }
    
    // Use get data for history view (put waterList, workoutList, or dietList for dataList)
    // Similar to the sleep function: getSleepHours
    static func getDataForDate(date: Date, dataList: [CountableData]) -> Int {
        return dataList.filter { entry in
            return Calendar.current.isDate(entry.date, inSameDayAs: date)
        }.reduce(0,  {x,y in x + y.data})
    }
    
    // Use to get data for graphs for water data
    // Similar to the sleep function: getSleepEntriesDateDefault
    func getWaterEntriesDateDefault(date: Date) -> [WaterData] {
        let result = waterList.filter { entry in
            return Calendar.current.isDate(entry.date, inSameDayAs: date)
        }
        if result.count == 0 {
            return [WaterData(date: date, data: 0)]
        } else {
            return result
        }
    }
    
    // Use to get data for graphs for workout data
    // Similar to the sleep function: getSleepEntriesDateDefault
    func getWorkoutEntriesDateDefault(date: Date) -> [WorkoutData] {
        let result = workoutList.filter { entry in
            return Calendar.current.isDate(entry.date, inSameDayAs: date)
        }
        if result.count == 0 {
            return [WorkoutData(date: date, type: "", data: 0)]
        } else {
            return result
        }
    }
    
    // Use to get data for graphs for diet data
    // Similar to the sleep function: getSleepEntriesDateDefault
    func getDietEntriesDateDefault(date: Date) -> [DietData] {
        let result = dietList.filter { entry in
            return Calendar.current.isDate(entry.date, inSameDayAs: date)
        }
        if result.count == 0 {
            return [DietData(date: date, type: MealType.snack, food: "", data: 0)]
        } else {
            return result
        }
    }
    
    // Use to get data for water entry logs
    // Similar to the sleep function: getSleepEntriesDate
    func getWaterEntriesDate(date: Date) -> [WaterData] {
        return waterList.filter { entry in
            return Calendar.current.isDate(entry.date, inSameDayAs: date)
        }
    }
    
    // Use to get data for workout entry logs
    // Similar to the sleep function: getSleepEntriesDate
    func getWorkoutEntriesDate(date: Date) -> [WorkoutData] {
        return workoutList.filter { entry in
            return Calendar.current.isDate(entry.date, inSameDayAs: date)
        }
    }
    
    // Use to get data for diet entry logs
    // Similar to the sleep function: getSleepEntriesDate
    func getDietEntriesDate(date: Date) -> [DietData] {
        return dietList.filter { entry in
            return Calendar.current.isDate(entry.date, inSameDayAs: date)
        }
    }
}


let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()

extension Date {
    func getDayBefore(num: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -num, to: self)!
    }
}

