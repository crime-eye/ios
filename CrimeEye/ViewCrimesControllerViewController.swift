//
//  ViewCrimesControllerViewController.swift
//  CrimeEye
//
//  Created by Kieran Haden on 09/12/2015.
//  Copyright © 2015 Crime Eye. All rights reserved.
//

import UIKit

class ViewCrimesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    // Menu items to display
    var crimes: [Location]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.translucent = false;
        
        mainView.backgroundColor = Style.viewBackground
        tableView.backgroundColor = Style.viewBackground
                
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return crimes!.count;
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
        let mycell = tableView
            .dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath)
            as! CustomTableViewCell
        
        mycell.CrimeText.text = crimes![indexPath.row].category!
        mycell.backgroundColor = Style.viewBackground
            
        return mycell;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
