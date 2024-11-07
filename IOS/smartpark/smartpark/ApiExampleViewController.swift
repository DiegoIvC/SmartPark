import UIKit

class ApiExampleViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    func fetchData() {
        guard let url = URL(string: "https://rickandmortyapi.com/api/character/665") else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else { return }

            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.user = user
                    self.updateUI()
                }
            } catch {
                print("Error al decodificar JSON: \(error)")
            }
        }.resume()
    }

    func updateUI() {
        guard let user = user else { return }
        
        // Posición inicial para las etiquetas
        var yOffset: CGFloat = 20.0
        let spacing: CGFloat = 40.0

        // Helper para crear etiquetas de texto
        func createLabel(withText text: String) -> UILabel {
            let label = UILabel()
            label.text = text
            label.font = UIFont.systemFont(ofSize: 16)
            label.numberOfLines = 0
            label.frame = CGRect(x: 20, y: yOffset, width: scrollView.frame.width - 40, height: 0)
            label.sizeToFit()
            scrollView.addSubview(label)
            yOffset += label.frame.height + spacing
            return label
        }
        
        // Crear y agregar etiquetas para cada propiedad del modelo `User`
        createLabel(withText: "ID: \(user.id)")
        createLabel(withText: "Name: \(user.name)")
        createLabel(withText: "Status: \(user.status)")
        createLabel(withText: "Species: \(user.species)")
        createLabel(withText: "Type: \(user.type)")
        createLabel(withText: "Gender: \(user.gender)")
        
        // Origin
        createLabel(withText: "Origin Name: \(user.origin.name)")
        createLabel(withText: "Origin URL: \(user.origin.url)")

        // Location
        createLabel(withText: "Location Name: \(user.location.name)")
        createLabel(withText: "Location URL: \(user.location.url)")

        // Image URL
        createLabel(withText: "Image URL: \(user.image)")
        
        // Episodes
        let episodesText = user.episode.joined(separator: ", ")
        createLabel(withText: "Episodes: \(episodesText)")
        
        // URL del personaje
        createLabel(withText: "URL: \(user.url)")
        
        // Created date
        createLabel(withText: "Created: \(user.created)")

        // Ajusta el tamaño del scrollView
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: yOffset)
    }
}


