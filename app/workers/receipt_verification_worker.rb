# encoding: utf-8

class ReceiptVerificationWorker
  include Sidekiq::Worker

  def perform(purchase_id)
    purchase = Purchase.find(purchase_id)
    
    if purchase.unverified?
      purchase.verify!
    end

    if purchase.verified?
      puts "✔ VERIFIED PURCHASE: #{purchase}" 
    else
      puts "✘ INVALID PURCHASE: #{purchase}"
    end    
  end
end