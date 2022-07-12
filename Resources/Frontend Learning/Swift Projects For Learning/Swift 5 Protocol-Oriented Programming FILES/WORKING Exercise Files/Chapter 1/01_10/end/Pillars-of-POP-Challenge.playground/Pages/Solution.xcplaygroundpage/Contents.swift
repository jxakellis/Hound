class PaymentController {
    let services: [Service]
    
    init(services: [Service]) {
        self.services = services
    }
    
    func calculateEarnings() -> Float {
        services.reduce(0) { $0 + $1.total}
        
        var total: Float = 0
        services.forEach { (service) in
            total += service.total
        }
        return total //amazonService.earnings + eBayService.totalEarned
 
    }
}

var amazonService = /*ServiceProvider.*/make(service: .amazon) //AmazonService()
var etsyService = /*ServiceProvider.*/make(service: .etsy) //EtsyService()

let controller = PaymentController(services: [amazonService, etsyService])

amazonService.add(payment: 100) //amazonService.receive(payment: 100)
etsyService.add(payment: 25)//eBayService.add(earning: 25)
amazonService.add(payment: 12.50)//amazonService.receive(payment: 12.50)

print("Total earned: \(controller.calculateEarnings())")


