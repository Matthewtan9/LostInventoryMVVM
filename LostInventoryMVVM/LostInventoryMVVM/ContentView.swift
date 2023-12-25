import SwiftUI
import FirebaseFirestore

// Define Firestore document structure
struct InventoryDocument: Identifiable, Codable {
    var id = UUID()
    var items: [InventoryItem]
}

struct InventoryItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var sport: String
    var imageData: Data?
    var timeLastSeen: String
    var imageURL: String?

    var image: UIImage? {
        get {
            if let imageData = imageData {
                return UIImage(data: imageData)
            }
            return nil
        }
        set {
            imageData = newValue?.jpegData(compressionQuality: 1.0)
        }
    }

    init(name: String, sport: String, image: UIImage?, timeLastSeen: String, imageURL: String? = nil) {
        self.name = name
        self.sport = sport
        self.imageData = image?.jpegData(compressionQuality: 1.0)
        self.timeLastSeen = timeLastSeen
        self.imageURL = imageURL
    }

    enum CodingKeys: String, CodingKey {
        case id, name, sport, imageData, timeLastSeen, imageURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        sport = try container.decode(String.self, forKey: .sport)
        imageData = try container.decode(Data.self, forKey: .imageData)
        timeLastSeen = try container.decode(String.self, forKey: .timeLastSeen)
        imageURL = try container.decode(String.self, forKey: .imageURL)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(sport, forKey: .sport)
        try container.encode(imageData, forKey: .imageData)
        try container.encode(timeLastSeen, forKey: .timeLastSeen)
        try container.encode(imageURL, forKey: .imageURL)
    }
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
    @State private var deletedItems: [InventoryItem] = []

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
                            AddItemView(items: $viewModel.items, viewModel: viewModel)
                        }

                        EditButton()
                                .foregroundColor(.white)
                                .padding()
                                .font(.title2)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity)
                    }

                   
                    Text("Found Items: \(deletedItems.count)")
                        .font(.title2)
                        .padding()
                        .background(Color.red.opacity(0.3))
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity)
                }
            }
            .listStyle(GroupedListStyle())
            Spacer()
        }
    }

    func deleteItems(at offsets: IndexSet) {
        // Move the deleted items to the temporary array
        deletedItems.append(contentsOf: offsets.map { viewModel.items[$0] })
        viewModel.items.remove(atOffsets: offsets)

        // Update Firestore after deletion
        let inventoryDocument = InventoryDocument(items: viewModel.items)
        do {
            try viewModel.db.collection("LostInventoryMVVM").document("A0XMgid7AmmmzHEgJzVr").setData(from: inventoryDocument)
        } catch {
            print("Error updating Firestore after deletion: \(error)")
        }
    }
}


struct DeletedItemsView: View {
    @Binding var deletedItems: [InventoryItem]

    var body: some View {
        List {
            ForEach(deletedItems.indices, id: \.self) { index in
                Text(deletedItems[index].name)
            }
        }
        .navigationBarTitle("Deleted Items", displayMode: .inline)
    }
}

struct DeleteItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var items: [InventoryItem]
    @ObservedObject var viewModel: InventoryViewModel
    @State private var selectedItem: InventoryItem?
    @State private var showDeleteAlert: Bool = false

    var body: some View {
        VStack {
            Text("...")
                .font(.title)
        }
        .textCase(.none)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitle("Delete Items", displayMode: .inline)
        .navigationBarItems(leading: Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        })
        .onAppear {
            viewModel.loadItemsFromFirestore()
        }
    }
}

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var items: [InventoryItem]
    @ObservedObject var viewModel: InventoryViewModel

    @State private var itemName: String = "Name of Item"
    @State private var sport: String = "Name of sport"
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedDate: Date = Date()

    let itemNames = ["Select Item", "Ball", "Glove", "Pads"]
    let sports = ["Select Sport", "Soccer", "Volleyball", "Basketball", "Tennis", "Badminton"]

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
                        timeLastSeen: dateFormatter.string(from: selectedDate),
                        imageURL: nil
                    )
                    items.append(newItem)

                    // Upload item to Firestore
                    let inventoryDocument = InventoryDocument(items: items)
                    do {
                        try viewModel.db.collection("LostInventoryMVVM").document("A0XMgid7AmmmzHEgJzVr").setData(from: inventoryDocument)
                    } catch {
                        print("Error writing item to Firestore: \(error)")
                    }

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
    @Published var items: [InventoryItem] = []
    @Published var foundItems: [InventoryItem] = [] // New array for found items
    let db = Firestore.firestore()

    func loadItemsFromFirestore() {
        db.collection("LostInventoryMVVM").document("A0XMgid7AmmmzHEgJzVr").getDocument { document, error in
            if let error = error {
                print("Error getting document: \(error)")
            } else if let document = document, document.exists {
                if let inventoryDocument = try? document.data(as: InventoryDocument.self) {
                    self.items = inventoryDocument.items
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
