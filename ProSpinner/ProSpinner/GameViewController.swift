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
    case presentScoreboard  = "presentScoreboard"
    case reloadScoreboard = "reloadScoreboard"
}

class GameViewController: UIViewController
{
    var downloadView: JSSAlertViewResponder?
    var admobManager : AdMobManager?
    var nextScene : SKScene?
    var didCheckSpinnersInThisSession = false
    weak var loadingViewController : LoadingViewController?
    
//  MARK: View's Life cycle
    override func viewDidLoad()
    {
        log.debug()
        super.viewDidLoad()
        loadScene()
        loadingScreenDidFinish()
        addObservers()
        ShareManager.rootViewController = self
    }

    override func viewDidAppear(_ animated: Bool)
    {
        log.debug("")
        super.viewDidAppear(animated)
        loadingViewController?.stopSpinnerRotation()
        loadingViewController = nil
        
        if didCheckSpinnersInThisSession == false
        {
            didCheckSpinnersInThisSession = true
            checkForNewSpinners()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
//  MARK: Private methods
    private func addObservers()
    {
        log.debug("")
        NotificationCenter.default.addObserver(self, selector: #selector(checkForNewSpinners), name: NSNotification.Name(NotifictionKey.checkForNewSpinners.rawValue), object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(presentScoreboard),
                                               name: NSNotification.Name(rawValue: NotificationName.presentScoreboard.rawValue),
                                               object: nil)
    }
    
    func loadingScreenDidFinish()
    {
        log.debug()
        PurchaseManager.rootViewController = self
        admobManager = AdMobManager(rootViewController: self)
    }
    
    func checkForNewSpinners()
    {
        log.debug("")
        guard let status = Network.reachability?.status else { return }
        
        switch status
        {
        case .unreachable: break
        case .wifi,.wwan:
            
            if NetworkManager.currentlyCheckingForNewSpinners == false
            {
                AppDelegate.showToast(withString: nil)
                NetworkManager.checkForNewSpinners()
                    { foundNewSpinners in
                        
                        if foundNewSpinners
                        {
                            let customIcon = UIImage(named: "downloadAlertLogo")
                            let alertview = JSSAlertView().show(
                                self,
                                title: "New Spinners Available !",
                                text: "Be the first to unlock them",
                                buttonText: "Download",
                                color: UIColor(red: 39/255, green: 145/255, blue: 174/255, alpha: 1.0),
                                iconImage: customIcon)
                            
                            alertview.setTextTheme(.light)
                            alertview.addAction(self.beginDownload)
                        }
                }
            }
        }
    }

    private func loadScene()
    {
        log.debug()
        if let sceneNode = nextScene
        {
            switch UIDevice.current.userInterfaceIdiom
            {
                case .pad: sceneNode.scaleMode = .aspectFit
                default: sceneNode.scaleMode = .aspectFill
            }
            
            // Present the scene
            if let view = self.view as? SKView
            {
                view.presentScene(sceneNode)
                view.ignoresSiblingOrder = true
                view.showsFPS = false
                view.showsNodeCount = false
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
    
    func presentScoreboard()
    {
        self.performSegue(withIdentifier: "showScoreboard", sender: nil)
    }
}
