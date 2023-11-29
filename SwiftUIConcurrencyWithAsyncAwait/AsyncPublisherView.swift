//
//  AsyncPublisherView.swift
//  SwiftUIConcurrencyWithAsyncAwait
//
//  Created by vivek sehrawat on 09/10/23.
//

import SwiftUI
import Combine
/*
 
 Before Async/Await was officially introduced in Swift, Combine was a popular choice for handling one-shot operations.

 Consider the following example with an AsyncPublisherDataManager class:
 
 class AsyncPublisherDataManager {
     @Published var fruitsArray: [String] = []
     
     func addFruits() async {
         fruitsArray.append("Apple")
         try? await Task.sleep(nanoseconds: 2_000_000_000)
         fruitsArray.append("Banana")
         try? await Task.sleep(nanoseconds: 2_000_000_000)
         fruitsArray.append("Orange")
         try? await Task.sleep(nanoseconds: 2_000_000_000)
         fruitsArray.append("Grapes")
         try? await Task.sleep(nanoseconds: 2_000_000_000)
         fruitsArray.append("Dates")
     }
 }
 
 And an AsyncPublisherViewModel:
 
 class AsyncPublisherViewModel: ObservableObject {
     @Published var dataArray: [String] = []
     var manager = AsyncPublisherDataManager()
     
     func start() async {
         await manager.addFruits()
     }
 }
 
 Question To get the fruits array data in the view model using Combine, create an init method and cancellables:
 
 var cancellables = Set<AnyCancellable>()
 init() {
     addSubscribers()
 }
 private func addSubscribers() {
     manager.$fruitsArray
         .receive(on: DispatchQueue.main)
         .sink { dataArray in
             self.dataArray = dataArray
         }
         .store(in: &cancellables)
 }
 
 Here in above code we added a subscriber.
 
 Now main part , how we can use or subscribe to this @published variable without combine or with async/await
 
 @Published var fruitsArray: [String] = [] without combine,
 
 Updated Code:
 
 In the above code, a subscriber is added. To use or subscribe to the @Published variable
 @Published var fruitsArray: [String] = []
 
 without Combine, update the code as follows:

 manager.$fruitsArray.values
 // Here, values is an AsyncPublisher and returns a publisher

 // This is not a normal for loop, which executes continuously.
 // This for loop waits for each value to come.
 for await value in manager.$fruitsArray.values { }
 
 
 
 Using .values, we can subscribe to the publisher.
 
 However, there is a problem: if there is an error in the for-await loop, code following the Task will not execute.
 
 
 Task {
     for await value in manager.$fruitsArray.values {
         await MainActor.run {
             self.dataArray = value
         }
     }
 }
 if we add task after that and if there is any error then after this task code will not get executed.
 
 Task {
         await MainActor.run {
             self.dataArray = ["Before]
         }
 }
 Task {
     for await value in manager.$fruitsArray.values {
         await MainActor.run {
             //self.dataArray = value
         }
     }
 }
 
 Task {
         await MainActor.run {
             self.dataArray = ["After]
         }
 }

 
 In the above code, "After" will not be executed if there is an error in for await value in manager.$fruitsArray.values. This is because it is listening to @Published var fruitsArray: [String] = [] and never knows when to stop.

 */

class AsyncPublisherDataManager {
    @Published var fruitsArray: [String] = []
    
    func addFruits() async {
        fruitsArray.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        fruitsArray.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        fruitsArray.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        fruitsArray.append("Grapes")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        fruitsArray.append("Dates")
    }
}

class AsyncPublisherViewModel: ObservableObject {
    @MainActor  @Published var dataArray: [String] = []
    var manager = AsyncPublisherDataManager()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
//        manager.$fruitsArray
//            .receive(on: DispatchQueue.main)
//            .sink { dataArray in
//                self.dataArray = dataArray
//            }
//            .store(in: &cancellables)
        
        //Changed to Async/await
        
        //Its not a normal foor loop, normal foor loop execute continuosly.
        // But this foor loop wait for each value to come.
        Task {
            for await value in manager.$fruitsArray.values {
                await MainActor.run {
                    self.dataArray = value
                }
            }
        }
        
        
    }
    
    func start() async {
        await manager.addFruits()
    }
}
struct AsyncPublisherView: View {
    @StateObject private var vm = AsyncPublisherViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(vm.dataArray, id: \.self) { element in
                    Text(element)
                        .font(.headline)
                }
            }
        }
        .task {
            await vm.start()
        }
    }
}

#Preview {
    AsyncPublisherView()
}
