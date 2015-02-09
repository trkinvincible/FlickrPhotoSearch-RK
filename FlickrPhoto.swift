//
//  FlickrPhoto.swift
//  FlickrSearch
//
//  Created by Student on 17/11/36 SAKA.
//  Copyright (c) 1936 SAKA Razeware. All rights reserved.
//

import UIKit

class FlickrPhoto {
    
    var farm: Int = 0
    var server: String = ""
    var secret: String = ""
    var photoID: String = ""
    var title:String = ""
    var comments:String = ""
    
    var image: UIImage?
    var thumbnail: UIImage?
    var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as String;
    
    init(){
        
    }
    
    class func createFromJSON(photoDict: NSDictionary) -> FlickrPhoto {
        var flickrPhoto:FlickrPhoto = FlickrPhoto()
        flickrPhoto.farm = photoDict.objectForKey("farm") as Int
        flickrPhoto.server = photoDict.objectForKey("server") as String
        flickrPhoto.secret = photoDict.objectForKey("secret") as String
        flickrPhoto.photoID = photoDict.objectForKey("id") as String
        flickrPhoto.title = photoDict.objectForKey("title") as String
        
        return flickrPhoto
    }
    
    enum PhotoResult {
        case Image(UIImage)
        case Error
    }
    typealias PhotoCompletion = (result: PhotoResult) -> Void
    
    
    func loadImage(thumbnail: Bool, completion: PhotoCompletion) {
        
        if secret.isEmpty{
            var photoDir = paths.stringByAppendingPathComponent(title);
            var image : UIImage = UIImage(named: photoDir)!;
            completion(result: .Image(image))
        }
        
        if self.image != nil && !thumbnail {
            completion(result: .Image(self.image!))
        } else if self.thumbnail != nil && thumbnail {
            completion(result: .Image(self.thumbnail!))
        }
        
        let size = thumbnail ? "m" : "b"
        
        let photoURLString = "http://farm\(self.farm).staticflickr.com/\(self.server)/\(self.photoID)_\(self.secret)_\(size).jpg"
        let request = NSURLRequest(URL: NSURL(string: photoURLString)!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) in
            if data != nil {
                if let image = UIImage(data: data) {
                    if thumbnail {
                        self.thumbnail = image
                    } else {
                        self.image = image
                    }
                    completion(result: .Image(image))
                } else {
                    completion(result: .Error)
                }
            } else {
                completion(result: .Error)
            }
        }
    }
    
    func SaveImage(completion: PhotoCompletion){


        
    }
}
