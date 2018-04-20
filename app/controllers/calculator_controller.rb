class CalculatorController < ApplicationController
  def index
  end
  
  class InputParams
    include ActiveAttr::Model

    attribute :gender, type: String
    attribute :age, type: Float
    attribute :israel_citizen, type: Boolean
    attribute :relationship_status, type: String 
    attribute :has_children, type: Boolean
    attribute :children_birth_year
    attribute :military_service, type: String
    attribute :military_service_duration, type: Integer
    attribute :education, type: String 
    attribute :first_degree_end_date
    attribute :first_degree_benefits_claimed, type: Boolean
    attribute :second_degree_end_date
    attribute :second_degree_benefits_claimed, type: Boolean
    attribute :employment
    attribute :national_insurance, type: Integer
    
    END_OF_YEAR = DateTime.parse('2017-12-31')
    BEGINNING_OF_YEAR = DateTime.parse('2017-01-01')
    
    def initialize(age:, child_birth_date:, military_release_date:, military_service_duration:, **opts)
      self.age = ((END_OF_YEAR - DateTime.parse(age)) / 365).to_f
      self.children_birth_year = child_birth_date.values.map { |date| DateTime.parse(date).year }
      self.military_entitlement_months = calculate_military_entitlement_months(
        military_release_date,
        military_service_duration.to_i,
        military_service,
        gender
      )
        
      super(opts)
    end
    
    def calculate_military_entitlement_months(military_release_date, military_service_duration, military_service, gender)
      entitlement_points = military_entitlement_points(military_service, military_service_duration, gender)
        
      plus_one_month = DateTime.parse(military_release_date) + 1.month
      end_of_military = DateTime.civil(plus_one_month.year, plus_one_month.month, 1) + 3.years
      
      byebug
      
      return 0 if end_of_military < BEGINNING_OF_YEAR
      return 12 if end_of_military > END_OF_YEAR
      

      (end_of_military.year * 12 + end_of_military.month) - (BEGINNING_OF_YEAR.year * 12 + BEGINNING_OF_YEAR.month)
    end
    
    def military_entitlement_points(military_service, military_service_duration, gender)
      return 0 if military_service == 'none'

      if military_service == 'social_service'
        if military_service_duration < 12
          return 0
        else
          return military_service_duration < 24 ? 1 : 2
        end
      end
      
      # NOT Social Service
      if gender == 'male'
        if military_service_duration < 12
          return 0
        else
          return military_service_duration < 23 ? 1 : 2
        end
      else
        if military_service_duration < 12
          return 0
        else
          return military_service_duration < 22 ? 1 : 2
        end
      end
    end

    # def initialize(
    #       gender:,
    #       age:,
    #       israel_citizen:,
    #       relationship_status:,
    #       has_children:,
    #       child_birth_date:,
    #       military_service:,
    #       military_release_date:,
    #       military_service_duration:,
    #       education:,
    #       first_degree_end_date:,
    #       first_degree_benefits_claimed:,
    #       second_degree_end_date:,
    #       second_degree_benefits_claimed:,
    #       employment:,
    #       national_insurance:,
    #       **
    #     )
    # end
  end
  
  def create
    input = InputParams.new(**stub.deep_symbolize_keys)
    byebug
    puts params.inspect
    render :index
  end
  
  def stub
   {
    "authenticity_token"=>"rtdcIw36xaEtBN/DCowHKDBwkCWqWBBxC8zfTof3GHTfNSTN5+ZY37bYObquclBqhxd9kNASraobeWfE96Lz8A==",
    "gender"=>"female",
    "age"=>"1999-12-19",
    "israel_citizen"=>"true",
    "relationship_status"=>"married",
    "has_children"=>"true",
    "child_birth_date"=>{
    	"0" => "2012-04-15",
    	"1" => "2012-04-16",
    	"2" => "2012-04-17"
    },
    "military_service"=>"military",
    "military_release_date"=>"2016-04-06",
    "military_service_duration"=>"36",
    "education"=>"second_degree",
    "first_degree_end_date"=>"2016-04-04",
    "first_degree_benefits_claimed"=>"false",
    "second_degree_end_date"=>"2017-04-25",
    "second_degree_benefits_claimed"=>"true",
    "employment"=>{
    	"0"=>
    		{
    		"salary"=>"200000",
    		"contribution"=>"10000",
    		"tax"=>"30000",
    		"start_date"=>"2017-01-01",
    		"end_date"=>"2017-04-20"
    		},
    	"1"=>
    		{
    		"salary"=>"200000",
    		"contribution"=>"10000",
    		"tax"=>"30000",
    		"start_date"=>"2016-01-01",
    		"end_date"=>"2016-04-20"
    		},
    	"2"=>
    		{
    		"salary"=>"200000",
    		"contribution"=>"10000",
    		"tax"=>"30000",
    		"start_date"=>"2015-01-01",
    		"end_date"=>"2015-04-20"
    		}
      },
    "national_insurance"=>"20000",
    "controller"=>"calculator",
    "action"=>"create"
    }
  end
end
