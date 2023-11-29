//
//  AsyncLetView.swift
//  SwiftUIConcurrencyWithAsyncAwait
//
//  Created by vivek sehrawat on 06/10/23.
//

import SwiftUI

struct AsyncLetView: View {
    @State private var images: [UIImage] = []
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/200")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, content: {
                    ForEach(images, id: \.self, content: { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                    })
                })
            }
            .navigationTitle("Async Let Learning")
            .onAppear {
                //self.images.append(UIImage(systemName: "heart.fill")!)
                Task {
                    do {
                        /*
                         When fetching images sequentially in a single task, the same issue occurs as the code runs synchronously. This results in the first image appearing before the second, and so on. To address this problem, we should create separate tasks for each image retrieval operation.
                         */
                        
//                        let image1 = try await fetchImage()
//                        self.images.append(image1)
//                        
//                        let image2 = try await fetchImage()
//                        self.images.append(image2)
//                        
//                        let image3 = try await fetchImage()
//                        self.images.append(image3)
//                        
//                        let image4 = try await fetchImage()
//                        self.images.append(image4)
                        
                        /*
                         To address the aforementioned issue, we can employ async let. However, this approach is not scalable and works best for limited scenarios, such as initiating 2-3 calls at the beginning of a screen or downloading 2-3 images. For downloading larger numbers of images (e.g., 50+), this method is not recommended, and a more scalable solution should be considered.
                         */
                        async let fetchimage1 = fetchImage()
                        async let fetchimage2 = fetchImage()
                        async let fetchimage3 = fetchImage()
                        async let fetchimage4 = fetchImage()
                        
                        let (image1, image2, image3, image4) = await (try fetchimage1, try fetchimage2, try fetchimage3, try fetchimage4)
                        self.images.append(contentsOf: [image1,image2,image3,image4])
                        
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func fetchImage() async throws -> UIImage {
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

#Preview {
    AsyncLetView()
}
