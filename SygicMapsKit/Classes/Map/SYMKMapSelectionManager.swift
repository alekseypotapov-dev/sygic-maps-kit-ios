import Foundation
import SygicMaps
import SygicUIKit

public protocol SYMKMapSelectionDelegate: class {
    func mapSelectionShouldAddPoiPin() -> Bool
    func mapSelection(didSelect poiData: SYMKPoiDataProtocol)
    func mapSelectionDeselectAll()
}

public class SYMKMapSelectionManager {
    
    // MARK: - Public Properties
    
    /// Map selection mode
    public enum MapSelectionMode {
        /// No selection
        case none
        /// Allows to select map markers
        case markers
        /// Allows to select anything on map
        case all
    }
    
    public weak var delegate: SYMKMapSelectionDelegate?
    public weak var mapView: SYMapView? {
        didSet {
            setupMarkersClusterIfNeeded()
        }
    }
    public var mapSelectionMode = MapSelectionMode.all
    
    // MARK: - Private Properties
    
    private var mapMarkersManager = SYMKMapMarkersManager<SYMKMapPin>()
    private var customMarkersManager = SYMKMapMarkersManager<SYMKMapPin>()
    private var reverseSearch = SYReverseSearch()
    
    // MARK: - Public Methods
    
    public init(with mode: MapSelectionMode, customMarkers: [SYMKMapPin]? = nil) {
        mapSelectionMode = mode
        
        mapMarkersManager.mapObjectsManager = self
        customMarkersManager.mapObjectsManager = self
        
        customMarkers?.forEach {
            addCustomPin($0)
        }
    }
    
    deinit {
        removeMarkersCluster()
    }
    
    public func selectMapObjects(_ objects: [SYViewObject]) {
        guard mapSelectionMode != .none else { return }
        
        let hadPinSelected = !mapMarkersManager.markers.isEmpty || customMarkersManager.highlightedMarker != nil
        if hadPinSelected {
            mapMarkersManager.removeAllMarkers()
            customMarkersManager.highlightedMarker = nil
            delegate?.mapSelectionDeselectAll()
        }
        
        var viewObj: SYViewObject?
        for obj in objects {
            if let poi = obj as? SYPoiObject, poi.type == .poi, mapSelectionMode == .all {
                selectMapPoi(poi)
                return
            } else if let marker = obj as? SYMapMarker {
                selectCustomMarker(marker)
                return
            } else if mapSelectionMode == .all && viewObj == nil {
                viewObj = obj
            }
        }
        
        guard !hadPinSelected else { return }
        if let coordinate = viewObj?.coordinate {
            selectCoordinate(coordinate)
        }
    }
    
    public func addCustomPin(_ pin: SYMKMapPin) {
        customMarkersManager.addMapMarker(pin)
    }
    
    // MARK: - Private Methods
    
    // MARK: - Marker Cluster
    
    private func setupMarkersClusterIfNeeded() {
        guard let mapView = mapView, mapMarkersManager.clusterLayer == nil else { return }
        let markersCluster = SYMapMarkersCluster()
        mapMarkersManager.clusterLayer = markersCluster
        customMarkersManager.clusterLayer = markersCluster
        mapView.addMapMarkersCluster(markersCluster)
    }
    
    private func removeMarkersCluster() {
        guard let markersCluster = mapMarkersManager.clusterLayer else { return }
        if let clusterMarkers = markersCluster.mapMarkers {
            mapView?.remove(clusterMarkers)
        }
        mapView?.removeMapMarkersCluster(markersCluster)
    }
    
    // MARK: - Selection
    
    private func selectMapPoi(_ poi: SYPoiObject) {
        SYPlaces.shared().loadPoiObjectPlace(poi) { [weak self] (place: SYPlace) in
            self?.selectPlace(with: SYMKPoiData(with: place), category: SYMKPoiCategory.with(syPoiCategory: place.category))
        }
    }
    
    private func selectCoordinate(_ coordinate: SYGeoCoordinate) {
        reverseSearch.reverseSearch(with: coordinate) { [weak self] results in
            guard let result = results.first else { return }
            self?.selectPlace(with: SYMKPoiData(with: result))
        }
    }
    
    private func selectPlace(with poiData: SYMKPoiData, category: SYMKPoiCategory = SYMKPoiCategory(icon: SYUIIcon.POIPoi, color: .action), highlighted: Bool = true) {
        if let delegate = delegate, delegate.mapSelectionShouldAddPoiPin(), let pin = SYMKMapPin(coordinate: poiData.coordinate, icon: category.icon, color: category.color, highlighted: highlighted) {
            mapMarkersManager.addMapMarker(pin)
        }
        delegate?.mapSelection(didSelect: poiData)
    }
    
    private func selectCustomMarker(_ mapMarker: SYMapMarker) {
        guard let customMarker = customMarkersManager.markers.first(where: { $0.mapMarker == mapMarker }) else { return }
        customMarkersManager.highlightedMarker = customMarker
        if let dataPayload = customMarker.data {
            delegate?.mapSelection(didSelect: dataPayload)
        } else {
            delegate?.mapSelection(didSelect: SYMKPoiData(with: customMarker.coordinate))
        }
    }
}

// MARK: - Map Objects Manager

extension SYMKMapSelectionManager: SYMKMapObjectsManager {
    public func addMapObject(_ mapObject: SYMapObject) -> Bool {
        guard let mapView = mapView else { return false }
        mapView.add(mapObject)
        return true
    }
    
    public func removeMapObject(_ mapObject: SYMapObject) {
        mapView?.remove(mapObject)
    }
}
