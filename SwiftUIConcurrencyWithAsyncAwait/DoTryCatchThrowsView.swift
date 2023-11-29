//
//  DoTryCatchThrowsView.swift
//  SwiftUIConcurrencyWithAsyncAwait
//
//  Created by vivek sehrawat on 04/10/23.
//

import SwiftUI

class DoTryCatchThrowsManager {
    let isActive: Bool = false
    
    func getTitle() -> String? {
        if isActive {
            return "New Text!"
        } else {
            return nil
        }
    }
    
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("Get Title 2!")
        } else {
            return .failure(URLError(.badURL))
        }
    }
    
    func getTitle3() throws ->  String {
        if isActive {
            return "Get title 3!!"
        } else {
            throw URLError(.badURL)
        }
    }
}
class DoTryCatchThrowsViewModel: ObservableObject {
    @Published var title: String = "Starting text"
    let manager = DoTryCatchThrowsManager()
    
    
    func fetchTitle() {
        //Simple Call
        //        let newTitle = manager.getTitle()
        //        self.title = newTitle
        
        //Call With Result variable
        let result = manager.getTitle2()
        switch result {
        case .success(let newTitle):
            self.title = newTitle
        case .failure(let error):
            self.title = error.localizedDescription
        }
        
        //With do, try, catch , throws
        do {
            let newTitle = try manager.getTitle3()
            self.title = newTitle
        } catch let error {
            self.title = error.localizedDescription
        }
    }
    
    
    
}

struct DoTryCatchThrowsView: View {
    @StateObject private var vm =  DoTryCatchThrowsViewModel()
    var body: some View {
        VStack {
            Text(vm.title)
                .frame(width: 300, height: 300)
                .background(.blue)
                .onTapGesture {
                    vm.fetchTitle()
                }
        }
        .padding()
    }
}

struct DoTryCatchThrowsView_Previews: PreviewProvider {
    static var previews: some View {
        DoTryCatchThrowsView()
    }
}
