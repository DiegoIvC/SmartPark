import UIKit
import SystemConfiguration

class SpeedingViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!

    // Propiedades para la paginación
    var currentPage: Int = 0
    let itemsPerPage: Int = 5
    var totalItems: Int = 0
    var data: [(String, String, String)] = [] // (imagen, velocidad, fecha)

    // Elementos para el paginador
    var paginatorLabel: UILabel?
    var dataRefreshTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configurar el scrollView
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true

        // Verificar la conexión a internet antes de hacer la solicitud
        if isInternetAvailable() {
            fetchData()
            // Iniciar el temporizador para refrescar los datos periódicamente
            startDataRefreshTimer()
        } else {
            showErrorMessage("No hay conexión a internet.")
        }
    }

    func isInternetAvailable() -> Bool {
        let reachability = SCNetworkReachabilityCreateWithName(nil, "www.apple.com")
        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(reachability!, &flags) == false {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)

        return isReachable && !needsConnection
    }

    @objc func fetchData() {
        guard let url = URL(string: "http://3.147.187.80/api/estacion/673a970b8548904611656030/actuadores/velocimetro/camara") else {
            print("URL no válida")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error en la solicitud: \(error)")
                DispatchQueue.main.async {
                    self.showErrorMessage("Hubo un error al obtener los datos.")
                }
                return
            }

            guard let data = data else {
                print("Datos vacíos")
                DispatchQueue.main.async {
                    self.showErrorMessage("No se recibieron datos.")
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let items = json["CA-1"] as? [[String: Any]] {

                    // Convertir los datos a tu tipo esperado
                    let newData = items.compactMap { item -> (String, String, String)? in
                        // Extraemos valores del diccionario de manera segura
                        guard let imagen = item["imagen"] as? String,
                              let velocidad = item["velocidad"] as? String,
                              let fecha = item["fecha"] as? String else {
                            return nil // Si falta algún valor, ignoramos este item
                        }
                        return (imagen, velocidad, fecha) // Devolvemos la tupla con los valores correctos
                    }

                    DispatchQueue.main.async {
                        // Usar elementsEqual para comparar los arrays de tuplas
                        if !newData.elementsEqual(self.data, by: { $0 == $1 }) {
                            self.data = newData
                            self.totalItems = self.data.count
                            self.setupScrollViewContent(for: self.currentPage)
                            self.setupPaginator()
                        }
                    }
                }
            } catch {
                print("Error al parsear JSON: \(error)")
                DispatchQueue.main.async {
                    self.showErrorMessage("Error al procesar los datos.")
                }
            }

        }

        task.resume()
    }

    func setupScrollViewContent(for page: Int) {
        // Limpiar el contenido previo
        scrollView.subviews.forEach { $0.removeFromSuperview() }

        let startIndex = page * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, totalItems)

        for index in startIndex..<endIndex {
            let yPosition = CGFloat(index % itemsPerPage) * (80 + 10)

            let item = data[index]
            let itemView = createItemView(imageURL: item.0, velocidad: item.1, fecha: item.2)
            itemView.frame = CGRect(x: 0, y: yPosition, width: scrollView.frame.width, height: 80)

            scrollView.addSubview(itemView)
        }

        // Ajustar el tamaño del contenido del scrollView
        let totalHeight = CGFloat(min(totalItems, (page + 1) * itemsPerPage)) * (80 + 10)
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: totalHeight)
    }

    func createItemView(imageURL: String, velocidad: String, fecha: String) -> UIView {
        let itemView = UIView()

        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        profileImageView.layer.cornerRadius = 30
        profileImageView.clipsToBounds = true
        itemView.addSubview(profileImageView)

        // Configurar el tap gesture para la imagen
        profileImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        profileImageView.addGestureRecognizer(tapGesture)

        if let url = URL(string: imageURL) {
            let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        profileImageView.image = UIImage(data: data)
                    }
                }
            }
            task.resume()
        }

        let velocidadLabel = UILabel()
        let fullText = "Velocidad: \(velocidad) km/h"
        let attributedString = NSMutableAttributedString(string: fullText)

        if let range = fullText.range(of: velocidad) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: nsRange)
        }

        velocidadLabel.attributedText = attributedString
        velocidadLabel.font = UIFont.systemFont(ofSize: 14)
        velocidadLabel.frame = CGRect(x: 120, y: 30, width: 200, height: 20)
        itemView.addSubview(velocidadLabel)

        let formattedDate = formatDate(fecha)
        let fechaLabel = UILabel()
        fechaLabel.text = formattedDate
        fechaLabel.font = UIFont.systemFont(ofSize: 14)
        fechaLabel.textColor = .systemBlue
        fechaLabel.frame = CGRect(x: 120, y: 60, width: 200, height: 20)
        itemView.addSubview(fechaLabel)

        return itemView
    }

    func formatDate(_ fecha: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: fecha) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "d MMMM yyyy h:mm a"
            return outputFormatter.string(from: date)
        } else {
            return fecha
        }
    }

    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        if let image = tappedImageView.image {
            showFullScreenImage(image: image)
        }
    }

    func showFullScreenImage(image: UIImage) {
        let fullScreenView = UIView(frame: self.view.bounds)
        fullScreenView.isUserInteractionEnabled = true

        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = fullScreenView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        fullScreenView.addSubview(blurEffectView)

        let fullScreenImageView = UIImageView(image: image)
        fullScreenImageView.frame = fullScreenView.bounds
        fullScreenImageView.contentMode = .scaleAspectFit
        fullScreenView.addSubview(fullScreenImageView)

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✖️", for: .normal)
        closeButton.frame = CGRect(x: fullScreenView.frame.width - 60, y: 40, width: 40, height: 40)
        closeButton.addTarget(self, action: #selector(dismissFullScreenImage(_:)), for: .touchUpInside)
        fullScreenView.addSubview(closeButton)

        fullScreenView.tag = 999
        self.view.addSubview(fullScreenView)
    }

    @objc func dismissFullScreenImage(_ sender: UIButton) {
        if let fullScreenView = self.view.viewWithTag(999) {
            fullScreenView.removeFromSuperview()
        }
    }

    func setupPaginator() {
        let paginatorView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 100, width: self.view.frame.width, height: 50))
        paginatorView.backgroundColor = .white

        let previousButton = UIButton(type: .system)
        previousButton.setTitle("Anterior", for: .normal)
        previousButton.frame = CGRect(x: 10, y: 10, width: 100, height: 30)
        previousButton.addTarget(self, action: #selector(previousPage), for: .touchUpInside)

        paginatorLabel = UILabel()
        paginatorLabel?.frame = CGRect(x: 120, y: 10, width: 150, height: 30)
        paginatorLabel?.textAlignment = .center
        paginatorLabel?.text = "Página \(currentPage + 1) de \(Int(ceil(Double(totalItems) / Double(itemsPerPage))))"

        let nextButton = UIButton(type: .system)
        nextButton.setTitle("Siguiente", for: .normal)
        nextButton.frame = CGRect(x: self.view.frame.width - 110, y: 10, width: 100, height: 30)
        nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)

        paginatorView.addSubview(previousButton)
        paginatorView.addSubview(paginatorLabel!)
        paginatorView.addSubview(nextButton)

        self.view.addSubview(paginatorView)
    }

    @objc func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
            setupScrollViewContent(for: currentPage)
            paginatorLabel?.text = "Página \(currentPage + 1) de \(Int(ceil(Double(totalItems) / Double(itemsPerPage))))"
        }
    }

    @objc func nextPage() {
        if currentPage < (totalItems / itemsPerPage) {
            currentPage += 1
            setupScrollViewContent(for: currentPage)
            paginatorLabel?.text = "Página \(currentPage + 1) de \(Int(ceil(Double(totalItems) / Double(itemsPerPage))))"
        }
    }

    @objc func startDataRefreshTimer() {
        dataRefreshTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(fetchData), userInfo: nil, repeats: true)
    }

    func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

