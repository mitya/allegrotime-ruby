module VX
  module_function

  def stripeForCrossing(crossing)
    Device.image_named("cell-stripe-#{crossing.color.mkname}")
  end
end