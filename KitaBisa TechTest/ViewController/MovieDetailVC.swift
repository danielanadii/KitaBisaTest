//
//  MovieDetailVC.swift
//  KitaBisa TechTest
//
//  Created by Daniel Anadi on 13/12/20.
//

import UIKit
import CoreData

class MovieDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblReleaseDate: UILabel!
    @IBOutlet weak var lblOverview: UILabel!
    @IBOutlet weak var imgPoster: UIImageView!
    @IBOutlet weak var btnLike: UIButton!
    
    @IBOutlet weak var reviewTableView: UITableView!
    
    var movieId: Int?
    var movieTitle: String?
    var moviePoster: UIImage?
    var moviePosterUrl: String?
    var movieRelease: String?
    var movieOverview: String?
    
    var reviews = [ReviewObject]()
    var movies = [FavMovie]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = movieTitle
        fetchCoreData()
        setupDetailView()
        getReview(movieID: movieId!)
    }
    

    func setupDetailView() {
        imgPoster.image = moviePoster
        lblTitle.text = movieTitle
        lblReleaseDate.text = movieRelease
        lblOverview.text = movieOverview
        
        //To check if the movie is on favorite
        if movies.count != 0 {
            for i in 0...movies.count-1 {
                if movies[i].id == movieId {
                    btnLike.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                }
            }
        }
    }
    
    @IBAction func btnLikeTapped(_ sender: Any) {
        if btnLike.currentImage == UIImage(systemName: "heart.fill") {
            removeFromCoreData(movieId: movieId!)
            
            createAlert(titles: "Success!", message: "This movie has been removed from your favorite list.")
            btnLike.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        else {
            saveMovie(id: movieId!, title: movieTitle!, release: movieRelease!, overview: movieOverview!, posterPath: moviePosterUrl!)
            
            createAlert(titles: "Congratulations!", message: "This movie has successfully added to your favorite list.")
            btnLike.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reviews.count == 0 {
            return 1
        }
        else {
            return reviews.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reviewTableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! reviewCell
        
        if reviews.count > 0 {
            let review = reviews[indexPath.row]
            
            cell.lblUsername.text = "Written by \(review.author ?? "")"
            cell.lblReview.text = review.content
            cell.imgProfile.image = UIImage(named: "loadingImage")
            cell.imgProfile.layer.cornerRadius = 27.5
            
            DispatchQueue.main.async() {
                let avatarPath = review.avatar_path ?? ""
                
                let posterUrl = "https://image.tmdb.org/t/p/w200\(avatarPath)"
                if let url = URL(string: posterUrl) {
                    do {
                        let data = try Data(contentsOf: url)
                        DispatchQueue.main.async {
                            cell.imgProfile.image = UIImage(data: data)
                        }
                    } catch  {
                        cell.imgProfile.image = UIImage(named: "userDefault")
                        print(error.localizedDescription)
                    }
                }
            }
        }
        else {
            cell.lblUsername.text = "Uh Ohh!"
            cell.lblReview.text = "Sorry, there are no review about this movie yet :("
            cell.imgProfile.image = UIImage(systemName: "xmark.circle")
            cell.imgProfile.tintColor = .lightGray
        }
        
        
        return cell
    }
    
    func getReview(movieID: Int) {
        let reviewURL = "https://api.themoviedb.org/3/movie/\(movieID)/reviews?api_key=53c147b28a892c1e5df7bb981cda8e15&language=en-US&page=1"
        
        let getSession = URLSession.shared.dataTask(with: URL(string: reviewURL)!) { data, response, error in
            
            guard let data = data, error == nil else {
                print("Error Get Data")
                return
            }
            
            var result: ReviewResponse?
            
            do {
                result = try JSONDecoder().decode(ReviewResponse.self, from: data)
            } catch {
                print("\(error.localizedDescription)")
            }
            
            guard let json = result else {
                return
            }
            
            if json.results.count != 0 {
                for number in 0...json.results.count-1 {
                    let review = ReviewObject()
                    
                    review.author = json.results[number].author
                    review.content = json.results[number].content
                    review.created_at = json.results[number].created_at
                    review.id = json.results[number].id
                    review.updated_at = json.results[number].updated_at
                    review.url = json.results[number].url
                    review.avatar_path = json.results[number].author_details.avatar_path
                    
                    self.reviews.append(review)
                }
            }
            DispatchQueue.main.async {
                self.reviewTableView.reloadData()
            }
        }
        getSession.resume()
    }
    
    func fetchCoreData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.persistentContainer.viewContext
    
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LikedMovie")
        
        do{
            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            result.forEach{ movie in
                movies.append(
                    FavMovie(
                        id: movie.value(forKey: "id") as! Int,
                        overview: movie.value(forKey: "overview") as! String,
                        poster_path: movie.value(forKey: "poster_path") as! String,
                        release_date: movie.value(forKey: "release_date") as! String,
                        title: movie.value(forKey: "title") as! String)
                )
            }
        }catch let err{
            print(err)
        }
    }

}

extension UIViewController {
    func removeFromCoreData(movieId: Int){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "LikedMovie")
        fetchRequest.predicate = NSPredicate(format: "id = %d", movieId)
        
        do{
            let dataToDelete = try managedContext.fetch(fetchRequest)[0] as! NSManagedObject
            managedContext.delete(dataToDelete)
            
            try managedContext.save()
        }catch let err{
            print(err)
        }
    }
    
    func saveMovie(id: Int, title: String, release: String, overview: String, posterPath: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let userEntity = NSEntityDescription.entity(forEntityName: "LikedMovie", in: managedContext)
        
        let insert = NSManagedObject(entity: userEntity!, insertInto: managedContext)
        insert.setValue(id, forKey: "id")
        insert.setValue(title, forKey: "title")
        insert.setValue(release, forKey: "release_date")
        insert.setValue(overview, forKey: "overview")
        insert.setValue(posterPath, forKey: "poster_path")
    }
    
    func createAlert(titles:String, message:String){
        let alert = UIAlertController(title: titles, message: message, preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
        
        self.present(alert, animated: true, completion: nil);
    }
}
