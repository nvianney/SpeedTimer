//
//  MoreViewController.swift
//  SpeedTimer
//
//  Created by Vianney Nguyen on 2016-05-01.
//  Copyright © 2016 Paperatus. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {
    @IBOutlet weak var settingsButton: UIView!
    @IBOutlet weak var algorithmsButton: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        tabBarController?.tabBar.backgroundImage = nil
        
        let settingsTapListener = UITapGestureRecognizer(target: self, action: #selector(buttonTapped(_:)))
        settingsButton.addGestureRecognizer(settingsTapListener)
        
        let algorithmTapListener = UITapGestureRecognizer(target: self, action: #selector(buttonTapped(_:)))
        algorithmsButton.addGestureRecognizer(algorithmTapListener)
    }
    
    @objc func buttonTapped(_ sender:UITapGestureRecognizer) {
        if (sender.view === settingsButton) {
            performSegue(withIdentifier: "settingsSegue", sender: self)
        } else if (sender.view == algorithmsButton) {
            performSegue(withIdentifier: "algorithmsSegue", sender: self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
