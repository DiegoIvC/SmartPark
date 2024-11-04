import UIKit

class AccessViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!

    // Propiedades para la paginación
    var currentPage: Int = 0
    let itemsPerPage: Int = 5
    var totalItems: Int = 0
    var data: [(String, Bool, Bool)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configurar el scrollView
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true



        // Datos de ejemplo
        data = [
            ("Este es mi nombre juan Angel castañeda Chavez", true, false),
            ("Nombre 2", false, true),
            ("Nombre 3", true, false),
            ("Nombre 4", true, false),
            ("Nombre 5", true, false),
            ("Nombre 6", true, false),
            ("Nombre 7", true, false),
            ("Nombre 8", false, true),
            ("Nombre 9", true, false),
            ("Nombre 10", true, false),
            ("Nombre 11", false, true),
            ("Nombre 2", false, true),
            ("Nombre 3", true, false),
            ("Nombre 4", true, false),
            ("Nombre 5", true, false),
            ("Nombre 6", true, false),
            ("Nombre 7", true, false),
            ("Nombre 8", false, true),
            ("Nombre 9", true, false),
            ("Nombre 10", true, false),
            ("Nombre 11", false, true),
            ("Nombre 2", false, true),
            ("Nombre 3", true, false),
            ("Nombre 4", true, false),
            ("Nombre 5", true, false),
            ("Nombre 6", true, false),
            ("Nombre 7", true, false),
            ("Nombre 8", false, true),
            ("Nombre 9", true, false),
            ("Nombre 10", true, false),
            ("Nombre 11", false, true),
            ("Nombre 12", true, false)
            // Agrega más datos aquí si deseas
        ]

        totalItems = data.count

        // Llamada a función para crear el contenido de la primera página
        setupScrollViewContent(for: currentPage)

        // Configurar paginador
        setupPaginator()
    }

   

   
    func setupScrollViewContent(for page: Int) {
        // Limpiar el contenido previo
        scrollView.subviews.forEach { $0.removeFromSuperview() }

        let startIndex = page * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, totalItems)

        for index in startIndex..<endIndex {
            let yPosition = CGFloat(index % itemsPerPage) * (80 + 10)

            // Crear la vista de cada elemento
            let itemView = createItemView(name: data[index].0, isCheckedSalida: data[index].1, isCheckedEntrada: data[index].2)
            itemView.frame = CGRect(x: 0, y: yPosition, width: scrollView.frame.width, height: 80)

            scrollView.addSubview(itemView)
        }

        // Ajustar el tamaño del contenido del scrollView
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: CGFloat(itemsPerPage) * (80 + 10))
    }

    func createItemView(name: String, isCheckedSalida: Bool, isCheckedEntrada: Bool) -> UIView {
        let itemView = UIView()

        // Crear y configurar la imagen de perfil
        let profileImageView = UIImageView()
        profileImageView.image = UIImage(systemName: "photo.fill")
        profileImageView.tintColor = .blue
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
        itemView.addSubview(profileImageView)

        // Crear y configurar el primer label para el nombre
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        nameLabel.frame = CGRect(x: 80, y: 20, width: 100, height: 30)
        itemView.addSubview(nameLabel)

        // Crear y configurar el segundo label para mostrar más información
          let additionalInfoLabel = UILabel()
          additionalInfoLabel.text = "Información adicional" // Puedes cambiar este texto según lo que necesites
          additionalInfoLabel.font = UIFont.systemFont(ofSize: 14)
          additionalInfoLabel.textColor = .gray // Cambiar el color si es necesario
          additionalInfoLabel.frame = CGRect(x: 80, y: 50, width: 200, height: 20) // Ajustar la posición para que esté debajo del primer label
          itemView.addSubview(additionalInfoLabel)
        
        // Crear y configurar el botón de Asistiendo
        let asistiendoCheck = UIButton(type: .system)
        asistiendoCheck.setTitle("Activo", for: .normal)
        asistiendoCheck.setTitleColor(.black, for: .normal)
        asistiendoCheck.frame = CGRect(x: 190, y: 20, width: 80, height: 30)
        asistiendoCheck.setImage(UIImage(systemName: isCheckedEntrada ? "checkmark.circle.fill" : "circle"), for: .normal)
        asistiendoCheck.tintColor = isCheckedEntrada ? .green : .gray
        asistiendoCheck.tag = 2
        asistiendoCheck.addTarget(self, action: #selector(toggleAsistiendo(_:)), for: .touchUpInside)
        itemView.addSubview(asistiendoCheck)
        
        // Crear y configurar el botón de Ausente
        let ausenteCheck = UIButton(type: .system)
        ausenteCheck.setTitle("Inactivo", for: .normal)
        ausenteCheck.setTitleColor(.black, for: .normal)
        ausenteCheck.frame = CGRect(x: 280, y: 20, width: 80, height: 30)
        ausenteCheck.setImage(UIImage(systemName: isCheckedSalida ? "checkmark.circle.fill" : "circle"), for: .normal)
        ausenteCheck.tintColor = isCheckedSalida ? .red : .gray
        ausenteCheck.tag = 1
        ausenteCheck.addTarget(self, action: #selector(toggleAusente(_:)), for: .touchUpInside)
        itemView.addSubview(ausenteCheck)

        return itemView
    }
    
    @objc func toggleAusente(_ sender: UIButton) {
        if sender.tintColor == .green {
            sender.tintColor = .gray
            sender.setImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            sender.tintColor = .green
            sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        }
    }

    @objc func toggleAsistiendo(_ sender: UIButton) {
        if sender.tintColor == .green {
            sender.tintColor = .gray
            sender.setImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            sender.tintColor = .green
            sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        }
    }


    @objc func toggleSalida(_ sender: UIButton) {
        guard let itemView = sender.superview else { return }

        if sender.tintColor == .green {
            sender.tintColor = .gray
            sender.setImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            sender.tintColor = .green
            sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)

            if let entradaButton = itemView.viewWithTag(2) as? UIButton {
                entradaButton.tintColor = .gray
                entradaButton.setImage(UIImage(systemName: "circle"), for: .normal)
            }
        }
    }

    @objc func toggleEntrada(_ sender: UIButton) {
        guard let itemView = sender.superview else { return }

        if sender.tintColor == .green {
            sender.tintColor = .gray
            sender.setImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            sender.tintColor = .green
            sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)

            if let salidaButton = itemView.viewWithTag(1) as? UIButton {
                salidaButton.tintColor = .gray
                salidaButton.setImage(UIImage(systemName: "circle"), for: .normal)
            }
        }
    }

    func setupPaginator() {
        let paginatorView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 100, width: self.view.frame.width, height: 50))
        paginatorView.backgroundColor = .white

        let previousButton = UIButton(type: .system)
        previousButton.setTitle("Anterior", for: .normal)
        previousButton.frame = CGRect(x: 20, y: 10, width: 80, height: 30)
        previousButton.addTarget(self, action: #selector(previousPage), for: .touchUpInside)
        paginatorView.addSubview(previousButton)

        let nextButton = UIButton(type: .system)
        nextButton.setTitle("Siguiente", for: .normal)
        nextButton.frame = CGRect(x: paginatorView.frame.width - 100, y: 10, width: 80, height: 30)
        nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        paginatorView.addSubview(nextButton)

        self.view.addSubview(paginatorView)
    }

    @objc func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
            setupScrollViewContent(for: currentPage)
        }
    }

    @objc func nextPage() {
        if (currentPage + 1) * itemsPerPage < totalItems {
            currentPage += 1
            setupScrollViewContent(for: currentPage)
        }
    }
}

