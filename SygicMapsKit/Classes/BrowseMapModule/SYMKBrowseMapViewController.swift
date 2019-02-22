import SygicMaps
import SygicUIKit


public protocol SYMKBrowseMapViewControllerDelegate: class {
    func browseMapController(_ browseController: SYMKBrowseMapViewController, didSelect data: SYMKPoiDataProtocol)
}

public protocol SYMKBrowserMapViewControllerAnnotationDelegate: class {
    func browseMapController(_ browseController: SYMKBrowseMapViewController, wantsViewFor annotation: SYAnnotation) -> SYAnnotationView
}

public class SYMKBrowseMapViewController: SYMKModuleViewController {
    
    // MARK: - Public Properties
    
    public enum MapSkins: String {
        case day
        case night
    }
    
    public enum UsersLocationSkins: String {
        case pedestrian
        case car
    }
    
    /**
        Delegate output for browse map controller
     */
    public weak var delegate: SYMKBrowseMapViewControllerDelegate?
    public weak var annotationDelegate: SYMKBrowserMapViewControllerAnnotationDelegate?
    
    /**
        Enables compass functionality.
    */
    public var useCompass = false
    
    /**
        Enables zoom control functionality.
     */
    public var useZoomControl = false

    /**
        Enables recenter button functionality.
        Button is automatically shown if map camera isn't centered to current position. After tapping recenter button, camera is automatically recentered and button disappears.
    */
    public var useRecenterButton = false
    
    /**
        Enables bounce in animation on first appearance of default poi detail bottom sheet
     */
    public var bounceDefaultPoiDetailFirstTime = false
    
    /**
     Displays user's location on map. When set to true, permission to device GPS location dialog is presented and access is required.
     */
    public var showUserLocation = false {
        didSet {
            triggerUserLocation(showUserLocation)
        }
    }
    
    /**
        Current map selection mode.
        Map interaction allows user to tap certain objects on map. Place pin and place detail are displayed for selected object.
        - if MapSelectionMode.markers option is set, only customPois markers will interact to user selection
     */
    public var mapSelectionMode: SYMKMapSelectionManager.MapSelectionMode = .markers {
        didSet {
            mapController?.selectionManager?.mapSelectionMode = mapSelectionMode
        }
    }
    
    /**
        Custom pois presented by markers in map.
     */
    public var customMarkers: [SYMKMapPin]? {
        didSet {
            addCustomMarkersToMap()
        }
    }
    
    public var mapSkin: MapSkins = .day {
        didSet {
            mapController?.mapView.activeSkins = [mapSkin.rawValue, userLocationSkin.rawValue]
        }
    }
    
    public var userLocationSkin: UsersLocationSkins = .car {
        didSet {
            mapController?.mapView.activeSkins = [mapSkin.rawValue, userLocationSkin.rawValue]
        }
    }
    
    // MARK: - Private Properties
    
    private var mapController: SYMKMapController?
    private var compassController = SYMKCompassController(course: 0, autoHide: true)
    private var recenterController = SYMKMapRecenterController()
    private var zoomController = SYMKZoomController()
    private var poiDetailViewController: SYUIPoiDetailViewController?
    
    private var mapControls = [MapControl]()
    
    // MARK: - Public Methods
    
    override public func loadView() {
        let browseView = SYMKBrowseMapView()
        if useCompass {
            browseView.setupCompass(compassController.compass)
            mapControls.append(compassController)
        }
        if useRecenterButton {
            browseView.setupRecenter(recenterController.button)
            mapControls.append(recenterController)
        }
        if useZoomControl {
            browseView.setupZoomControl(zoomController.expandableButtonsView)
            mapControls.append(zoomController)
        }
        view = browseView
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        if let map = mapState.map {
            (view as! SYMKBrowseMapView).setupMapView(map)
            map.delegate = mapController
            map.setup(with: mapState)
            map.renderEnabled = true
        }
        super.viewDidAppear(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        mapController?.mapView.renderEnabled = false
        super.viewWillDisappear(animated)
    }
    
    public func addAnnotation(_ annotation: SYAnnotation) {
        mapController?.mapView.addAnnotation(annotation)
    }
    
    public func addAnnotations(_ annotations: [SYAnnotation]) {
        mapController?.mapView.addAnnotations(annotations)
    }
    
    public func dequeueReusableAnnotation(for reuseIdentifier: String) -> SYAnnotationView? {
        return mapController?.mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
    }
    
    public func removeAnnotation(_ annotation: SYAnnotation) {
        mapController?.mapView.removeAnnotation(annotation)
    }
    
    public func removeAnnotations(_ annotations: [SYAnnotation]) {
        mapController?.mapView.removeAnnotations(annotations)
    }
        
    // MARK: - Private Methods
    
    internal override func sygicSDKInitialized() {
        SYOnlineSession.shared().onlineMapsEnabled = true
        triggerUserLocation(showUserLocation)
        setupMapController()
        setupViewDelegates()
    }
    
    internal override func sygicSDKFailure() {
        let alert = UIAlertController(title: "Error", message: "Error during SDK initialization", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
    
    private func setupMapController() {
        let mapController = SYMKMapController(with: mapState, mapFrame: view.bounds)
        mapController.selectionManager = SYMKMapSelectionManager(with: mapSelectionMode)
        mapController.selectionManager?.delegate = self
        mapController.mapView.activeSkins = [mapSkin.rawValue, userLocationSkin.rawValue]
        (view as! SYMKBrowseMapView).setupMapView(mapController.mapView)
        self.mapController = mapController
        addCustomMarkersToMap()
    }
    
    private func setupViewDelegates() {
        compassController.delegate = mapController
        recenterController.delegate = mapController
        zoomController.delegate = mapController
        mapController?.delegate = self
        
    }
    
    private func addCustomMarkersToMap() {
        guard let markers = customMarkers, let mapController = mapController else { return }
        for marker in markers {
            mapController.selectionManager?.addCustomPin(marker)
        }
    }
    
    // MARK: User Location
    
    private func triggerUserLocation(_ show: Bool) {
        guard SYMKSdkManager.shared.isSdkInitialized else { return }
        if show {
            SYPositioning.shared().startUpdatingPosition()
        } else {
            SYPositioning.shared().stopUpdatingPosition()
        }
    }
    
    // MARK: PoiDetail
    
    private func showPoiDetail(with data: SYMKPoiDetailModel) {
        poiDetailViewController = SYMKPoiDetailViewController(with: data)
        poiDetailViewController?.presentPoiDetailAsChildViewController(to: self, bounce: bounceDefaultPoiDetailFirstTime, completion: nil)
        bounceDefaultPoiDetailFirstTime = false
    }
    
    private func hidePoiDetail() {
        guard let poiDetail = poiDetailViewController else { return }
        poiDetail.dismissPoiDetail(completion: { [weak self] _ in
            guard poiDetail == self?.poiDetailViewController else { return }
            self?.poiDetailViewController = nil
        })
    }
}

extension SYMKBrowseMapViewController: SYMKMapViewControllerDelegate {
    
    public func mapController(_ controller: SYMKMapController, didUpdate mapState: SYMKMapState, on mapView: SYMapView) {
        if mapState.cameraMovementMode != .free && !showUserLocation {
            showUserLocation = true
        }
        mapControls.forEach { $0.update(with: mapState) }
    }
    
    public func mapControllerWantsView(for annotation: SYAnnotation) -> SYAnnotationView {
        guard let customAnnotationDelegate = annotationDelegate else { return SYAnnotationView(frame: .zero) }
        return customAnnotationDelegate.browseMapController(self, wantsViewFor: annotation)
    }
    
}

extension SYMKBrowseMapViewController: SYMKMapSelectionDelegate {
    
    public func mapSelectionShouldAddPoiPin() -> Bool {
        return delegate == nil
    }
    
    public func mapSelection(didSelect poiData: SYMKPoiDataProtocol) {
        guard let poiData = poiData as? SYMKPoiData else { return }
        if let delegate = delegate {
            delegate.browseMapController(self, didSelect: poiData)
        } else {
            showPoiDetail(with: poiData)
        }
    }
    
    public func mapSelectionDeselectAll() {
        hidePoiDetail()
    }
    
}
