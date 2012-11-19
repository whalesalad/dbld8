module Concerns
  module CostConcerns
    extend ActiveSupport::Concern

    def earns?
      cost > 0
    end

    def spends?
      cost < 0
    end

    def prefix
      earns? ? '+' : '-'
    end

    def cost_to_s
      "#{prefix}#{cost.abs}"
    end
  end
end