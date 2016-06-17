//
//  NetworkErrorView.swift
//  MovieViewer
//
//  Created by Alexander Strandberg on 6/16/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit

class NetworkErrorView: UIView {
    
    var networkImageView: UIImageView!
    var networkLabel: UILabel!
    override init(frame: CGRect) {
        
        super.init(frame:frame)
        
        alpha = 0
        backgroundColor = UIColor.grayColor()
        
        networkLabel = UILabel(frame: CGRect(x: 162, y: 11, width: 119, height: 21))
        networkLabel.text = "Network Error"
        networkLabel.textColor = UIColor.whiteColor()
        addSubview(networkLabel)
        
        networkImageView = UIImageView(frame: CGRect(x: 114, y: 0, width: 40, height: 44))
        networkImageView.image = UIImage(named: "networkErrorIcon")
        addSubview(networkImageView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
