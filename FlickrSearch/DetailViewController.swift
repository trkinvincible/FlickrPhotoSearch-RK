
import UIKit
import Social

class ImageCell: UICollectionViewCell {
  
  @IBOutlet var imageView: UIImageView!
  
}

class DetailViewController: UIViewController {
  
  @IBOutlet var collectionView: UICollectionView!
  
    var photos: [FlickrPhoto] = []
    var count : Int = 0;
    let longPressRec = UILongPressGestureRecognizer()
    var largephoto:NSIndexPath!;
    var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        longPressRec.addTarget(self, action: "longPressedView")
        self.collectionView?.addGestureRecognizer(longPressRec);
        self.collectionView?.userInteractionEnabled = true;
    }
    
    var largePhotoIndexPath : NSIndexPath? {
        didSet {
            //2
            var indexPaths = [NSIndexPath]()
            if largePhotoIndexPath != nil {
                indexPaths.append(largePhotoIndexPath!)
            }
            if oldValue != nil {
                indexPaths.append(oldValue!)
            }
            //3
            collectionView?.performBatchUpdates({
                self.collectionView?.reloadItemsAtIndexPaths(indexPaths)
                return
                }){
                    completed in
                    //4
                    if self.largePhotoIndexPath != nil {
                        self.collectionView?.scrollToItemAtIndexPath(
                            self.largePhotoIndexPath!,
                            atScrollPosition: .CenteredVertically,
                            animated: true)
                    }
            }
        }
    }
    
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)

}

extension DetailViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,UICollectionViewDelegate ,UIAlertViewDelegate{
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.photos.count
  }
  
  func collectionView(collectionView: UICollectionView,
        shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            if largePhotoIndexPath == indexPath {
                largePhotoIndexPath = nil
            }
            else {
                largePhotoIndexPath = indexPath
                largephoto = indexPath;
            }
            
            return false
    }
    
    func collectionView(collectionView: UICollectionView!,
        layout collectionViewLayout: UICollectionViewLayout!,
        sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
            if indexPath == largePhotoIndexPath {
                return CGSize(width: 350, height: 350)
            }
            return CGSize(width: 135, height: 135)
    }
    
    
    func collectionView(collectionView: UICollectionView!,
        layout collectionViewLayout: UICollectionViewLayout!,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }
    
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    println("Enter collectionView");
    let imageCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as ImageCell

    let photo = self.photos[indexPath.row]
    println(photos);
    if indexPath != self.largePhotoIndexPath {
            photo.loadImage(true) {
                    switch $0 {
                    case .Error:
                        break
                    case .Image(let image):
                        imageCell.imageView.image = image
                        
                    }
                }
        }
        else if indexPath == self.largePhotoIndexPath{
            photo.loadImage(false) {
                    switch $0 {
                    case .Error:
                        break
                    case .Image(let image):
                        imageCell.imageView.image = image
                    }
                }
        }
    
        return imageCell
    }
    
    func longPressedView()
    {
        if count == 0{
            count++;
            if largePhotoIndexPath == nil{
                return;
            }
        }else{
            count = 0;
            return ;
        }
        
        let alert = UIAlertController(title: "Choose Action", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let fbbutton = UIAlertAction(title: "Post in FaceBook", style: UIAlertActionStyle.Default) { (alert) -> Void in
            
            if(SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook))
            {
                var imageptr:UIImage!;
                let photo = self.photos[self.largephoto.row]
                photo.loadImage(false) {
                    switch $0 {
                    case .Error:
                        break
                    case .Image(let image):
                        imageptr = image as UIImage
                    }
                }
                var controller = SLComposeViewController(forServiceType: SLServiceTypeFacebook);
                controller.setInitialText("Sharing to Facebook");
                controller.addImage(imageptr);
                self.presentViewController(controller ,animated : true , completion : nil);
            }
            else
            {
                var alert = UIAlertController(title: "Sign in", message: "No facebook account found", preferredStyle: UIAlertControllerStyle.Alert);
                let CancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
                }
                alert.addAction(CancelButton)
                self.presentViewController(alert , animated : true , completion : nil);
            }
            println("Posted in FaceBook");
        }
        if !self.photos[self.largephoto.row].secret.isEmpty{
            let SaveButton = UIAlertAction(title: "Save To Favourites", style: UIAlertActionStyle.Default) { (alert) -> Void in
                
                var alert = UIAlertView()
                    alert.title = "Please Enter Comments"
                    alert.addButtonWithTitle("Done")
                    alert.delegate = self;
                    alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
                    alert.show();
                }
            alert.addAction(SaveButton)
        }
        
        if self.photos[self.largephoto.row].secret.isEmpty{
            let EditButton = UIAlertAction(title: "Edit Comment", style: UIAlertActionStyle.Default) { (alert) -> Void in
                
                var alert = UIAlertView()
                alert.title = "Please Enter Comments"
                alert.addButtonWithTitle("Done")
                alert.delegate = self;
                alert.textFieldAtIndex(0)?.text? = (self.photos[self.largephoto.row].comments as String);                println(self.photos[self.largephoto.row].comments);
                println(alert.textFieldAtIndex(0)?.text);
                alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
                alert.show();
            }
            alert.addAction(EditButton)
            
            let deleteButton = UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.Default) { (alert) -> Void in
                let photo = self.photos[self.largephoto.row]
                var dbDir = self.paths.stringByAppendingPathComponent("photoDetails.sqlite");
                var dbhelper:SqLiteHelper = SqLiteHelper();
                dbhelper.open(dbDir);
                dbhelper.deletePhoto(photo.title)
            }
            alert.addAction(deleteButton)
        }
    
        alert.addAction(fbbutton)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        
        var selectedtext = alertView.textFieldAtIndex(0)?.text;
        
        var dbDir = paths.stringByAppendingPathComponent("photoDetails.sqlite");
        var dbhelper:SqLiteHelper = SqLiteHelper();
        dbhelper.open(dbDir);
        var imageptr:UIImage!;
        let photo = self.photos[self.largephoto.row]
        photo.loadImage(false) {
            switch $0 {
            case .Error:
                break
            case .Image(let image):
                imageptr = image as UIImage
            }
        }
        var photoDir = paths.stringByAppendingPathComponent(photo.title+".jpg");
        var data : NSData = UIImagePNGRepresentation(imageptr);
        var photosarray = dbhelper.selectPhoto()
        for fp in photosarray{
            if photo.title == fp.title{
             dbhelper.updatePhoto(photo.title, comment: selectedtext!)
             return;
            }
        }
        dbhelper.createPhoto(photo.title+".jpg", comment: selectedtext!);
        data.writeToFile(photoDir, atomically: true);
        println("Saved to Favourites");
    }
}

