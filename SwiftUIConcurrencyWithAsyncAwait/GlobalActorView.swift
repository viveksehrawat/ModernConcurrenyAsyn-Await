//
//  GlobalActorView.swift
//  SwiftUIConcurrencyWithAsyncAwait
//
//  Created by vivek sehrawat on 08/10/23.
//

import SwiftUI

/*
 In Simple application, we do not need Global actor.
 But in complex application for eg.
 GlobalActorViewModel method
 func getData() {
 //Suppose it is Heavy Complex method.
 }
 
 We are calling this method on main thread
 .task {
     await vm.getData()
 }
 
 In certain cases, executing heavy methods within tasks on the main actor or main thread can lead to performance issues.
 
 When we want nonisolated method in Actor class, we normally add nonisolated keyword to that method eg.
 
 nonisolated func getDataFromNetwork() -> [String] {
     return ["abc", "xyz", "hello"]
 }
 
 To address this, we can use the nonisolated keyword for non-async functions or variables within an actor class. Conversely, when requiring async functions in regular classes, we employ Global actors.
 
 To incorporate the async method func getData() async as part of the actor class "MyDataManager", a Global Actor is necessary. To make "MyDataManager" a Global Actor, create a shared instance of this actor outside the "MyDataManager" class.

 This can be achieved by creating a class or structure with the @globalActor keyword, such as:

 @globalActor struct MyFirstGlobalActor {
     static var shared = MyDataManager()
 }
 By adding the @MyFirstGlobalActor attribute, there's no need for the async keyword. This method now belongs to the "MyDataManager" Actor class. Consequently, the code can be modified from:

 func getData() async {
 }
 to

 func getData() {
 }
 This approach helps maintain efficiency and avoid occupying the main thread with heavy tasks.
 */

@globalActor
struct MYFirstGlobalActor {
    /*
     To utilize the "MyDataManager" Actor, it is essential to access the shared instance of the global actor instead of directly using "MyDataManager." This ensures a more efficient and accurate implementation.
     Do not use "MyDataManager" directaly or create more instance.
     
     */
    static var shared = MyDataManager()
}

actor MyDataManager {
    
    func getDataFromNetwork() -> [String] {
        return ["abc", "xyz", "hello"]
    }
}

class GlobalActorViewModel: ObservableObject {
    @MainActor @Published var stringArray: [String] = []
//    let manager = MyDataManager()
    let manager = MYFirstGlobalActor.shared
    
    @MYFirstGlobalActor
    func getData() {
        Task {
            let data = await manager.getDataFromNetwork()
            await MainActor.run {
                self.stringArray = data
            }
        }
    }
}
/*
 The @MainActor attribute functions similarly to the custom "@MyFirstGlobalActor". When you want a method to run on the main thread, simply add @MainActor:

 @MainActor
 func getData() async {
 }
 The following line impacts the UI and may not show a compile-time error:

 stringArray = await manager.getDataFromNetwork()
 However, when running the app, you might receive a warning indicating that it's not running on the main thread. To resolve this issue, add @MainActor in front of @Published:

 @MainActor @Published var stringArray: [String] = []
 Now, you'll receive a compile-time error:

 Main actor-isolated property 'stringArray' cannot be mutated from global actor 'MyFirstGlobalActor'
 To update the code accordingly:

 Task {
     let data = await manager.getDataFromNetwork()
     await MainActor.run {
         self.stringArray = data
     }
 }
 If all variables require the Main actor, you might need to add @MainActor to each:

 @MainActor @Published var stringArray1: [String] = []
 @MainActor @Published var stringArray2: [String] = []
 @MainActor @Published var stringArray3: [String] = []
 In such cases, it's a better solution to mark the entire class with @MainActor:

 @MainActor class GlobalActorViewModel: ObservableObject { }
 This approach ensures that all properties and methods within the class run on the main thread.
 */

struct GlobalActorView: View {
    @StateObject private var vm = GlobalActorViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(vm.stringArray, id: \.self) { element in
                    Text(element)
                        .font(.headline)
                }
            }
        }
        .task {
            await vm.getData()
        }
    }
}

#Preview {
    GlobalActorView()
}
