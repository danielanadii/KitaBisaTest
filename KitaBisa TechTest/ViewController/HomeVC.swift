//
//  ViewController.swift
//  KitaBisa TechTest
//
//  Created by Daniel Anadi on 12/12/20.
//

import UIKit

class HomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var movieCollectionView: UICollectionView!
    
    let apiUrl = "https://api.themoviedb.org/3/movie/popular?api_key=53c147b28a892c1e5df7bb981cda8e15&language=en-US&page=1"
    
    var movies = [MovieObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        getData(url: apiUrl)
        setupNavBar()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = movieCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! movieCell
        
        let movie = movies[indexPath.item]
        
        cell.lblTitle.text = movie.title
        cell.lblRelease.text = movie.release_date
        cell.lblOverview.text = movie.overview
        cell.imgPoster.image = UIImage(named: "loadingImage")
        
        DispatchQueue.main.async() {
            let posterPath = movie.poster_path ?? ""
            
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentCell = movieCollectionView.cellForItem(at: indexPath) as! movieCell
        
        sMovieId = movies[indexPath.item].id
        sMovieTitle = movies[indexPath.item].title
        sMoviePoster = currentCell.imgPoster.image
        sMoviePosterUrl = movies[indexPath.item].poster_path
        sMovieRelease = movies[indexPath.item].release_date
        sMovieOverview = movies[indexPath.item].overview
        
        performSegue(withIdentifier: "movieDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "movieDetailSegue" {
            let dest = segue.destination as! MovieDetailVC
            
            dest.movieId = self.sMovieId
            dest.movieTitle = self.sMovieTitle
            dest.moviePoster = self.sMoviePoster
            dest.movieRelease = self.sMovieRelease
            dest.movieOverview = self.sMovieOverview
            dest.moviePosterUrl = self.sMoviePosterUrl
        }
    }
    
    
    func getData(url: String) {
        movies.removeAll()
        
        let getSession = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            
            guard let data = data, error == nil else {
                print("Error Get Data")
                return
            }
            
            var result: MovieResponse?
            
            do {
                result = try JSONDecoder().decode(MovieResponse.self, from: data)
            } catch {
                print("\(error.localizedDescription)")
            }
            
            guard let json = result else {
                return
            }
            
            for number in 0...json.results.count-1 {
                let movie = MovieObject()
                
                movie.poster_path = json.results[number].poster_path
                movie.adult = json.results[number].adult
                movie.overview = json.results[number].overview
                movie.release_date = json.results[number].release_date
//                movie.genre_ids = json.results[number].genre_ids
                movie.id = json.results[number].id
                movie.original_title = json.results[number].original_title
                movie.original_language = json.results[number].original_language
                movie.title = json.results[number].title
                movie.backdrop_path = json.results[number].backdrop_path
                movie.popularity = json.results[number].popularity
                movie.vote_count = json.results[number].vote_count
                movie.video = json.results[number].video
                movie.vote_average = json.results[number].vote_average
            
                self.movies.append(movie)
            }
            DispatchQueue.main.async {
                self.movieCollectionView.reloadData()
            }
            
        }
        getSession.resume()
        
    }

    @IBAction func btnHeartTapped(_ sender: Any) {
        performSegue(withIdentifier: "likedMovieSegue", sender: self)
    }
    
    @IBAction func btnCategoryTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Popular", style: .default, handler: self.getPopular))
        alertController.addAction(UIAlertAction(title: "Upcoming", style: .default, handler: self.getUpcoming))
        alertController.addAction(UIAlertAction(title: "Top Rated", style: .default, handler: self.getTopRated))
        alertController.addAction(UIAlertAction(title: "Now Playing", style: .default, handler: self.getNowPlaying))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getPopular(alert: UIAlertAction) {
        print("GET Popular")
        let popularUrl = "https://api.themoviedb.org/3/movie/popular?api_key=53c147b28a892c1e5df7bb981cda8e15&language=en-US&page=1"
        
        getData(url: popularUrl)
    }
    func getUpcoming(alert: UIAlertAction) {
        print("GET Upcoming")
        let upcomingUrl = "https://api.themoviedb.org/3/movie/upcoming?api_key=53c147b28a892c1e5df7bb981cda8e15&language=en-US&page=1"
        
        getData(url: upcomingUrl)
    }
    func getTopRated(alert: UIAlertAction) {
        print("GET TopRated")
        let topratedUrl = "https://api.themoviedb.org/3/movie/top_rated?api_key=53c147b28a892c1e5df7bb981cda8e15&language=en-US&page=1"
        
        getData(url: topratedUrl)
    }
    func getNowPlaying(alert: UIAlertAction) {
        print("GET NowPlaying")
        let nowplayingUrl = "https://api.themoviedb.org/3/movie/now_playing?api_key=53c147b28a892c1e5df7bb981cda8e15&language=en-US&page=1"
        
        getData(url: nowplayingUrl)
    }
    
    func setupNavBar() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.3854072237, blue: 0.8392156863, alpha: 1)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "Movie Updates"
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
    }
    
}



