//
//  ViewController.swift
//  ExchangeRateApp
//
//  Created by Mac12 on 9.06.2021.
//  Copyright © 2021 Trakya University. All rights reserved.
//

import UIKit

//UITableViewDataSource: Bir nesnenin verileri yönetmek ve bir tablo görünümü 
için hücreler sağlamak için benimsediği yöntemdir.

//UITableViewDelegate: Tablo görünümünde seçimleri yönetme, bölüm üstbilgilerini ve altbilgilerini yapılandırma, 
hücreleri silme ve yeniden sıralama ve diğer eylemleri gerçekleştirme yöntemleri.

//XMLParserDelegate: Bir XML ayrıştırıcısının, temsilcisini ayrıştırılan belgenin 
içeriği hakkında bilgilendirmek için kullandığı arabirim.

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, XMLParserDelegate {

    @IBOutlet weak var tblView: UITableView!  //tableview yarattık buraya bağladık.
    
    var parser = XMLParser()  //xml parçalama işlemi yaparken kullanacağız gerekli.
    var kurlar = NSMutableArray() //kurlar adında dizi tanımladım. NSmutablearray tarzında.
    var elements = NSMutableDictionary() //elementlerimizi bir sözlük yapısında tanımlıyoruz.
    var element = NSString() //elemanları oluşturan elementler var NSString türünde tanımladık.
    var currencyName = NSMutableString() //xmldeki currentName'i string türünde yazdırıyoruz.
    var forexBuying = NSMutableString() //xmldeki forexBuying string türünde tanımlıyoruz.
    var anaDeger: Double = 1.0  //kurların ilk anadegerini burada double ve başlangıcı 1.0 olarak veriyoruz.
    
    
    //mainstoryboardda oluşturduğumuz btnCalculate butonunu buraya bağladık.
    //eger textFieldValuedeki text string ise double türüne çevirelim.ana degeri double a çeviriyoruz.
    //parsingDataFromUrl fonsiyonunu çeviriyoruz.

    @IBAction func btnCalculate(_ sender: UIButton) {
        if let iGetString = textFieldValue.text{
            if let isDouble = Double(iGetString){
                anaDeger = isDouble
                parsingDataFromURL()
            }
            
        }
        
    }
    
    @IBOutlet weak var textFieldValue: UITextField!  //textfieldı buraya bağladık.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parsingDataFromURL()  //bu fonksiyonu burada tanımlıyoruz ki ilk yüklenirken bu fonksiyonu çagır diyoruz ekranda ulaşabilelim kurlar bilgisine diye.
        textFieldValue.textAlignment = .center
        tblView.dataSource = self
        tblView.allowsSelection = false
        tblView.showsVerticalScrollIndicator = false
        
    }
    
//urlden parser yapacak fonksiyon
    //bu aşamada xmlparser tanımlarını yapacak ama kurlar dizisi boş
    func parsingDataFromURL(){
        kurlar = [] //bu konuda kurlar dizimin içi boş bunu biliyor.
        parser = XMLParser(contentsOf: NSURL(string: "https://www.tcmb.gov.tr/kurlar/today.xml")! as URL)! //parser yapacağımız ilgili urli buraya yazıyoruz.
        parser.delegate = self
        parser.parse()
        tblView.reloadData()
    }
   
//kurları doldurmak için didStartElement ve didEndElement fonksiyonlarını kullanıyoruz.
//didStartElement başlangıçta
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        element = elementName as NSString

//elementName as NSString isEqual yani eşitse Currencye  
        if(elementName as NSString).isEqual(to: "Currency"){ 
            
            elements = NSMutableDictionary()
            elements = [:]
            currencyName = NSMutableString()
            currencyName = " " //başlangıçta currencyName boş gelecek.
            forexBuying = NSMutableString()
            forexBuying = " "   //başlangıçta forexBuying boş gelecek.
            
        }
        
    }
    
//karakteri bulduracağız bu fonksiyonda
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if element.isEqual(to: "CurrencyName"){ 
            currencyName.append(string) //CurrencyName'i bulursan currenyName değişkenine bunu append(string) olarak ekle
        }else if element.isEqual(to: "ForexBuying"){
            forexBuying.append(string)  //ForexBuying'i bulursan forexBuying değişkenine bunu append(string) olarak ekle
        }
    }
    
//elementName yine Currency'in sonuna geldiyse eğer
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if(elementName as NSString).isEqual(to: "Currency"){ //eğer sonuna geldi ve Currency e eşit ise
            if !currencyName.isEqual(nil){ //eğer currencyName boş değil ise elementin 
                elements.setObject(currencyName, forKey: "CurrencyName" as NSCopying)
            }
            if !forexBuying.isEqual(nil){
                elements.setObject(forexBuying, forKey: "ForexBuying" as NSCopying)
            }
            kurlar.add(elements) //bu durumlar boş değil ise en son kurlar dizisine ekleyecek.
           
        }
    }
    

    //UItableView Data Source
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return kurlar.count //elimizdeki kurların miktarı kadar o kadar hücre olacak
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "myCell")! as UITableViewCell
        
        if(cell.isEqual(NSNull.self)){ //eğer cell boş ise
            cell = Bundle.main.loadNibNamed("myCell",owner: self,options: nil)![0] as! UITableViewCell
        }
        
        cell.textLabel?.text = (kurlar.object(at:indexPath.row) as AnyObject).value(forKey: "CurrencyName") as! NSString as String
        cell.detailTextLabel?.text = (kurlar.object(at:indexPath.row) as AnyObject).value(forKey : "ForexBuying") as! NSString as String
        
//" 2.2724\n\t\t\t" 
        let str = cell.detailTextLabel?.text
        
        let fullName = str
        let prs = fullName!.components(separatedBy: "\n")
        let yn = prs[0]
        
        let ana = yn.components(separatedBy: " ")
        let git = ana[1]
        
        if let miktar = Double(git){
            cell.detailTextLabel?.text = String(miktar / anaDeger)
        }else{
            print("Deger integera çevirilemedi hatası \(git)")
        }
        
        return cell
    }
}



