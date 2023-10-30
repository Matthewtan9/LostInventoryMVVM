import SwiftUI

struct InventoryItem: Identifiable {
    var id = UUID()
    var name: String
    var sport: String
    var image: UIImage?
    var timeLastSeen: String
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = InventoryViewModel()
    @State private var isAddItemViewPresented: Bool = false
    @State private var isDeleteItemViewPresented: Bool = false
    @State private var currentItemForImagePicker: InventoryItem?

    var body: some View {
        NavigationView {
            List {
                Section(header: VStack(spacing: 50) {
                    Text("Matthew's lost inventory system")
                        .font(.headline)
                        .padding(.top, 100)

                    HStack {
                        Text("Name Of Items").bold()
                        Spacer()
                        Text("Sports played").bold()
                        Spacer()
                        Text("Object last seen").bold()
                        Spacer()
                        Text("Time last seen").bold()
                    }
                    .padding(.horizontal, 10)
                }) {
                    
                    ForEach(viewModel.items.indices, id: \.self) { index in
                        HStack {
                            Text(viewModel.items[index].name)
                                .frame(width: 60, alignment: .leading)
                            Spacer()
                            Text(viewModel.items[index].sport)
                                .frame(width: 60, alignment: .leading)
                            Spacer()
                            Button(action: {
                                currentItemForImagePicker = viewModel.items[index]
                            }) {
                                if let image = viewModel.items[index].image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color.gray.opacity(0.7))
                                }
                            }
                            .sheet(item: $currentItemForImagePicker, onDismiss: {
                                currentItemForImagePicker = nil
                            }) { item in
                                ImagePicker(selectedImage: Binding(
                                    get: { item.image },
                                    set: { newImage in
                                        if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                                            viewModel.items[index].image = newImage
                                        }
                                    }
                                ))
                            }
                            
                            Spacer()
                            Text(viewModel.items[index].timeLastSeen)
                                .frame(width: 90, alignment: .center)
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete(perform: deleteItems)
                }
                
                Section {
                    Button(action: {
                        isAddItemViewPresented.toggle()
                    }) {
                        HStack {
                            Spacer()
                            Text("Add Item")
                                .font(.title2)
                                .padding()
                                .background(Color.green.opacity(0.3))
                                .cornerRadius(10)
                            Spacer()
                        }
                    }
                    .sheet(isPresented: $isAddItemViewPresented) {
                        AddItemView(items: $viewModel.items)
                    }

                    Button(action: {
                        isDeleteItemViewPresented.toggle()
                    }) {
                        HStack {
                            Spacer()
                            Text("Delete Item")
                                .font(.title2)
                                .padding()
                                .background(Color.red.opacity(0.3))
                                .cornerRadius(10)
                            Spacer()
                        }
                    }
                    .sheet(isPresented: $isDeleteItemViewPresented) {
                        DeleteItemView(items: $viewModel.items)
                    }
                    Button(action: {
                        isDeleteItemViewPresented.toggle()
                    }) {
                        HStack {
                            Spacer()
                            Text("Object found")
                                .font(.title2)
                                .padding()
                                .background(Color.red.opacity(0.3))
                                .cornerRadius(10)
                            Spacer()
                        }
                    }
                    .sheet(isPresented: $isDeleteItemViewPresented) {
                        DeleteItemView(items: $viewModel.items)
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }
    }
    
    
    func deleteItems(at offsets: IndexSet) {
        viewModel.items.remove(atOffsets: offsets)
    }
}

struct DeleteItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var items: [InventoryItem]
    @State private var selectedItem: InventoryItem?
    @State private var showDeleteAlert: Bool = false

    var body: some View {
        VStack {
            Text("...")
                .font(.title)
                
        }
            Text("Delete an Item")
                .font(.headline)
                .padding()

            List {
                ForEach(items) { item in
                    Button(action: {
                        self.selectedItem = item
                        self.showDeleteAlert = true
                    }) {
                        HStack {
                            Text(item.name)
                            Spacer()
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(title: Text("Confirm Deletion"),
                      message: Text("Are you sure you want to delete \(selectedItem?.name ?? "this item")?"),
                      primaryButton: .destructive(Text("Delete")) {
                          if let toDelete = selectedItem {
                              if let index = items.firstIndex(where: { $0.id == toDelete.id }) {
                                  items.remove(at: index)
                              }
                          }
                      },
                      secondaryButton: .cancel())
            }
            
     
        .navigationBarTitle("Delete Items", displayMode: .inline)
        .navigationBarItems(leading: Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        })
    }
}

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var items: [InventoryItem]
    
    @State private var itemName: String = "Name of Item"
    @State private var sport: String = "Name of sport"
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedDate: Date = Date()
    
    let itemNames = ["Select Item","Ball", "Glove", "Pads"]
    let sports = ["Select Sport","Soccer", "Volleyball", "Basketball", "Tennis", "Badminton"]

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Item Name", selection: $itemName) {
                    ForEach(itemNames, id: \.self) {
                        Text($0)
                    }
                }

                Picker("Sports Played", selection: $sport) {
                    ForEach(sports, id: \.self) {
                        Text($0)
                    }
                }

                Button(action: {
                    isImagePickerPresented.toggle()
                }) {
                    HStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        } else {
                            Text("Upload Image")
                        }
                    }
                }
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(selectedImage: $selectedImage)
                }
                
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()

                Button(action: {
                    let newItem = InventoryItem(
                        name: itemName,
                        sport: sport,
                        image: selectedImage,
                        timeLastSeen: dateFormatter.string(from: selectedDate)
                    )
                    items.append(newItem)
                    presentationMode.wrappedValue.dismiss()
                },
                label: {
                    Text("Add Item")
                })
            }
            .navigationBarTitle("Add Item", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}


class InventoryViewModel: ObservableObject {
    @Published var items: [InventoryItem] = [
        InventoryItem(name: "Ball1", sport: "Soccer", timeLastSeen: "10/10/23"),
        InventoryItem(name: "Ball2", sport: "Soccer", timeLastSeen: "11/10/23"),
        InventoryItem(name: "Ball3", sport: "Soccer", timeLastSeen: "12/10/23"),
        InventoryItem(name: "Ball4", sport: "Soccer", timeLastSeen: "13/10/23"),
        InventoryItem(name: "Ball5", sport: "Soccer", timeLastSeen: "14/10/23"),
        // ... add more items if needed
    ]
    let itemsPerPage = 4
    @Published var currentPage = 1
    
    func nextPage() {
         currentPage += 1
     }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
