import UIKit
import SygicMaps
import SygicMapsKit


class CustomMarkerInfoExampleViewController: UIViewController, SYMKModulePresenter {
    
    var presentedModules = [SYMKModuleViewController]()
    var customAnnotations = [SYAnnotation]()
    let reuseIdentifier = "customTapViews"
    var browseMapModule: SYMKBrowseMapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Custom marker info demo"
        
        let removeAnnotationsButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(CustomMarkerInfoExampleViewController.removeAnnotationsTapped(_:)))
        navigationItem.rightBarButtonItem = removeAnnotationsButton
        
        let browseMap = SYMKBrowseMapViewController()
        browseMap.delegate = self
        browseMap.annotationDelegate = self
        browseMap.mapSelectionMode = .all
        browseMapModule = browseMap
        
        presentModule(browseMap)
    }
    
    @objc private func removeAnnotationsTapped(_ sender: UIButton) {
        customAnnotations.forEach { annotation in
            browseMapModule?.removeAnnotation(annotation)
        }
    }
    
}

extension CustomMarkerInfoExampleViewController: SYMKBrowseMapViewControllerDelegate {
    
    func browseMapController(_ browseController: SYMKBrowseMapViewController, didSelect data: SYMKPoiDataProtocol) {
        let customAnnotation = DataAnnotation(data: data)
        customAnnotations.append(customAnnotation)
        browseController.addAnnotation(customAnnotation)
    }
    
}

extension CustomMarkerInfoExampleViewController: SYMKBrowserMapViewControllerAnnotationDelegate {
    
    func browseMapController(_ browseController: SYMKBrowseMapViewController, wantsViewFor annotation: SYAnnotation) -> SYAnnotationView {
        let annotationView: DataAnnotationView
        
        if let dequeueView = browseController.dequeueReusableAnnotation(for: reuseIdentifier), let dataAnnotationView = dequeueView as? DataAnnotationView {
            annotationView = dataAnnotationView
        } else {
            annotationView = DataAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
        
        annotationView.firstText = "\(annotation.coordinate.latitude)"
        annotationView.secondText = "\(annotation.coordinate.longitude)"
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(customViewTapped)))
        
        return annotationView
    }
    
    @objc func customViewTapped() {
        print("Custom View Tapped")
    }
    
}
