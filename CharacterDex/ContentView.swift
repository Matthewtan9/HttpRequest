import SwiftUI
import Combine

struct Superhero: Codable, Identifiable {
    let id: Int
    let name: String
    let images: SuperheroImages
}

struct SuperheroImages: Codable {
    let xs: URL
    let sm: URL
    let md: URL
    let lg: URL
}

class SuperheroViewModel: ObservableObject {
    @Published var superheroes: [Superhero] = []
    private var cancellables: Set<AnyCancellable> = []

    func fetchData() {
        guard let url = URL(string: "https://akabab.github.io/superhero-api/api/all.json") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Superhero].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break 
                case .failure(let error):
                    print("Error: \(error)")
                }
            } receiveValue: { [weak self] superheroes in
                self?.superheroes = superheroes
            }
            .store(in: &cancellables)
    }
}

struct ContentView: View {
    @ObservedObject private var viewModel = SuperheroViewModel()

    var body: some View {
        List(viewModel.superheroes) { superhero in
            VStack {
                // Display superhero images in different sizes
                Group {
                    loadImage(from: superhero.images.xs)
                    loadImage(from: superhero.images.sm)
                    loadImage(from: superhero.images.md)
                    loadImage(from: superhero.images.lg)
                }
                .frame(width: 100, height: 100)
                
                // Display superhero name
                Text(superhero.name)
            }
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
    
    private func loadImage(from url: URL) -> AnyView {
        if let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            return AnyView(
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            )
        } else {
            return AnyView(
                Image(systemName: "photo")
            )
        }
    }


}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
