//
//  ViewControllerActionAR.swift
//  imageDetectAR
//
//  Created by MAC on 27/12/2019.
//  Copyright © 2019 EdJordan. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
//import WebKit


extension ViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        updateQueue.async {
            let physicalWidth = imageAnchor.referenceImage.physicalSize.width
            let physicalHeight = imageAnchor.referenceImage.physicalSize.height
            
            // Create a plane geometry to visualize the initial position of the detected image
            let mainPlane = SCNPlane(width: physicalWidth, height: physicalHeight)
            mainPlane.firstMaterial?.colorBufferWriteMask = .alpha
            
            // Create a SceneKit root node with the plane geometry to attach to the scene graph
            // This node will hold the virtual UI in place
            let mainNode = SCNNode(geometry: mainPlane)
            mainNode.eulerAngles.x = -.pi / 2
            mainNode.renderingOrder = -1
            mainNode.opacity = 1
            
            // Add the plane visualization to the scene
            node.addChildNode(mainNode)
            
            // Perform a quick animation to visualize the plane on which the image was detected.
            // We want to let our users know that the app is responding to the tracked image.
            self.highlightDetection(on: mainNode, width: physicalWidth, height: physicalHeight, completionHandler: {
                
                // Introduce virtual content
//                self.displayDetailView(on: mainNode, xOffset: physicalWidth)
                
                // Animate the WebView to the right
                self.displayWebView(on: mainNode, xOffset: physicalWidth)
                
            })
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - SceneKit Helpers
    

    
    func displayWebView(on rootNode: SCNNode, xOffset: CGFloat) {
        // Xcode yells at us about the deprecation of UIWebView in iOS 12.0, but there is currently
        // a bug that does now allow us to use a WKWebView as a texture for our webViewNode
        // Note that UIWebViews should only be instantiated on the main thread!
      DispatchQueue.main.async {
            let request = URLRequest(url: URL(string: "https://www.uvinum.es/vino-vt-castilla/solaz-tempranillo-cabernet-2018?gaw=1&awc=16985_1577794256_070d77b41fcabd398cf179fddec43471&utm_campaign=afiliados&utm_source=awin-es")!)
    
//            let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 400, height: 672))
//            webView.load(request)
            
            
            let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 400, height: 972))
            webView.loadRequest(request)
                        
        let webViewPlane = SCNPlane(width: xOffset, height: xOffset * 2.5)
            webViewPlane.cornerRadius = 0.10
            
            let webViewNode = SCNNode(geometry: webViewPlane)
            webViewNode.geometry?.firstMaterial?.diffuse.contents = webView
            webViewNode.position.z -= 0.5
            webViewNode.opacity = 0
            
            rootNode.addChildNode(webViewNode)
            webViewNode.runAction(.sequence([
                .wait(duration: 3.0),
                .fadeOpacity(to: 1.0, duration: 1.5),
                .moveBy(x: xOffset * 1.1, y: 0, z: -0.05, duration: 1.5),
                .moveBy(x: 0, y: 0, z: -0.05, duration: 0.2)
                ])
            )
        }
    }
    
    func highlightDetection(on rootNode: SCNNode, width: CGFloat, height: CGFloat, completionHandler block: @escaping (() -> Void)) {
        let planeNode = SCNNode(geometry: SCNPlane(width: width, height: height))
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        planeNode.position.z += 0.1
        planeNode.opacity = 0
        
        rootNode.addChildNode(planeNode)
        planeNode.runAction(self.imageHighlightAction) {
            block()
        }
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
            ])
    }

}
