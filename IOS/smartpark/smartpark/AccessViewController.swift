import UIKit

class AccessViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!

    // Propiedades para la paginación
    var currentPage: Int = 0
    let itemsPerPage: Int = 2
    var totalItems: Int = 0
    var data: [(String, String, String, String, String)] = [] // Se añadió un campo para el departamento

    var dataFetchTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configurar el scrollView
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true

        // Llamar a la API por primera vez
        fetchDataFromAPI()

        // Configurar el paginador
        setupPaginator()

        // Iniciar polling para obtener datos nuevos cada 10 segundos
        startPollingForUpdates()
    }

    @objc func fetchDataFromAPI() {
        guard let url = URL(string: "http://127.0.0.1:8000/api/estacion/673a970b8548904611656030/accesos") else {
            showAlert(title: "Error", message: "URL no válida")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Error en la conexión: \(error.localizedDescription)")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "No se recibieron datos")
                }
                return
            }

            do {
                let responseData = try JSONDecoder().decode([[String: String]].self, from: data)
                self.data = responseData.map {
                    let fullName = "\($0["nombre"] ?? "") \($0["apellido_paterno"] ?? "") \($0["apellido_materno"] ?? "")"
                    let formattedDate = self.formatDate($0["fecha"] ?? "")
                    return (fullName, $0["rfid"] ?? "N/A", $0["curp"] ?? "N/A", formattedDate, $0["departamento"] ?? "Sin departamento")
                }
                self.totalItems = self.data.count

                DispatchQueue.main.async {
                    if self.totalItems > 0 {
                        // Actualizar dinámicamente la vista con los nuevos datos
                        self.setupScrollViewContent(for: self.currentPage)
                    } else {
                        self.showAlert(title: "Aviso", message: "No hay accesos disponibles")
                    }
                    // Actualizamos la visibilidad de los botones del paginador
                    self.updatePaginatorButtons()
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Error al procesar los datos: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }

    // Función para formatear la fecha de manera simplificada
    func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .long
            outputFormatter.timeStyle = .short // Incluimos la hora
            return outputFormatter.string(from: date)
        } else {
            return dateString // Si no se puede parsear, devolvemos la fecha original
        }
    }

    func setupScrollViewContent(for page: Int) {
        // Limpiar el contenido previo
        scrollView.subviews.forEach { $0.removeFromSuperview() }

        let startIndex = page * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, totalItems)

        for index in startIndex..<endIndex {
            let yPosition = CGFloat(index % itemsPerPage) * (90 + 10) // Aumentamos el espacio para el departamento

            // Crear la vista de cada elemento
            let itemView = createItemView(name: data[index].0, id: data[index].1, department: data[index].4, curp: data[index].2, date: data[index].3)
            itemView.frame = CGRect(x: 0, y: yPosition, width: scrollView.frame.width, height: 90) // Ajustamos la altura por el nuevo label

            scrollView.addSubview(itemView)
        }

        // Ajustar el tamaño del contenido del scrollView
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: CGFloat((endIndex - startIndex)) * (90 + 10))
    }

    func createItemView(name: String, id: String, department: String, curp: String, date: String) -> UIView {
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
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.frame = CGRect(x: 80, y: 10, width: 200, height: 20)
        itemView.addSubview(nameLabel)

        // Crear y configurar el segundo label para el ID (rfid)
        let idLabel = UILabel()
        idLabel.text = id
        idLabel.font = UIFont.systemFont(ofSize: 14)
        idLabel.textColor = .gray
        idLabel.frame = CGRect(x: 80, y: 30, width: 200, height: 20)
        itemView.addSubview(idLabel)

        // Crear y configurar el tercer label para el CURP
        let curpLabel = UILabel()
        curpLabel.text = curp
        curpLabel.font = UIFont.systemFont(ofSize: 14)
        curpLabel.textColor = .gray
        curpLabel.frame = CGRect(x: 80, y: 50, width: 200, height: 20)
        itemView.addSubview(curpLabel)

        // Crear y configurar el cuarto label para el departamento
        let departmentLabel = UILabel()
        departmentLabel.text = department
        departmentLabel.font = UIFont.systemFont(ofSize: 14)
        departmentLabel.textColor = .gray
        departmentLabel.frame = CGRect(x: 80, y: 70, width: 200, height: 20)
        itemView.addSubview(departmentLabel)

        // Crear y configurar el quinto label para la fecha
        let dateLabel = UILabel()
        dateLabel.text = date
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .gray
        dateLabel.frame = CGRect(x: 80, y: 90, width: 200, height: 20) // Ajustamos la posición por la nueva altura
        itemView.addSubview(dateLabel)

        return itemView
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
        nextButton.isEnabled = currentPage < totalPages() - 1

        // Colocar los botones y el label en el paginador
        previousButton.frame = CGRect(x: 20, y: 10, width: 100, height: 30)
        pageLabel.frame = CGRect(x: 130, y: 10, width: 160, height: 30)
        nextButton.frame = CGRect(x: 300, y: 10, width: 100, height: 30)

        paginatorView.addSubview(previousButton)
        paginatorView.addSubview(pageLabel)
        paginatorView.addSubview(nextButton)

        self.view.addSubview(paginatorView)
    }

    func totalPages() -> Int {
        return (totalItems + itemsPerPage - 1) / itemsPerPage
    }

    @objc func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
            setupScrollViewContent(for: currentPage)
            updatePaginatorButtons()
        }
    }

    @objc func nextPage() {
        if currentPage < totalPages() - 1 {
            currentPage += 1
            setupScrollViewContent(for: currentPage)
            updatePaginatorButtons()
        }
    }

    func updatePaginatorButtons() {
        guard let paginatorView = self.view.subviews.last else { return }
        
        let previousButton = paginatorView.subviews.first { $0 is UIButton && ($0 as! UIButton).title(for: .normal) == "Anterior" } as? UIButton
        let nextButton = paginatorView.subviews.first { $0 is UIButton && ($0 as! UIButton).title(for: .normal) == "Siguiente" } as? UIButton
        let pageLabel = paginatorView.subviews.first { $0 is UILabel } as? UILabel

        previousButton?.isEnabled = currentPage > 0
        nextButton?.isEnabled = currentPage < totalPages() - 1
        pageLabel?.text = "Página \(currentPage + 1) de \(totalPages())"
    }


    // Función para manejar los errores
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // Polling para actualización periódica
    func startPollingForUpdates() {
        dataFetchTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(fetchDataFromAPI), userInfo: nil, repeats: true)
    }

    // Detener el polling cuando no se necesita más
    deinit {
        dataFetchTimer?.invalidate()
    }
}

