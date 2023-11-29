//
//  CheckedContinuationView.swift
//  SwiftUIConcurrencyWithAsyncAwait
//
//  Created by vivek sehrawat on 06/10/23.
//

import SwiftUI
class CheckedContinuationNetworkManger {
    
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw error
        }
    }
    /*
    In this method, executing the withCheckedThrowingContinuation line will call the continuation and pause/suspend the task. It then leaves the async task and proceeds to the URLSession.shared.dataTask code, which is not async. Once the data task is completed, the async task will continue/resume from where it left off with the line continuation.resume(returning: data).

     According to Apple's documentation, the closure's body executes synchronously on the calling task, and once it returns, the calling task is suspended. The task can be resumed immediately, or the continuation can be escaped to complete it afterward, which will then resume the suspended task. If resume(throwing:) is called on the continuation, this function will throw that error.
     
     if we write like this:
     if let data = data {
         continuation.resume(returning: data)
     }
     continuation.resume(throwing: URLError(.badURL))

     The continuation's resume method must be invoked exactly once. Failing to do so will cause the calling task to remain suspended indefinitely, resulting in the task hanging and being leaked with no possibility of destruction. The checked continuation provides detection of misuse, and dropping the last reference to it without resuming will trigger a warning. Resuming a continuation twice will also be diagnosed and cause a crash.

     This means that the continuation must be called only once to avoid crashing the app. For example:
     
     */
    
    func getData2(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url, completionHandler: {data,response,error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
                // In the code above, the continuation is called safely once to avoid crashes, as per Apple's documentation.
            })
            .resume()
        }
    }
    
    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage) -> Void)  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            completionHandler(UIImage(systemName: "heart.fill")!)
        })
    }
    
    //Change old written code into Async Code
    func getHeartImageFromDatabase() async -> UIImage {
        await withCheckedContinuation { continuation in
            getHeartImageFromDatabase(completionHandler: { image in
                continuation.resume(returning: image)
            })
        }
    }
    
}

class CheckedContinuationViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let networkManager = CheckedContinuationNetworkManger()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/200") else {
            return
        }
        do {
            let data = try await networkManager.getData2(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run(body: {
                    self.image = image
                })
            }
        } catch  {
            print(error)
        }
    }
    
    func getHeartImage() async {
        self.image = await networkManager.getHeartImageFromDatabase()
    }
}

struct CheckedContinuationView: View {
    @StateObject private var vm = CheckedContinuationViewModel()
    
    var body: some View {
        ZStack {
            if let image =  vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await vm.getImage()
        }
    }
}

#Preview {
    CheckedContinuationView()
}
