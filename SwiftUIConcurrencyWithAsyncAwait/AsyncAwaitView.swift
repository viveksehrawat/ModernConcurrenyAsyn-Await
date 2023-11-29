//
//  AsyncAwaitView.swift
//  SwiftUIConcurrencyWithAsyncAwait
//
//  Created by vivek sehrawat on 05/10/23.
//

import SwiftUI

class AsyncAwaitViewModel: ObservableObject {
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("Title1 : \(Thread.current)")
        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title2 = "Title2 : \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArray.append(title2)
                
                let title3 = "Title3 : \(Thread.current)"
                self.dataArray.append(title3)
            }
        }
    }
    
    func addAuthor() async {
        let author1 = "Author1 : \(Thread.current)"
        self.dataArray.append(author1)
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2 = "Author2 : \(Thread.current)"
        await MainActor.run(body: {
            self.dataArray.append(author2)
        })
    }
}

struct AsyncAwaitView: View {
    @StateObject private var vm = AsyncAwaitViewModel()
    
    var body: some View {
        List(vm.dataArray, id: \.self) { data in
            Text(data)
        }
        .onAppear {
            Task {
                await vm.addAuthor()
            }
//            vm.addTitle1()
//            vm.addTitle2()
        }
    }
}

#Preview {
    AsyncAwaitView()
}
