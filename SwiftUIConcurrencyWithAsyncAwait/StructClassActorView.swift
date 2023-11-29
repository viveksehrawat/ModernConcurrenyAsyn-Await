//
//  StructClassActorView.swift
//  SwiftUIConcurrencyWithAsyncAwait
//
//  Created by vivek sehrawat on 08/10/23.
//

import SwiftUI

/*
 
 Links:
 -
 - https://stackoverflow.com/questions/24217586/structure-vs-class-in-swift-language
 - https://medium.com/@vinayakkini/swift-basics-struct-vs-class-31b44ade28ae
 - https://stackoverflow.com/questions/24217586/structure-vs-class-in-swift-language/59219141#59219141
 - https://stackoverflow.com/questions/27441456/swift-stack-and-heap-understanding
 - https://stackoverflow.com/questions/24232799/why-choose-struct-over-class/24232845
 - https://www.backblaze.com/blog/whats-the-diff-programs-processes-and-threads/
 - https://medium.com/doyeona/automatic-reference-counting-in-swift-arc-weak-strong-unowned-925f802c1b99

 
VALUE TYPES:
 - Struct, Enum, String, Int, etc
 - Stored in the stack
 - Faster
 - Thread safe!, Because each thread has its own stack.
 - When you assign or pass value type a new copy of data is created
 
 
REFRENCE TYPES:
 - Class, Function, Actor
 - Stored in Heap
 - Slower, But Synchorinzed
 - Not thread safe
 - When you assign or pass refrence type a new refrence to original instance will be created(pointer)
 
STACK:
 - Stores value types
 - Variables allocated on he stack are stored directly to the memory, and access to this memory is very fast.
 - Each thread has its own stack

HEAP:
 - Stores refrence type
 - shared accross threads!
 
 
Struct:
 - Based on values
 - can be mutated
 - Stored in the stack
 
Class:
 - Based on refrences(Instances)
 - Stored in the heap
 - inherit from other classes
 
Actor:
 - Same as classes, But thread safe.
 
 Where we have to use Struct, Classes And Actor?
 Struct - Data Models, views
 Classes - ViewModels
 Actor - Shared "Managers" and "Data Stores"
 
 */



struct StructClassActorView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
                runTest()
            }
    }
    
}

#Preview {
    StructClassActorView()
}

extension StructClassActorView {
    func runTest() {
        print("Test Started!")
    }
}
