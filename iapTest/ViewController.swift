//
//  ViewController.swift
//  iapTest
//
//  Created by YooSeunghwan on 2017/12/04.
//  Copyright © 2017年 eys-style. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController,PurchaseManagerDelegate {

    @IBOutlet weak var mainTableView: UITableView!
    
    let productIdentifiers : [String] = ["inapppurchase1","inapppurchase2","inapppurchase3","inapppurchase4"]
    var productItems = [AnyObject]()
    
    private var refreshControl:UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        // プロダクト情報取得
        fetchProductInformationForIds(productIdentifiers)
        
        mainTableView.frame.size.width = self.view.bounds.size.width
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
//        mainTableView.estimatedRowHeight = 100
//        mainTableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        mainTableView.addSubview(refreshControl)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refresh() {
        
        if productItems.count > 0 {
            productItems.removeAll()
        }        
        fetchProductInformationForIds(productIdentifiers)
        
        refreshControl.endRefreshing()
    }
    
    @IBAction func purchaseButtonTapped(_ sender: AnyObject) {
        startPurchase(productIdentifier: productIdentifiers[sender.tag])
    }
    //------------------------------------
    // 課金処理開始
    //------------------------------------
    func startPurchase(productIdentifier : String) {
        print("課金処理開始!!")
        //デリゲード設定
        PurchaseManager.sharedManager().delegate = self
        //プロダクト情報を取得
        ProductManager.productsWithProductIdentifiers(productIdentifiers: [productIdentifier], completion: { (products, error) -> Void in
            if (products?.count)! > 0 {
                //課金処理開始
                PurchaseManager.sharedManager().startWithProduct((products?[0])!)
            }
            if (error != nil) {
                print(error ?? NSError.self)
            }
        })
    }
    // リストア開始
    func startRestore() {
        //デリゲード設定
        PurchaseManager.sharedManager().delegate = self
        //リストア開始
        PurchaseManager.sharedManager().startRestore()
    }
    //------------------------------------
    // MARK: - PurchaseManager Delegate
    //------------------------------------
    //課金終了時に呼び出される
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("課金終了！！")
        //---------------------------
        // コンテンツ解放処理
        //---------------------------
        // TODO UserDefault更新
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    //課金終了時に呼び出される(startPurchaseで指定したプロダクトID以外のものが課金された時。)
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("課金終了（指定プロダクトID以外）！！")
        //---------------------------
        // コンテンツ解放処理
        //---------------------------
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    //課金失敗時に呼び出される
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFailWithError error: NSError!) {
        print("課金失敗！！")
        // TODO errorを使ってアラート表示
    }
    // リストア終了時に呼び出される(個々のトランザクションは”課金終了”で処理)
    func purchaseManagerDidFinishRestore(_ purchaseManager: PurchaseManager!) {
        print("リストア終了！！")
        // TODO インジケータなどを表示していたら非表示に
    }
    // 承認待ち状態時に呼び出される(ファミリー共有)
    func purchaseManagerDidDeferred(_ purchaseManager: PurchaseManager!) {
        print("承認待ち！！")
        // TODO インジケータなどを表示していたら非表示に
    }
    // プロダクト情報取得
    fileprivate func fetchProductInformationForIds(_ productIds:[String]) {
        ProductManager.productsWithProductIdentifiers(productIdentifiers: productIds,completion: {[weak self] (products : [SKProduct]?, error : NSError?) -> Void in
            if error != nil {
                if self != nil {
                }
                print(error?.localizedDescription ?? "")
                return
            }
            for product in products! {
                print("localizedTitle? \(product.localizedTitle)")
                print("localizedDescription? \(product.localizedDescription)")
                print("price? \(product.price)")
                print("isDownloadable? \(product.priceLocale)")
                let priceString = ProductManager.priceStringFromProduct(product: product)
                let item: Dictionary = ["title":product.localizedTitle, "description":product.localizedDescription, "price": priceString, "isDownloadable": product.isDownloadable] as [String : Any]
                self?.productItems.append(item as AnyObject)
            }
            
            self?.mainTableView.reloadData()
        })
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyCustomCell = tableView.dequeueReusableCell(withIdentifier: "MyCustomCell") as! MyCustomCell
        
        let item = productItems[indexPath.row]
        
        if let title = item["title"], let desc = item["description"], let price = item["price"] {
            cell.setCell(title as! String, desc as! String, price as! String)
        }
        cell.buyBtn.tag = indexPath.row
        
        return cell
    }
}
