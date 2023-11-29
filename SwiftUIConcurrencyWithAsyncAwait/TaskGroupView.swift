//
//  TaskGroupView.swift
//  SwiftUIConcurrencyWithAsyncAwait
//
//  Created by vivek sehrawat on 06/10/23.
//

import SwiftUI

class TaskGroupDataManager {
    
    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        do {
            /*
             This approach is not scalable and works best for limited scenarios, such as initiating 2-3 calls at the beginning of a screen or downloading 2-3 images. For downloading larger numbers of images (e.g., 50+), this method is not recommended.
             */
            async let fetchimage1 = fetchImage(urlString: "https://picsum.photos/200")
            async let fetchimage2 = fetchImage(urlString: "https://picsum.photos/200")
            async let fetchimage3 = fetchImage(urlString: "https://picsum.photos/200")
            async let fetchimage4 = fetchImage(urlString: "https://picsum.photos/200")
            
            let (image1, image2, image3, image4) = await (try fetchimage1, try fetchimage2, try fetchimage3, try fetchimage4)
            return [image1,image2,image3,image4]
        } catch {
           throw error
        }
    }
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        let urlStrings = [ "https://picsum.photos/200",
                           "https://picsum.photos/200",
                           "https://picsum.photos/200"
        ]
        /*
         When working with multiple tasks, it is essential to use Task Groups. Task Groups provide a way to manage and organize the concurrent execution of tasks. There are two primary options for creating Task Groups:

         withTaskGroup
         withThrowingTaskGroup
         The option you choose depends on whether the function you are calling is throwing or not.

         1. withTaskGroup
         Use withTaskGroup when the function you are calling does not throw errors. The syntax for creating a Task Group using withTaskGroup is as follows:

         withTaskGroup(of: <#T##Sendable.Protocol#>) { group in
             // Add tasks to the group
         }
         Here, the first parameter of is the type of the Child task's return type, conforming to the Sendable protocol.

         2. withThrowingTaskGroup
         Use withThrowingTaskGroup when the function you are calling throws errors. The syntax for creating a Task Group using withThrowingTaskGroup is as follows:

         try withThrowingTaskGroup(of: <#T##Sendable.Protocol#>) { group in
             // Add tasks to the group
         }
         Similar to withTaskGroup, the first parameter of is the type of the Child task's return type, conforming to the Sendable protocol.

         By using Task Groups, you can effectively manage and handle multiple tasks, ensuring a more organized and efficient execution of your concurrent code.
         
         */
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            
            var images: [UIImage] = []
            
            // Reserve Capacity for Improved Performance:

            // When working with a collection like 'images', using 'reserveCapacity'
            // can significantly enhance performance when you know the expected size
            // of the collection in advance.

            // In this case, we are reserving capacity in the 'images' collection
            // based on the number of URLs in the 'urlStrings' array. This can help
            // avoid frequent reallocations of memory as elements are added to the
            // collection, leading to improved execution speed.

            images.reserveCapacity(urlStrings.count)
            
            /**
             Adds a task to the concurrent group with optional priority and return type.

             - Parameters:
                - priority: An optional parameter to specify the priority of the task. By default, the task inherits the priority of the parent group.
                - task: An asynchronous task that returns a UIImage. The return type is determined by the type declared in the group, in this case, UIImage.self.

             - Returns: A task handle representing the added task.

             Normally, specifying a priority for the task is not necessary, as it will inherit the same priority as the parent group.

             The second option, 'task', is a closure of type '() async throws -> UIImage'. It is expected to perform an asynchronous operation and return a UIImage. The return type conforms to the type declared for the group, which, in this case, is UIImage.self. This ensures that the result of the task matches the expected type for the group.
             
             addTask has two options priorty and operation.
             Normally we do not need to give priorty because it will take same priorty the Parent has.
             
             Second option has
             T##() async throws -> UIImage
             
             it return UIImage because we decalred in group UIImage.self
             */

            group.addTask(operation: {
                try await self.fetchImage(urlString: "https://picsum.photos/200")
            })
            group.addTask {
                try await self.fetchImage(urlString: "https://picsum.photos/200")
            }
            group.addTask {
                try await self.fetchImage(urlString: "https://picsum.photos/200")
            }
            group.addTask {
                try await self.fetchImage(urlString: "https://picsum.photos/200")
            }
            /*
             More Cleaner way to add task, we noramlly do in our project
             It's advisable to design tasks to handle their own errors gracefully. By not making 'try' optional, a single failure among multiple tasks won't propagate an error for the entire group. Instead, individual tasks can gracefully handle errors, ensuring that a single failure doesn't disrupt the entire operation.
             */
            for urlString in urlStrings {
                group.addTask(operation: {
                    try? await self.fetchImage(urlString: urlString)
                })
            }
            /*
             This for loop is designed to wait for each operation to complete before proceeding.
             We use 'try await' after the 'for' keyword to await the result of each operation in the group.
             The tasks within the group can complete in any order, and we await their results here.
             When all tasks have completed, 'taskResult' holds a value.

             It's important to note that this is not a typical for loop. Instead, it waits for each task to return a result individually.
             Theoretically, if one task never returns to our app, we will wait indefinitely, or until it fails or times out.

             */
            for try await taskResult in group {
                if let image = taskResult {
                    images.append(image)
                }
            }
            
            return images
        }
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}

class TaskGroupViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    let manager = TaskGroupDataManager()
    
    func getImages() async {
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            self.images.append(contentsOf: images)
        }
    }
}

struct TaskGroupView: View {
    @StateObject private var vm = TaskGroupViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, content: {
                    ForEach(vm.images, id: \.self, content: { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                    })
                })
            }
        }
        .task {
            await vm.getImages()
        }
    }
}

#Preview {
    TaskGroupView()
}
