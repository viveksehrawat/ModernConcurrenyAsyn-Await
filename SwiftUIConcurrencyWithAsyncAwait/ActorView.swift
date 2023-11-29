//
//  ActorView.swift
//  SwiftUIConcurrencyWithAsyncAwait
//
//  Created by vivek sehrawat on 08/10/23.
//

import SwiftUI

class MydataManager {
    static let shared = MydataManager()
    private init() { }
    var data: [String] = []
    /*
     If an issue arises when calling the getRandom function using different threads, a custom Queue is required to resolve the problem. The code will function correctly when a Custom Queue is created. However, the Actor will perform the same tasks automatically, eliminating the need for a completion handler to address thread-related issues.
     */
    private let myQue = DispatchQueue(label: "com.actor.DataManager")
    
//    func getRandomData() -> String? {
//        self.data.append(UUID().uuidString)
//        print(Thread.current)
//        return data.randomElement()
//    }
    
    // The above method works if we run on a single thread
    // To solve multi-threading issues, add the code to the queue created previously
    func getRandomData(completionHandler: @escaping (_ title: String?) -> Void) {
        // Execute the following code asynchronously on the custom queue (myQue)
        myQue.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
        }
        
    }
}

/*
 Advantages of using Actor:

The code becomes cleaner and more streamlined compared to the non-actor class implementation.
There is no need to utilize completion handlers within the app.
*/

actor MyActordataManager {
    static let shared = MyActordataManager()
    private init() { }
    var data: [String] = []
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return data.randomElement()
    }
    
    /*
     In cases where certain parts of the code within our Actor do not require isolation for any specific reason, the 'nonisolated' keyword can be used.
     After that there is no need to use await keyword to call this method.
    */
    nonisolated
    func getNewData() -> String {
        return "New data"
    }
    
}

struct HomeView: View {
//    let manager = MydataManager.shared
    let manager = MyActordataManager.shared
    
    @State var text: String = ""
    let timer = Timer.publish(every: 0.1, tolerance: nil, on:  .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onReceive(timer, perform: { _ in
//            if let number = manager.getRandomData() {
//                self.text = number
//            }
            
            //If the timer operates on the main thread, no issues arise. However, when switching to another thread, thread-related issues may occur.
            
            
            /*
             The HomeView and AccountView both utilize the MyDataManager class to retrieve data. Since classes are not inherently thread-safe, issues may arise when multiple threads access the same class concurrently. To resolve this problem without using Actors, create a custom queue for managing the data access.
             */
            
            /*
             WARNING: ThreadSanitizer: Swift access race (pid=88519)
               Modifying access of Swift variable at 0x00011205ced0 by thread T3:
                 #0 SwiftUIConcurrencyWithAsyncAwait.MydataManager.data.modify :
             
             SUMMARY: ThreadSanitizer: Swift access race
             */
            
            
//            DispatchQueue.global(qos: .background).async {
//                if let number = manager.getRandomData() {
//                    DispatchQueue.main.async {
//                        self.text = number
//                    }
//                }
//            }
            
            /*
             After Using this there is no error and Warning from ThreadSanitizer
             In below code
             */
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let number = title {
//                        DispatchQueue.main.async {
//                            self.text = number
//                        }
//                    }
//                }
//            }
            
            Task {
                if let title = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = title
                    }
                }
            }
        })
    }
}

struct AccountView: View {
//    let manager = MydataManager.shared
    
    let manager = MyActordataManager.shared
    
    
    @State var text: String = ""
    let timer = Timer.publish(every: 0.01, tolerance: nil, on:  .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onReceive(timer, perform: { _ in
//            if let number = manager.getRandomData() {
//                self.text = number
//            }
//            DispatchQueue.global(qos: .default).async {
//                if let number = manager.getRandomData() {
//                    DispatchQueue.main.async {
//                        self.text = number
//                    }
//                }
//            }
            
            
            
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let number = title {
//                        DispatchQueue.main.async {
//                            self.text = number
//                        }
//                    }
//                }
//            }
            
            
            Task {
                if let title = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = title
                    }
                }
            }

            
            
        })
    }
}

struct ActorView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle.fill")
                }
        }
        
    }
}

#Preview {
    ActorView()
}
