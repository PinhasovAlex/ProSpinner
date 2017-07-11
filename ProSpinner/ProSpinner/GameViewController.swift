//
//  GameViewController.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 15/05/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds
import JSSAlertView

enum NotificationName: String
{
    case removeDownloadView = "removeDownloadView"
    case notifyWithNewTexture = "notifyWithNewTexture"
    case reloadLockedViewAfterPurchase = "reloadLockedViewAfterPurchase"
}

class GameViewController: UIViewController
{
    var downloadView: JSSAlertViewResponder?
    var admobManager : AdMobManager?
    var nextScene : SKScene?
    weak var loadingViewController : LoadingViewController?
    
//  MARK: View's Life cycle
    override func viewDidLoad()
    {
        log.debug()
        super.viewDidLoad()
        loadScene()
        loadingScreenDidFinish()
        addObservers()
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        loadingViewController?.stopSpinnerRotation()
        loadingViewController = nil
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
//  MARK: Private methods
    private func addObservers()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(checkForNewSpinners), name: NSNotification.Name(NotifictionKey.checkForNewSpinners.rawValue), object: nil)
    }
    
    func loadingScreenDidFinish()
    {
        log.debug()
        PurchaseManager.rootViewController = self
        admobManager = AdMobManager(rootViewController: self)
        checkForNewSpinners()
    }
    
    func checkForNewSpinners()
    {
        if NetworkManager.currentlyCheckingForNewSpinners == false
        {
            ToastController().showToast(inViewController: self)
            NetworkManager.checkForNewSpinners()
                { foundNewSpinners in
                    
                    if foundNewSpinners
                    {
                        let customIcon = UIImage(named: "downloadAlertLogo")
                        let alertview = JSSAlertView().show(
                            self,
                            title: "New Spinners Available !",
                            text: "",
                            buttonText: "Download",
                            cancelButtonText: "Cancel",
                            color: UIColor(red: 69/255, green: 175/255, blue: 224/255, alpha: 1.0),
                            iconImage: customIcon)
                        
                        alertview.setTextTheme(.light)
                        alertview.addAction(self.beginDownload)
                        alertview.addCancelAction {}
                    }
            }
        }
    }

    private func loadScene()
    {
        log.debug()
        if let sceneNode = nextScene
        {
            sceneNode.scaleMode = .aspectFill
            // Present the scene
            if let view = self.view as? SKView
            {
                view.presentScene(sceneNode)
                view.ignoresSiblingOrder = true
                view.showsFPS = true
                view.showsNodeCount = true
            }
        }
    }
        
    func beginDownload()
    {
        log.debug()
        NetworkManager.handleNewSpinnersAvailable()

        if let downloadViewController = storyboard?.instantiateViewController(withIdentifier: "DownloadingViewController")
        {
            self.present(downloadViewController, animated: true, completion: nil)
        }
    }
}
