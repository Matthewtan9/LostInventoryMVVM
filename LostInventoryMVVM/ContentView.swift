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
    @State private var isImagePickerPresentedForItem: InventoryItem? = nil

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
                    ForEach(viewModel.items) { item in
                        HStack {
                            Text(item.name)
                                .frame(width: 80, alignment: .leading)
                            Spacer()
                            Text(item.sport)
                                .frame(width: 90, alignment: .leading)
                            Spacer()
                            Button(action: {
                                isImagePickerPresentedForItem = item
                            }) {
                                if let image = item.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                } else {
                                    Circle()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color.gray.opacity(0.7))
                                }
                            }
                            .sheet(item: $isImagePickerPresentedForItem) { _ in
                                ImagePicker(selectedImage: .constant(isImagePickerPresentedForItem?.image))
                            }
                            Spacer()
                            Text(item.timeLastSeen)
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
        .navigationBarItems(leading: Button("Back") {
            presentationMode.wrappedValue.dismiss()
        })
    }
}


struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var items: [InventoryItem]
    
    @State private var itemName: String = ""
    @State private var sport: String = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented: Bool = false
    @State private var timeLastSeen: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Item Name", text: $itemName)
                TextField("Sports Played", text: $sport)
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
                TextField("Time Last Seen", text: $timeLastSeen)
                
                Button(action: {
                    let newItem = InventoryItem(name: itemName, sport: sport, image: selectedImage, timeLastSeen: timeLastSeen)
                    items.append(newItem)
                    presentationMode.wrappedValue.dismiss()
                }, label: {
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
        InventoryItem(name: "Item 1", sport: "Soccer", timeLastSeen: "10/10/23"),
        InventoryItem(name: "Item 2", sport: "Soccer", timeLastSeen: "Time"),
        InventoryItem(name: "Item 3", sport: "Soccer", timeLastSeen: "Time"),
        InventoryItem(name: "Item 4", sport: "Soccer", timeLastSeen: "Time")
    ]
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
