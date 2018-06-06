//
//  ViewController.swift
//  BodyMeasure
//
//  Created by 岩井 宏晃 on 2018/06/04.
//  Copyright © 2018年 kiizankiizan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ListViewControllerDelegate {

    private var measureVc: MeasureViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MeasureViewController {
            measureVc = vc
        }
    }

    @IBAction func pushCameraButton(_ sender: Any) {
        present(CameraViewController.create(), animated: true, completion: nil)
    }
    
    @IBAction func pushListButton(_ sender: Any) {
        present(ListViewController.create(delegate: self), animated: true, completion: nil)
    }
    
    func listViewController(_ vc: ListViewController, didSelect frontImage: UIImage?, sideImage: UIImage?) {
        measureVc.updateImage(frontImage: frontImage, sideImage: sideImage)
    }
}

