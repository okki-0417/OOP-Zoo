# frozen_string_literal: true

class Hiring
  def initialize(zoo:, employee:)
    @zoo = zoo
    @employee = employee
  end

  def perform
    @zoo.purchase(@employee.class.signing_fee)
    @zoo.save!
    @employee.save!
    @employee
  end

  def to_s
    "#{@employee.name}を雇用"
  end
end
