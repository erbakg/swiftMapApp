//
//  ViewController.swift
//  TestMapApp
//
//  Created by Erbol on 23.02.2022.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    let mapView : MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    let addAddressButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "addAddress"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let routeButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "route"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let resetButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "reset"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    var annotationsArray = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        setConstraints()
        
        addAddressButton.addTarget(self, action: #selector(addAddressTapped), for: .touchUpInside)
        
        routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
        
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
    }
    
    @objc func addAddressTapped(){
        
        alertAddAddress(title: "Add address", placeholder: "Enter your address") {[self] (text) in
            setupPlacemark(address: text)
        }
        
    }
    
    @objc func routeButtonTapped(){
       
        for index in 0...annotationsArray.count - 2 {
            createDirectionRoad(startCoordinate: annotationsArray[index].coordinate, destiantionCoordinate: annotationsArray[index + 1].coordinate)
        }
        
        mapView.showAnnotations(annotationsArray, animated: true)
        
    }
    
    @objc func resetButtonTapped(){
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationsArray = [MKPointAnnotation]()
        routeButton.isHidden = true
        resetButton.isHidden = true
    }
    
    private func setupPlacemark(address: String) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { [self] (placemarks, error) in
            if let error = error {
                print(error)
                alertError(title: "Error", message: "Error in server. Please try again" )
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(address)"
            
            guard let placemarkLocataion = placemark?.location else { return }
            annotation.coordinate = placemarkLocataion.coordinate
            
            annotationsArray.append(annotation)
            
            if annotationsArray.count > 2 {
                routeButton.isHidden = false
                resetButton.isHidden = false
            }
            mapView.showAnnotations(annotationsArray, animated: true)
        }
        
    }
    
    private func createDirectionRoad(startCoordinate: CLLocationCoordinate2D, destiantionCoordinate: CLLocationCoordinate2D) {
        
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destiantionCoordinate)
        
        let road = MKDirections.Request()
        road.source = MKMapItem(placemark: startLocation)
        road.destination = MKMapItem(placemark: destinationLocation)
        road.transportType = .walking
        road.requestsAlternateRoutes = true
        
        let directon = MKDirections(request: road)
        print(directon)
        directon.calculate {[self] (response, error) in
            
            if let error = error {
                print(error)
                alertError(title: "Error", message: "Error in making road" )
                return
            }
            
            guard let response = response else {
                self.alertError(title: "Error", message: "Road is not usable" )
                return
            }
            
            var minRoute = response.routes[0]
            for route in response.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            self.mapView.addOverlay(minRoute.polyline)
        }
    }
}

extension ViewController: MKMapViewDelegate {
     
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        return renderer
    }
    
}

extension ViewController {
    func setConstraints() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        mapView.addSubview(addAddressButton)
        NSLayoutConstraint.activate([
            addAddressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            addAddressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            addAddressButton.heightAnchor.constraint(equalToConstant: 70),
            addAddressButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        mapView.addSubview(resetButton)
        NSLayoutConstraint.activate([
            resetButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -70),
            resetButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            resetButton.heightAnchor.constraint(equalToConstant: 100),
            resetButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        mapView.addSubview(routeButton)
        NSLayoutConstraint.activate([
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -70),
            routeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            routeButton.heightAnchor.constraint(equalToConstant: 100),
            routeButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
}
