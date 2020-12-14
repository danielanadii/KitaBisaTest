//
//  LikedMovieVC.swift
//  KitaBisa TechTest
//
//  Created by Daniel Anadi on 14/12/20.
//

import UIKit
import CoreData

class LikedMovieVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var movies = [FavMovie]()

    @IBOutlet weak var likedTableView: UITableView!
    @IBOutlet weak var lblNoData: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        fetchCoreData()
        checkFavData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = likedTableView.dequeueReusableCell(withIdentifier: "likedCell", for: indexPath) as! likedCell
        let movie = movies[indexPath.item]
        
        cell.selectionStyle = .none
        
        cell.lblTitle.text = movie.title
        cell.lblReleaseDate.text = movie.release_date
        cell.lblOverview.text = movie.overview
        
        DispatchQueue.main.async() {
            let posterPath = movie.poster_path 
            
            let posterUrl = "https://image.tmdb.org/t/p/w200\(posterPath)"
            if let url = URL(string: posterUrl) {
                do {
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        cell.imgPoster.image = UIImage(data: data)
                    }
                } catch  {
                    cell.imgPoster.image = UIImage(named: "notAvailable")
                    print(error.localizedDescription)
                }
            }
        }
        
        return cell
    }
    
    var sMovieId: Int?
    var sMovieTitle: String?
    var sMoviePoster: UIImage?
    var sMoviePosterUrl: String?
    var sMovieRelease: String?
    var sMovieOverview: String?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = likedTableView.cellForRow(at: indexPath) as! likedCell
        
        sMovieId = movies[indexPath.item].id
        sMovieTitle = movies[indexPath.item].title
        sMoviePoster = currentCell.imgPoster.image
        sMoviePosterUrl = movies[indexPath.item].poster_path
        sMovieRelease = movies[indexPath.item].release_date
        sMovieOverview = movies[indexPath.item].overview
        
        performSegue(withIdentifier: "detailFromLikeSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeFromCoreData(movieId: movies[indexPath.row].id)
            
            self.movies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            checkFavData()
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailFromLikeSegue" {
            let dest = segue.destination as! MovieDetailVC
            
            dest.movieId = self.sMovieId
            dest.movieTitle = self.sMovieTitle
            dest.moviePoster = self.sMoviePoster
            dest.movieRelease = self.sMovieRelease
            dest.movieOverview = self.sMovieOverview
            dest.moviePosterUrl = self.sMoviePosterUrl
        }
    }
    
    func checkFavData() {
        if movies.count == 0 {
            lblNoData.alpha = 1
        }
        else {
            lblNoData.alpha = 0
        }
    }
}
