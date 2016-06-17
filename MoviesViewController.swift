//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Alexander Strandberg on 6/15/16.
//  Copyright © 2016 Alexander Strandberg. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var networkErrorView: NetworkErrorView!
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    
    var firstLoadDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true // Needed to fix bug where user couldn't refresh when there were no movies
        
        searchBar.delegate = self
        
        networkErrorView = NetworkErrorView(frame: CGRect(x: 0, y: 0, width: 375, height: 44))
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(networkErrorView, atIndex: 0)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        refreshControlAction(refreshControl)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = filteredMovies![indexPath.row]
        
        if let posterPath = movie["poster_path"] as? String {
            let posterBaseURL = "http://image.tmdb.org/t/p/w500"
            let posterURL = NSURL(string: posterBaseURL + posterPath)
            
            let imageRequest = NSURLRequest(URL: posterURL!)
            
            cell.posterView.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        cell.posterView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
            
        }
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.posterView.image = nil
        }
        
        return cell
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        // ... Create the NSURLRequest (myRequest) ...
        let apiKey = "913e82319bc3dfdc258ee027afa67cf3"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made - only for initial loading
        if !firstLoadDone {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
          completionHandler: { (data, response, error) in
            
            // Hide HUD once the network request comes back (must be done on main UI thread) - only for initial loading
            if !self.firstLoadDone {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.firstLoadDone = true
            }
            
            // ... Remainder of response handling code ...
            if let data = data {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data, options:[]) as? NSDictionary {
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    self.filteredMovies = self.movies
                }
            } else {
                UIView.animateWithDuration(0.3, delay:0, options:UIViewAnimationOptions.TransitionFlipFromTop, animations: {
                    self.networkErrorView.alpha = 1
                    }, completion: { finished in
                })
                UIView.animateWithDuration(0.3, delay:3.3, options:UIViewAnimationOptions.TransitionFlipFromTop, animations: {
                    self.networkErrorView.alpha = 0
                    }, completion: { finished in
                })
            }
            
            // Reload the tableView now that there is new data
            self.collectionView.reloadData()
            
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
            
            if let text = self.searchBar.text {
                self.filterData(text)
            }
            
        });
        task.resume()
    }
    
    // This method updates filteredMovies based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterData(searchText)
    }
    
    func filterData(searchText: String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            if let movies = movies {
                filteredMovies = movies.filter({(movie: NSDictionary) -> Bool in
                    // If title matches the searchText, return true to include it
                    if let title = movie["title"] as? String {
                        if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                            return true
                        } else {
                            return false
                        }
                    } else {
                        return false
                    }
                })
            }
        }
        collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        filterData("")
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        let vc = segue.destinationViewController as! MovieDetailViewController
        let indexPath = collectionView.indexPathForCell(sender as! UICollectionViewCell)
        
        let movie = filteredMovies![indexPath!.row]
        
        vc.movieTitle = movie["title"] as? String
        vc.moviedOverview = movie["overview"] as? String
        
        if let posterPath = movie["poster_path"] as? String {
            let posterBaseURLLow = "http://image.tmdb.org/t/p/w45"
            let posterBaseURLHigh = "http://image.tmdb.org/t/p/original"
            let posterURLLow = NSURL(string: posterBaseURLLow + posterPath)
            let posterURLHigh = NSURL(string: posterBaseURLHigh + posterPath)
            vc.posterURLLow = posterURLLow
            vc.posterURLHigh = posterURLHigh
        }
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            vc.posterURLLow = nil
            vc.posterURLHigh = nil
        }
     }
    
}
