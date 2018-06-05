//
//  ListViewController.swift
//  BodyMeasure
//
//  Created by 岩井 宏晃 on 2018/06/05.
//  Copyright © 2018年 kiizankiizan. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {

    let datas = ImageData.all()
    
    class func create() -> UINavigationController {
        return UIStoryboard(name: "List", bundle: nil).instantiateInitialViewController() as! UINavigationController
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
    
    @IBAction func pushCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
