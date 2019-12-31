//
//  ViewController.swift
//  imageDetectAR
//
//  Created by MAC on 27/12/2019.
//  Copyright © 2019 EdJordan. All rights reserved.
//

import UIKit
import ARKit


class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    let updateQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).serialSCNQueue")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.showsStatistics = true
        
        sceneView.delegate = self 
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
     
    }

      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)

          guard let refImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) else {
                  fatalError("Missing expected asset catalog resources.")
          }

          // Create a session configuration
          let configuration = ARImageTrackingConfiguration()
          configuration.trackingImages = refImages
          configuration.maximumNumberOfTrackedImages = 1

          // Run the view's session
          sceneView.session.run(configuration, options: ARSession.RunOptions(arrayLiteral: [.resetTracking, .removeExistingAnchors]))
      }
    
       override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)

           // Pause the view's session
           sceneView.session.pause()
       }
}

