//
//  SendableView.swift
//  SwiftUIConcurrencyWithAsyncAwait
//
//  Created by vivek sehrawat on 09/10/23.
//

import SwiftUI

/*
 Sendable and @Sendable, introduced in Swift 5.5, address the challenge of type-checking values passed between structured concurrency constructs and actor messages. This is particularly important for thread safety and preventing data races.

 Threads have their own stacks, but the heap is shared across all threads. Data race conditions can occur when two threads access the same object from the heap. To prevent data races, we can make a class thread-safe using Actors or DispatchQueues.

 However, if a thread-safe class uses a non-thread-safe class, the Sendable protocol comes into play. Consider the following example:

 func updateUserInfo() async {
     let info = "User info"
     await manager.updateDatabase(userInfo: info)
 }
 
 Passing a String to an actor class does not cause problems because strings are value types, making them Sendable by default.

 If we pass Struct to actor class
 
 Structs, being value types, are also thread-safe:

 struct MyUser {
     let name: String
 }
 
 Note that Sendable is not fully integrated into the compiler yet, so no warnings are currently issued. Future releases might include Sendable checks.

 Adding Sendable to a struct does not cause issues:

 struct MyUser: Sendable {
     let name: String
 }
 
 However, adding Sendable to a non-final class causes an error:

 class MyClassasInfo: Sendable // Error
 To resolve this, make the class final:

 final class MyClassasInfo: Sendable
 This works fine if the class has let properties, but not if they are mutable:

 final class MyClassasInfo: Sendable {
     var name: String // Error
 }
 
 To solve the problem, add @unchecked before Sendable:

 final class MyClassasInfo: @unchecked Sendable { }
 However, using @unchecked is dangerous because it tells the compiler not to check for Sendable conformance. It is the developer's responsibility to ensure thread safety, typically by using a DispatchQueue:

 final class MyClassasInfo: @unchecked Sendable {
     private var name: String
     let queue = DispatchQueue(label: "com.app.MyClass")
     
     init(name: String) {
         self.name = name
     }
     
     func updateName(newName: String) {
         queue.async {
             self.name = newName
         }
     }
 }
 This approach is not recommended. Instead, use a struct to pass data in actors and add the Sendable keyword to improve performance:

 struct MyUser: Sendable {
     var name: String
 }
 */


actor MyManager {
    
    func updateDatabase(userInfo: MyclassasInfo) {
        
    }
}

struct MyUser: Sendable {
    var name: String
}

final class MyclassasInfo: @unchecked Sendable {
    private var name: String
    let que = DispatchQueue(label: "com.app.MYclass")
    
    init(name: String) {
        self.name = name
    }
    
    func updateNme(newName: String) {
        que.async {
            self.name = newName
        }
    }
}

class SendableViewModel: ObservableObject {
    let manager = MyManager()
    
    func updateUserInfo() async {
        let info = MyclassasInfo(name: "name")
        await manager.updateDatabase(userInfo: info)
    }
}

struct SendableView: View {
    @StateObject private var vm = SendableViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .task {
                await vm.updateUserInfo()
            }
    }
}

#Preview {
    SendableView()
}
