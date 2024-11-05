import UIKit

class AccessViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!

    // Propiedades para la paginación
    var currentPage: Int = 0
    let itemsPerPage: Int = 5
    var totalItems: Int = 0
    var data: [(String, String, String, String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configurar el scrollView
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true

        // Datos de ejemplo
        data = [
            ("Juan Angel Castañeda Chávez", "CACJ2809", "Desarrollo", "28/09/10"),
            ("Ana María Gómez López", "AMGL3012", "Recursos Humanos", "15/05/15"),
            ("Carlos Eduardo Martínez Pérez", "CEMP1402", "Finanzas", "10/11/18"),
            ("Lucía Fernández Torres", "LFT0910", "Ventas", "22/07/20"),
            ("Miguel Ángel Salazar Román", "MASR2211", "Soporte Técnico", "30/03/19"),
            ("Roberto Díaz Hernández", "RDH2512", "Marketing", "09/02/17"),
            ("Andrea Soto Jiménez", "ASJ1908", "Desarrollo", "13/09/21"),
            ("Elena Ríos Domínguez", "ERD0811", "Logística", "27/04/18"),
            ("Francisco Ortega Ramos", "FOR0501", "Finanzas", "12/06/14"),
            ("Silvia Villanueva Cruz", "SVC1703", "Compras", "31/08/19"),
            ("Mario García Morales", "MGM2709", "Legal", "10/10/20"),
            ("Gabriela Pérez Sánchez", "GPS1202", "Administración", "17/07/16"),
            ("Héctor Rivera Valdez", "HRV0610", "Soporte Técnico", "25/11/17"),
            ("Isabel Ortega Ramírez", "IOR2105", "Calidad", "03/03/13"),
            ("Fernando Díaz Chávez", "FDC1506", "Ventas", "20/01/22"),
            ("Laura Gutiérrez Herrera", "LGH2303", "Desarrollo", "08/04/14"),
            ("Manuel Torres Cruz", "MTC1808", "Recursos Humanos", "27/05/20"),
            ("Patricia Méndez Flores", "PMF0712", "Operaciones", "11/02/19"),
            ("Eduardo Solís Nieto", "ESN2804", "Marketing", "05/10/21"),
            ("Sofía Ruiz Vargas", "SRV0911", "Compras", "22/01/18"),
            ("Alberto Vargas Reyes", "AVR2903", "Logística", "19/07/13"),
            ("Olga Jiménez Lozano", "OJL1605", "Administración", "02/09/15"),
            ("Jesús Ponce Salazar", "JPS0707", "Calidad", "18/10/17"),
            ("Marcela Gómez Lara", "MGL2410", "Legal", "29/03/20"),
            ("Andrés Romero Márquez", "ARM0106", "Finanzas", "04/12/19"),
            ("Daniela Cruz Olmedo", "DCO1304", "Soporte Técnico", "09/09/14"),
            ("Luis Herrera Ramírez", "LHR2212", "Ventas", "14/02/21"),
            ("Carmen Peña Campos", "CPC1911", "Desarrollo", "07/05/16"),
            ("Rafael Ortiz Torres", "ROT0202", "Marketing", "25/08/18"),
            ("Monserrat Rangel Morales", "MRM1509", "Recursos Humanos", "17/06/15"),
            ("José Luis Serrano Núñez", "JLS0505", "Calidad", "20/03/22"),
            ("Raquel Salinas Gutiérrez", "RSG1408", "Operaciones", "12/07/13")
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
            let itemView = createItemView(name: data[index].0, id: data[index].1, department: data[index].2, date: data[index].3)
            itemView.frame = CGRect(x: 0, y: yPosition, width: scrollView.frame.width, height: 80)

            scrollView.addSubview(itemView)
        }

        // Ajustar el tamaño del contenido del scrollView
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: CGFloat((endIndex - startIndex)) * (80 + 10))
    }

    func createItemView(name: String, id: String, department: String, date: String) -> UIView {
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
        nameLabel.frame = CGRect(x: 80, y: 10, width: 200, height: 20)
        itemView.addSubview(nameLabel)

        // Crear y configurar el segundo label para el ID
        let idLabel = UILabel()
        idLabel.text = id
        idLabel.font = UIFont.systemFont(ofSize: 12)
        idLabel.textColor = .gray
        idLabel.frame = CGRect(x: 80, y: 30, width: 200, height: 20)
        itemView.addSubview(idLabel)

        // Crear y configurar el tercer label para el departamento
        let departmentLabel = UILabel()
        departmentLabel.text = department
        departmentLabel.font = UIFont.systemFont(ofSize: 12)
        departmentLabel.textColor = .gray
        departmentLabel.frame = CGRect(x: 80, y: 50, width: 200, height: 20)
        itemView.addSubview(departmentLabel)

        // Crear y configurar el cuarto label para la fecha
        let dateLabel = UILabel()
        dateLabel.text = date
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .gray
        dateLabel.frame = CGRect(x: 80, y: 70, width: 200, height: 20)
        itemView.addSubview(dateLabel)

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

        // Botón "Anterior"
        let previousButton = UIButton(type: .system)
        previousButton.setTitle("Anterior", for: .normal)
        previousButton.addTarget(self, action: #selector(previousPage), for: .touchUpInside)
        previousButton.isEnabled = currentPage > 0

        // Indicador de página
        let pageLabel = UILabel()
        pageLabel.text = "Página \(currentPage + 1) de \(totalPages())"
        pageLabel.textAlignment = .center
        pageLabel.font = UIFont.boldSystemFont(ofSize: 16)

        // Botón "Siguiente"
        let nextButton = UIButton(type: .system)
        nextButton.setTitle("Siguiente", for: .normal)
        nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        nextButton.isEnabled = (currentPage + 1) * itemsPerPage < totalItems

        // Configuración del stack view para los botones e indicador
        let stackView = UIStackView(arrangedSubviews: [previousButton, pageLabel, nextButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        paginatorView.addSubview(stackView)

        // Constraints para centrar el stack view dentro de paginatorView
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: paginatorView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: paginatorView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: paginatorView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: paginatorView.trailingAnchor, constant: -20)
        ])

        self.view.addSubview(paginatorView)
    }

    // Función para obtener el total de páginas basado en el número de elementos y elementos por página
    func totalPages() -> Int {
        return (totalItems + itemsPerPage - 1) / itemsPerPage
    }

    @objc func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
            setupScrollViewContent(for: currentPage)
            updatePaginator()  // Llamada para actualizar el estado de los botones
        }
    }

    @objc func nextPage() {
        if (currentPage + 1) * itemsPerPage < totalItems {
            currentPage += 1
            setupScrollViewContent(for: currentPage)
            updatePaginator()  // Llamada para actualizar el estado de los botones
        }
    }

    func updatePaginator() {
        // Encuentra el paginatorView (última subvista añadida en el setupPaginator)
        if let paginatorView = self.view.subviews.last,
           let stackView = paginatorView.subviews.first as? UIStackView,
           let previousButton = stackView.arrangedSubviews[0] as? UIButton,
           let pageLabel = stackView.arrangedSubviews[1] as? UILabel,
           let nextButton = stackView.arrangedSubviews[2] as? UIButton {
            
            // Actualizar el texto del indicador de página
            pageLabel.text = "Página \(currentPage + 1) de \(totalPages())"
            
            // Habilitar o deshabilitar botones según la página actual
            previousButton.isEnabled = currentPage > 0
            nextButton.isEnabled = (currentPage + 1) * itemsPerPage < totalItems
        }
    }




}

