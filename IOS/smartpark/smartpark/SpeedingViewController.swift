import UIKit

class SpeedingViewController: UIViewController {


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
       // let nameLabel = UILabel()
        //nameLabel.text = name
        //nameLabel.font = UIFont.systemFont(ofSize: 13)
        //nameLabel.frame = CGRect(x: 80, y: 20, width: 100, height: 30)
        //itemView.addSubview(nameLabel)

        // Crear y configurar los labels para "Velocidad:", "Fecha:" y "Advertido:" con sus valores
        let velocidadLabel = UILabel()
        velocidadLabel.text = "Velocidad:"
        velocidadLabel.font = UIFont.systemFont(ofSize: 14)
        velocidadLabel.textColor = .gray
        velocidadLabel.frame = CGRect(x: 80, y: 10, width: 80, height: 20)
        itemView.addSubview(velocidadLabel)

        let velocidadValueLabel = UILabel()
        velocidadValueLabel.text = "80 km/h" // Cambia el valor según lo que necesites
        velocidadValueLabel.font = UIFont.systemFont(ofSize: 14)
        velocidadValueLabel.frame = CGRect(x: 160, y: 10, width: 100, height: 20)
        itemView.addSubview(velocidadValueLabel)

        let fechaLabel = UILabel()
        fechaLabel.text = "Fecha:"
        fechaLabel.font = UIFont.systemFont(ofSize: 14)
        fechaLabel.textColor = .gray
        fechaLabel.frame = CGRect(x: 80, y: 30, width: 80, height: 20)
        itemView.addSubview(fechaLabel)

        let fechaValueLabel = UILabel()
        fechaValueLabel.text = "01/11/2024" // Cambia el valor según lo que necesites
        fechaValueLabel.font = UIFont.systemFont(ofSize: 14)
        fechaValueLabel.frame = CGRect(x: 160, y: 30, width: 100, height: 20)
        itemView.addSubview(fechaValueLabel)

        let advertidoLabel = UILabel()
        advertidoLabel.text = "Advertido:"
        advertidoLabel.font = UIFont.systemFont(ofSize: 14)
        advertidoLabel.textColor = .gray
        advertidoLabel.frame = CGRect(x: 80, y: 50, width: 80, height: 20)
        itemView.addSubview(advertidoLabel)

        let advertidoValueLabel = UILabel()
        advertidoValueLabel.text = "Sí" // Cambia el valor según lo que necesites
        advertidoValueLabel.font = UIFont.systemFont(ofSize: 14)
        advertidoValueLabel.frame = CGRect(x: 160, y: 50, width: 100, height: 20)
        itemView.addSubview(advertidoValueLabel)
        
        let verDetallesButton = UIButton(type: .system)
        verDetallesButton.setTitle("Detalles", for: .normal)
        verDetallesButton.setTitleColor(.white, for: .normal)
        verDetallesButton.backgroundColor = .blue // Fondo azul
        verDetallesButton.contentHorizontalAlignment = .center // Alineación a la derecha dentro del botón

        // Configuración del frame para colocar el botón a la derecha de la pantalla
        let screenWidth = UIScreen.main.bounds.width
        verDetallesButton.layer.cornerRadius = 10 // Bordes redondeados
        verDetallesButton.clipsToBounds = true // Asegura que los bordes se recorten
        verDetallesButton.frame = CGRect(x: screenWidth - 110, y: 20, width: 100, height: 30) // Ajusta 'x' para la posición en la derecha

        // Añadir el botón a la vista
        itemView.addSubview(verDetallesButton)

        return itemView
    }
    
    // Acción para el botón Ver Detalles
    @objc func verDetalles(_ sender: UIButton) {
        // Código para mostrar los detalles
        print("Ver Detalles presionado")
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


