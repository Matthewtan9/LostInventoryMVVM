// FrontPageView.swift
import SwiftUI

struct FrontPageView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                Group {
                    Text("Welcome to Lost Inventory System")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                // Image
                Group {
                    Image("lostandfound")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .padding()
                }

                // Explore Inventory Button
                Group {
                    NavigationLink(destination: ContentView()) {
                        CustomButton(text: "Explore Inventory", color: .blue)
                    }
                    .padding(.top, 20)
                }

                // Description Button
                Group {
                    NavigationLink(destination: DescriptionView()) {
                        CustomButton(text: "Description", color: .green)
                    }
                    .padding(.top, 20)
                }

                Spacer()
            }
            .padding()
            .navigationBarTitle("Home Page", displayMode: .inline)
        }
    }
}

struct CustomButton: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.headline)
            .frame(width: 200, height: 50)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

// DescriptionView.swift
struct DescriptionView: View {
    var body: some View {
        VStack {
            // Description Text
            Group {
                Text("Lost Inventory System Description")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()

                Text(descriptionContent)
                    .multilineTextAlignment(.leading)
                    .padding()

                Spacer()
            }

            // Thank You Text
            Group {
                Text("Thank you for your collaboration!")
            }

            Spacer()
        }
        .padding()
        .navigationBarTitle("Description", displayMode: .inline)
    }

    private var descriptionContent: String {
        """
        The lost inventory system for the park helps the owner keep track of rented equipment lost on the fields, like soccer and basketball. Visitors and staff can report lost or found items with details such as descriptions and locations. It makes it easier to find lost items and notifies users when something is found. The system streamlines the process, making it more organized and efficient for both visitors and park management.
        """
    }
}

struct FrontPageView_Previews: PreviewProvider {
    static var previews: some View {
        FrontPageView()
    }
}
