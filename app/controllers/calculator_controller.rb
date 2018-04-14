class CalculatorController < ApplicationController
  def index
  end
  
  def create
    puts params.inspect
    render :index
  end  
end
