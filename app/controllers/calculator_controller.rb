class CalculatorController < ApplicationController
  include ActionView::Helpers::NumberHelper
  
  def introduction
  end
  
  def terms_of_service
    description_params = params.except('authenticity_token', 'controller', 'action')
    subject_str = 'הגשת בקשה להחזר מס על סך: '
    body_str = 'הנתונים שהוכנסו:'

    @subject = subject_str
    @body = body_str + description_params.to_s
  end

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
    attribute :military_release_date, type: DateTime
    attribute :military_service, type: String
    attribute :military_service_duration, type: Integer
    attribute :education, type: String 
    attribute :first_degree_end_date, type: DateTime
    attribute :first_degree_benefits_claimed, type: Boolean, default: true
    attribute :second_degree_end_date, type: DateTime
    attribute :second_degree_benefits_claimed, type: Boolean, default: true
    attribute :employment
    attribute :national_insurance, type: Integer, default: 0
    attribute :national_insurance_tax, type: Integer, default: 0
    attribute :unemployment, type: Boolean
    attribute :unemployment_months, type: Integer
    
    END_OF_YEAR = DateTime.parse('2017-12-31')
    BEGINNING_OF_YEAR = DateTime.parse('2017-01-01')
    
    def initialize(age:, child_birth_date:, military_release_date:, employment:, national_insurance_accepted:, **opts)
      self.age = age.present? ? ((END_OF_YEAR - DateTime.parse(age)) / 365).to_f : 20
      self.children_birth_year = child_birth_date.values[0].present? ? child_birth_date.values.map { |date| DateTime.parse(date).year } : []
      self.employment = employment.values
        
      super(opts)
      
      if national_insurance_accepted.to_s == 'true'
        self.national_insurance = 0
        self.national_insurance_tax = 0
      end
    end
    
    def test!(func)
      puts "#{func} = #{self.send(func)}"
    end
    
    def calculate!
      puts "********* TEST *************"
      test! :gender_points
      test! :age_points
      test! :military_points
      test! :israel_citizen_points
      test! :children_points
      test! :degree_points
      test! :tax_on_slary
      test! :tax_sum
      test! :contribution_sum
      test! :gemel
      test! :total_deductions
      test! :tax_to_be_paid
      test! :tax_refund
      test! :employment_months
      puts "****************************"
    end

    FIRST_TAX_STEP = 74640
    SECOND_TAX_STEP = 107070
    THIRD_TAX_STEP = 171840
    FOURTH_TAX_STEP = 238800
    FIFTH_TAX_STEP = 496620
    SIXTH_TAX_STEP = 640000
    
    def employment_months
      return 12 unless unemployment

      12 - unemployment_months
    end
    
    def tax_refund
      tax_to_be_paid - tax_sum
    end
    
    def tax_to_be_paid
      tax_on_slary - total_deductions
    end
    
    def total_deductions
      points * 2580 * (employment_months / 12.0) + gemel
    end
    
    def gemel
      ratio = (employment_months / 12.0)
      contribution_sum * ratio > 7308 ? 7308 * ratio * 0.35 : contribution_sum * 0.35
    end
    
    def points
      gender_points + age_points + military_points + israel_citizen_points + children_points + degree_points
    end
    
    def gender_points
      gender == 'male' ? 0 : 0.5
    end
    
    def age_points
      ((age >= 16) && (age <= 18)) ? 1 : 0
    end
    
    def israel_citizen_points
      israel_citizen ? 2.25 : 0
    end
    
    def children_points
      children_birth_year.inject(0) { |acc, child| acc + child_points(child) }
    end
    
    def degree_points
      first_degree_points + second_degree_points
    end
    
    def first_degree_points
      return 0 if education == 'none' || first_degree_end_date.blank?
      return 0 if first_degree_benefits_claimed
      
      year = first_degree_end_date.year
      ((year >= 2015) && (year <= 2016)) ? 1 : 0
    end
    
    def second_degree_points
      return 0 if education == 'none' || education == 'first_degree' || second_degree_end_date.blank?
      return 0 if second_degree_benefits_claimed
      
      year = second_degree_end_date.year
      ((year >= 2015) && (year <= 2016)) ? 0.5 : 0
    end
    
    def child_points(child_year)
      return 1.5 if child_year == 2017
      return 2.5 if ((child_year >= 2012) && (child_year <= 2016))
      
      0
    end
    
    def tax_on_slary
      return salary_sum * 0.10 if salary_sum < FIRST_TAX_STEP
      return (7464 + (salary_sum - FIRST_TAX_STEP) * 0.14) if salary_sum < SECOND_TAX_STEP
      return (12004 + (salary_sum - SECOND_TAX_STEP) * 0.2) if salary_sum < THIRD_TAX_STEP
      return (24958 + (salary_sum - THIRD_TAX_STEP) * 0.31) if salary_sum < FOURTH_TAX_STEP
      return (45716 + (salary_sum - FOURTH_TAX_STEP) * 0.35) if salary_sum < FIFTH_TAX_STEP
      return (135953 + (salary_sum - FIFTH_TAX_STEP) * 0.47) if salary_sum < SIXTH_TAX_STEP

      (203341 + (salary_sum - SIXTH_TAX_STEP) * 0.5)
    end
    
    def salary_sum
      employment.inject(0) { |sum, work| sum + work[:salary].to_i } + national_insurance
    end
    
    def tax_sum
      employment.inject(0) { |sum, work| sum + work[:tax].to_i } + national_insurance_tax
    end
    
    def contribution_sum
      employment.inject(0) { |sum, work| sum + work[:contribution].to_i }
    end
    
    def military_points
      return 0 if military_service == 'none' 

      military_entitlement_months = calculate_military_entitlement_months(
        military_release_date,
        military_service_duration.to_i,
        military_service
      )
      entitlement_points = military_entitlement_points(military_service, military_service_duration, gender)

      (military_entitlement_months / 12) * entitlement_points
    end
    
    def calculate_military_entitlement_months(military_release_date, military_service_duration, military_service)
      return 0 unless military_release_date.present?
      plus_one_month = military_release_date + 1.month
      end_of_military = DateTime.civil(plus_one_month.year, plus_one_month.month, 1) + 3.years
      
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
  end
  
  def create
    # input = InputParams.new(**stub.deep_symbolize_keys)
    input = InputParams.new(**params.deep_symbolize_keys)
    puts params.inspect
    puts input.calculate!
    
    amount = input.calculate!
    amount = 3000
    amount = 0 if amount < 500
    amount = amount * 0.8

    render json: { amount: number_with_delimiter(amount.to_i, :delimiter => ',') }
  end
  
  def stub2
   {
    "authenticity_token"=>"rtdcIw36xaEtBN/DCowHKDBwkCWqWBBxC8zfTof3GHTfNSTN5+ZY37bYObquclBqhxd9kNASraobeWfE96Lz8A==",
    "gender"=>"male",
    "age"=>"1999-12-19",
    "israel_citizen"=>"true",
    "relationship_status"=>"single",
    "has_children"=>"false",
    "child_birth_date"=>{
    },
    "military_service"=>"military",
    "military_release_date"=>"2009-04-06",
    "military_service_duration"=>"36",

    "education"=>"second_degree",
    "first_degree_end_date"=>"2016-04-04",
    "first_degree_benefits_claimed"=>"true",
    "second_degree_end_date"=>"2017-04-25",
    "second_degree_benefits_claimed"=>"false",
    "employment"=>{
    	"0"=>
    		{
    		"salary"=>"337405",
    		"contribution"=>"22050",
    		"tax"=>"71896",
    		"start_date"=>"2017-01-01",
    		"end_date"=>"2017-12-31"
    		}
      },
    "national_insurance"=>"0",
    "national_insurance_tax" => "0",
    "controller"=>"calculator",
    "action"=>"create"
    }
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
    "national_insurance_tax" => "10000",
    "unemployment"=>"true",
    "unemployment_months"=>"5",
    "controller"=>"calculator",
    "action"=>"create"
    }
  end
end
