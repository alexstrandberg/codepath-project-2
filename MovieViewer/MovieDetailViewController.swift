//
//  MovieDetailViewController.swift
//  MovieViewer
//
//  Created by Alexander Strandberg on 6/16/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    var posterURLLow: NSURL?
    var posterURLHigh: NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let posterURLLow = posterURLLow, posterURLHigh = posterURLHigh {
            let smallImageRequest = NSURLRequest(URL: posterURLLow)
            let largeImageRequest = NSURLRequest(URL: posterURLHigh)
            
            self.posterImageView.setImageWithURLRequest(
                smallImageRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    // smallImageResponse will be nil if the smallImage is already available
                    // in cache (might want to do something smarter in that case).
                    self.posterImageView.alpha = 0.0
                    self.posterImageView.image = smallImage;
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        self.posterImageView.alpha = 1.0
                        
                        }, completion: { (sucess) -> Void in
                            
                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                            // per ImageView. This code must be in the completion block.
                            self.posterImageView.setImageWithURLRequest(
                                largeImageRequest,
                                placeholderImage: smallImage,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    
                                    self.posterImageView.image = largeImage;
                                    
                                },
                                failure: { (request, response, error) -> Void in
                                    // do something for the failure condition of the large image request
                                    // possibly setting the ImageView's image to a default image
                                    self.view.backgroundColor = UIColor.grayColor()
                                    
                                    self.posterImageView.alpha = 0.0
                                    self.posterImageView.image = UIImage(named: "networkErrorIcon")
                                    
                                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                                        self.posterImageView.alpha = 1.0
                                    })
                            })
                    })
                },
                failure: { (request, response, error) -> Void in
                    // do something for the failure condition
                    // possibly try to get the large image
                    self.view.backgroundColor = UIColor.grayColor()
                    
                    self.posterImageView.alpha = 0.0
                    self.posterImageView.image = UIImage(named: "networkErrorIcon")
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.posterImageView.alpha = 1.0
                    })
            })
        }
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
