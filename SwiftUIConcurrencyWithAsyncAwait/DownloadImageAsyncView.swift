//
//  DownloadImageAsyncView.swift
//  SwiftUIConcurrencyWithAsyncAwait
//
//  Created by vivek sehrawat on 04/10/23.
//

import SwiftUI
import Combine

class DownloadImageAsyncImageLoader {
    
    let url = URL(string: "https://picsum.photos/200")!
    
    /// Handles the response data and returns a UIImage if successful.
    /// - Parameters:
    ///   - data: The downloaded data.
    ///   - response: The URL response.
    /// - Returns: A UIImage if the response is successful, otherwise nil.
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }
    
    /// Downloads an image using a completion handler with escaping closure.
    /// - Parameter completionHandler: A closure to be executed with the downloaded image or an error.
    func downloadWithEscaping(completionHandler: @escaping (_ image: UIImage?,_ error: Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            completionHandler(image, nil)
        }
        .resume()
    }
    
    /// Downloads an image using Combine and returns a publisher.
    /// - Returns: A Combine publisher for downloading an image.
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError( { $0 })
            .eraseToAnyPublisher()
    }
    
    /// Downloads an image asynchronously using async/await and returns a UIImage.
    /// - Returns: A UIImage if the download is successful, otherwise an error is thrown.
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
}

class DownloadImageAsyncViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    var loader = DownloadImageAsyncImageLoader()
    var cancellable = Set<AnyCancellable>()
    
    func fetchImage() async {
        //Direct allocation
        //self.image = UIImage(systemName: "heart.fill")
        
        //Download with Escaping closure
        //        loader.downloadWithEscaping { [weak self] image,error in
        //            //Main thread issue
        //            /*
        //            if let image = image {
        //                self?.image = image
        //            } else {
        //                self?.image = UIImage(systemName: "heart.fill")
        //            }
        //             */
        //            DispatchQueue.main.async {
        //                self?.image = image
        //            }
        
        //Download image with Combine
        //        loader.downloadWithCombine()
        //            .sink { _ in
        //
        //            } receiveValue: { [weak self] image in
        //                DispatchQueue.main.async {
        //                    self?.image = image
        //                }
        //            }
        //            .store(in: &cancellable)
        
//        loader.downloadWithCombine()
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: {_ in
//
//            }, receiveValue: { [weak self] image in
//                self?.image = image
//            })
//            .store(in: &cancellable)
        
        //Download image with async/Await
        let image = try? await loader.downloadWithAsync()
        // background thread issue if we use directly use main actor when using async
//        self.image = image
        await MainActor.run{
            self.image = image
        }
       
    }
}
struct DownloadImageAsyncView: View {
    @StateObject var vm = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250,height: 250)
            }
        }
        .onAppear {
            Task {
                await vm.fetchImage()
            }
            
        }
    }
}

struct DownloadImageAsyncView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageAsyncView()
    }
}
