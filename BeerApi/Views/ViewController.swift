//
//  ViewController.swift
//  BeerApi
//
//  Created by André Brilho on 07/08/2018.
//  Copyright © 2018 André Brilho. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    var beers:[Beer] = []
    @IBOutlet weak var tbl: UITableView!
    var finished:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbl.register(UINib(nibName: "BeerTableViewCell", bundle: nil), forCellReuseIdentifier: "BeerTableViewCell")
        tbl.dataSource = self
        tbl.delegate = self
        getBeers()
    }
    
    func getBeers(){
        BeersApi.fetchBeers(refresh: false, sucess: { (beer) in
            self.beers = beer
            DispatchQueue.main.async {
                self.tbl.reloadData()
            }
        }) { (error) in
            print("errro")
        }
    }
    
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tbl.dequeueReusableCell(withIdentifier: "BeerTableViewCell", for: indexPath) as! BeerTableViewCell
            cell.beer = beers[indexPath.row]
            return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        do {
            AppDelegate.realmBeerBD.beginWrite()
            let beer = beers[indexPath.row]
            AppDelegate.realmBeerBD.delete(beer)
            try
            AppDelegate.realmBeerBD.commitWrite()
            beers.remove(at: indexPath.row)
            tbl.reloadData()
        }catch {
            print("erro ao excluir elemento")
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let beerDetailCarroViewController = storyboard?.instantiateViewController(withIdentifier: "BeerDetalheViewController") as? BeerDetalheViewController {
            beerDetailCarroViewController.beer = beers[indexPath.row]
            self.present(beerDetailCarroViewController, animated: true)

        }
}
    
    @IBAction func updateBeers(_ sender: Any) {
        do {
            AppDelegate.realmBeerBD.beginWrite()
            let beers = AppDelegate.realmBeerBD.objects(Beer.self)
            AppDelegate.realmBeerBD.delete(beers)
            try AppDelegate.realmBeerBD.commitWrite()
            BeersApi.fetchBeers(refresh: false, sucess: { (beer) in
                self.beers = beer
                DispatchQueue.main.async {
                    self.tbl.reloadData()
                }
            }) { (error) in
                print("errro")
            }
        }catch {
            print("Erro ao excluir BD para fazer o Sync novamente")
        }
    }
    
    
}
