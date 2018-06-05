//
//  ListViewController.swift
//  BodyMeasure
//
//  Created by 岩井 宏晃 on 2018/06/05.
//  Copyright © 2018年 kiizankiizan. All rights reserved.
//

import UIKit

protocol ListViewControllerDelegate: class {
    func listViewController(_ vc: ListViewController, didSelect frontImage: UIImage?, sideImage: UIImage?)
}

class ListViewController: UITableViewController {

    let datas = ImageData.all()
    private var delegate: ListViewControllerDelegate?
    
    class func create(delegate: ListViewControllerDelegate?) -> UINavigationController {
        let navi = UIStoryboard(name: "List", bundle: nil).instantiateInitialViewController() as! UINavigationController
        
        let vc = navi.topViewController as! ListViewController
        vc.delegate = delegate
        
        return navi
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListTableViewCell
        
        let data = datas[indexPath.row]
        
        if let frontImageData = data.frontImage {
            cell.frontImage.image = UIImage(data: frontImageData)
        }
        
        if let sideImageData = data.sideImage {
            cell.sideImage.image = UIImage(data: sideImageData)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = datas[indexPath.row]
        
        let frontImage = data.frontImage == nil ? nil : UIImage(data: data.frontImage!)
        let sideImage = data.sideImage == nil ? nil : UIImage(data: data.sideImage!)
        
        delegate?.listViewController(self, didSelect: frontImage, sideImage: sideImage)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pushCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
