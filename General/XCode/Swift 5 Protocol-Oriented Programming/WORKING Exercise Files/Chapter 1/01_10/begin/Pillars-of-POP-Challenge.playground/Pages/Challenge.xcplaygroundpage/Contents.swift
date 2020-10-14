class PaymentController {
    let amazonService: AmazonService
    let etsyService: EtsyService
    
    init(amazon: AmazonService, etsy: EtsyService) {
        amazonService = amazon
        etsyService = etsy
    }
    
    func calculateEarnings() -> Float {
        amazonService.earnings + etsyService.totalSold
    }
}

let amazonService = AmazonService()
let etsyService = EtsyService()

let controller = PaymentController(amazon: amazonService, etsy: etsyService)

amazonService.orderPlaced(payment: 100)
etsyService.itemSold(profit: 25)
amazonService.orderPlaced(payment: 12.50)

print("Total earned: \(controller.calculateEarnings())")
