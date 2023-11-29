//
//  TaskView.swift
//  SwiftUIConcurrencyWithAsyncAwait
//
//  Created by vivek sehrawat on 05/10/23.
//

import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async {
        do {
            guard let url = URL(string: "https://picsum.photos/200") else {
                return
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run(body: {
                self.image = UIImage(data: data)
            })
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/200") else {
                return
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run(body: {
                self.image2 = UIImage(data: data)
            })
        } catch  {
            print(error.localizedDescription)
        }
    }
}

struct TaskView: View {
    
    @StateObject private var vm = TaskViewModel()
    @State private var fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack(spacing: 40) {
            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image = vm.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        
        .onDisappear {
            /*
             @State private var fetchImageTask: Task<(), Never>? = nil
             To ensure the task can be cancelled when the view disappears, a reference to the task is saved and stored in the fetchImageTask variable. When the view is about to disappear, the cancel() method is called on the fetchImageTask object to cancel the task.
             */
            fetchImageTask?.cancel()
            
            /*
             if we use .task
             .task {
             await vm.fetchImage()
             }
             
             If the task is created using the .task modifier, there is no need to manually cancel the task. Swift will automatically cancel the task when it is no longer needed.
             
             However, it is important to note that cancelling the task does not immediately cancel the task. According to Apple's documentation, for long-running tasks for eg. we are in for loop, you should use try Task.checkCancellation() to check for cancellation periodically and stop the task when it is cancelled. This ensures that the task is safely cancelled and any resources it was using are freed up properly.
             
             According to aaple document we have to use
             try Task.checkCancellation()
             For long running task
             */
        }
        .onAppear {
            /*
             
             If you put vm.fetchImage() and vm.fetchImage2() calls in a single Task block like this:
             
             Task {
             await vm.fetchImage()
             await vm.fetchImage2()
             }
             the execution will suspend at the first task, and then the second task will execute. As a result, the first image will be displayed, and then after some time, the second image will be displayed. To resolve this issue and make both images appear simultaneously, you should create two separate Task blocks like this:
             
             Task {
             await vm.fetchImage()
             }
             
             Task {
             await vm.fetchImage2()
             }
             This will ensure that both tasks are executed simultaneously, and both images are displayed at the same time.
             */
            
            Task {
                await vm.fetchImage()
                await vm.fetchImage2()
            }
            
            /*
             these are the task priority
             which one finsih first, not fixed. System will optimize for us which will execute first.
             */
            
            Task(priority: .high) {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                // If we add Sleep then All task execte in front of high and this task execte in last or before background task.
                // We can use yield instead of sleep.
                /*
                 Output will be:
                 medium : <_NSMainThread: 0x600001708200>{number = 1, name = main} : TaskPriority.medium
                 userInitiated : <_NSMainThread: 0x600001708200>{number = 1, name = main} : TaskPriority.high
                 high : <_NSMainThread: 0x600001708200>{number = 1, name = main} : TaskPriority.high
                 low : <_NSMainThread: 0x600001708200>{number = 1, name = main} : TaskPriority.low
                 utility : <_NSMainThread: 0x600001708200>{number = 1, name = main} : TaskPriority.low
                 background : <_NSMainThread: 0x600001708200>{number = 1, name = main} : TaskPriority.background
                 */
                await Task.yield()
                print("high : \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .medium) {
                print("medium : \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .low) {
                print("low : \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .userInitiated) {
                print("userInitiated : \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .utility) {
                print("utility : \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .background) {
                print("background : \(Thread.current) : \(Task.currentPriority)")
            }
            
            Task(priority: .userInitiated) {
                /*
                 When a child task is created using the .task modifier, it gets the same priority as its parent task. This means that the child task will have the same priority as the task that created it. This can be useful in scenarios where you want to ensure that the child task has the same priority as the parent task.
                 
                 For example, if the parent task has a priority of .userInitiated, the child task will also have a priority of .userInitiated. This ensures that the child task is executed with the same priority as the parent task, which can be important for maintaining responsiveness and performance in your app.
                 
                 Output:
                 userInitiated : <_NSMainThread: 0x600001704040>{number = 1, name = main} : TaskPriority.high
                 Child task : <_NSMainThread: 0x600001704040>{number = 1, name = main} : TaskPriority.high
                 */
                print("userInitiated : \(Thread.current) : \(Task.currentPriority)")
                Task {
                    print("Child task : \(Thread.current) : \(Task.currentPriority)")
                }
                
                /*
                 If you need to specify a different priority for a child task than its parent, you can use the detached function. The detached function creates a new task that is not bound to its parent task's priority.
                 
                 Here's an example:
                 Output:
                 userInitiated : <_NSMainThread: 0x600001714200>{number = 1, name = main} : TaskPriority.high
                 detached : <NSThread: 0x6000017045c0>{number = 7, name = (null)} : TaskPriority.medium
                 
                 /// Don't use a detached task if it's possible, According to appple documentation
                 */
                Task(priority: .userInitiated) {
                    print("userInitiated : \(Thread.current) : \(Task.currentPriority)")
                    
                    Task.detached {
                        print("detached : \(Thread.current) : \(Task.currentPriority)")
                    }
                }
            }
        }
    }
}

#Preview {
    TaskView()
}
