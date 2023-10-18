//
//  ContentView.swift
//  LostInventoryMVVM
//
//  Created by macuser on 2023-10-18.
//

import SwiftUI


struct nextButton : View{
    var action: () -> ()
    var body : some View {
        Button(">", action: action)
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
    struct previousButton : View{
        var action: () -> ()
        var body : some View {
            Button("<", action: action)
                .padding()
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("Matthew's lost inventory system")
                .font(.largeTitle)
                .padding(.bottom, 30)
            
            HStack{
                VStack{
                    Text("Name Of Items")
                }
                Text("Sports played")
                
                
                Text("Object last seen")
                
                Text("Time")
                Spacer()
                
                
                
            }
            HStack{
                VStack{
                    Text("Item 1")
                        .padding(.trailing,20)
                    
                }
                Text("Soccer")
                    .padding(.trailing,60)
                ZStack{
                    Circle()
                        .frame(width:50, height:50)
                        .foregroundColor(.gray)
                      
                    Text("+")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                }
                .padding(.trailing,30)
                
                Text("Time")
                
                ZStack{
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.red)
                    Text("-")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
            }
            
            //
            HStack{
                VStack{
                    Text("Item 2")
                        .padding(.trailing,20)
                }
                Text("Soccer")
                    .padding(.trailing,60)
                ZStack{
                    Circle()
                        .frame(width:50, height:50)
                        .foregroundColor(.gray)
                      
                    Text("+")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                }
                .padding(.trailing,30)
                Text("Time")
                
                
                ZStack{
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.red)
                    Text("-")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                }
                Spacer()
                
            }
            HStack{
                VStack{
                    Text("Item 3")
                        .padding(.trailing,20)
                }
                Text("Soccer")
                    .padding(.trailing,60)
                
                ZStack{
                    Circle()
                        .frame(width:50, height:50)
                        .foregroundColor(.gray)
                      
                    Text("+")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                }
                .padding(.trailing,30)
                Text("Time")
                
                ZStack{
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.red)
                    Text("-")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                }
                Spacer()
                
            }
            
            //
            HStack{
                VStack{
                    Text("Item 4")
                        .padding(.trailing,20)
                }
                Text("Soccer")
                    .padding(.trailing,60)
                ZStack{
                    Circle()
                        .frame(width:50, height:50)
                        .foregroundColor(.gray)
                      
                    Text("+")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                }
                .padding(.trailing,30)
                Text("Time")
                
                
                ZStack{
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.red)
                    Text("-")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            
            //
            
            HStack{
                Text("Add Item")
                    .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.blue),
                    alignment: .top)
                
                Text("Object Found")
                    .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.blue),
                    alignment: .top)
               
                Spacer()
            }
            .padding()
        }
    }
}
    


    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
