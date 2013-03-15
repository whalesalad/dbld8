# encoding: utf-8
class ReceiptVerificationWorker
  include Sidekiq::Worker

  def perform(purchase_id)
    purchase = Purchase.find(purchase_id)
    
    if purchase.unverified?
      purchase.verify!
    end

    msg = (purchase.verified?) ? "✔ VERIFIED" : "✘ INVALID"
    msg += " PURCHASE: #{purchase}"

    Rails.logger.info msg
    puts msg
  end
end