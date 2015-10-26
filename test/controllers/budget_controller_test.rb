 require 'test_helper'

class BudgetControllerTest < ActionController::TestCase

	test "Should return a valid period" do
		data = Date.new(2015,06,01)
		boolean = @controller.is_date_in_interval("Janeiro",2015,"Dezembro",2015,data)
		expect_return = true
		assert_equal(expect_return,boolean)	
	end

	test "Should return an invalid period" do
		data = Date.new(2014,06,01)
		boolean = @controller.is_date_in_interval("Janeiro",2015,"Dezembro",2015,data)
		expect_return = false
		assert_equal(expect_return,boolean)	
	end

	test "Should return a not empty filter" do
		
		list_type_expenses = [1, 2, 3, 4, 5, 6]
		not_empty_list = @controller.is_empty_filter(list_type_expenses)
		assert_not (not_empty_list)
		
	end

	test "Should return a empty filter" do
		list_type_expenses = []
		empty_list = @controller.is_empty_filter(list_type_expenses)
		assert (empty_list)
	end

	test "Should return a equals hashs" do
		hash = {"01/2015"=>0, "02/2015"=>0, "03/2015"=>0, "04/2015"=>0, "05/2015"=>0, "06/2015"=>0, "07/2015"=>0, "08/2015"=>0, "09/2015"=>0, "10/2015"=>0, "11/2015"=>0, "12/2015"=>0}
		hash_return = @controller.initialize_hash(2015)
		assert_equal(hash_return, hash)
	end

	test "Should return diferents hashs" do
		hash = {"01/2015"=>12, "02/2015"=>19, "03/2015"=>1, "04/2015"=>9, "05/2015"=>15, "06/2015"=>89, "07/2015"=>0, "08/2015"=>78, "09/2015"=>100, "10/2015"=>5, "11/2015"=>60, "12/2015"=>0}
		hash_return = @controller.initialize_hash(2015)
		assert_not_equal(hash_return, hash)
	end

	test "Routes to method filter_chart_budget" do
		create_public_agency
		get :filter_chart_budget, id: 1, year: "2015"
		assert_response :success
		assert assigns(:list_expense_month)
		assert assigns(:expense_find)
	end

	test "Should return equals arrays" do
		hash = {2015=>{"01/2015"=>0, "02/2015"=>0, "03/2015"=>0, "04/2015"=>0, "05/2015"=>0, "06/2015"=>0, "07/2015"=>0, "08/2015"=>0, "09/2015"=>0, "10/2015"=>0, "11/2015"=>0, "12/2015"=>0}}
 		array_expect = [["01/2015", 0], ["02/2015", 0], ["03/2015", 0], ["04/2015", 0], ["05/2015", 0], ["06/2015", 0], ["07/2015", 0], ["08/2015", 0], ["09/2015", 0], ["10/2015", 0], ["11/2015", 0], ["12/2015", 0]]
 		array_return = @controller.transform_hash_to_array(hash)
 		assert_equal(array_expect, array_return)
	end

	test "Should return diferents arrays" do
		hash = {2015=>{"01/2015"=>0, "02/2015"=>0, "03/2015"=>0, "04/2015"=>0, "05/2015"=>0, "06/2015"=>0, "07/2015"=>0, "08/2015"=>0, "09/2015"=>0, "10/2015"=>0, "11/2015"=>0, "12/2015"=>0}}
 		array_expect = [[2015, ["01/2015", 0], ["02/2015", 0], ["03/2015", 0], ["04/2015", 0], ["05/2015", 0], ["06/2015", 0], ["07/2015", 0], ["08/2015", 0], ["09/2015", 0], ["10/2015", 0], ["11/2015", 0], ["12/2015", 0]]]
 		array_return = @controller.transform_hash_to_array(hash)
 		assert_not_equal(array_expect, array_return)
	end
	def create_public_agency
		SuperiorPublicAgency.create(id: 1,name: "valid SuperiorPublicAgency")
		PublicAgency.create(id: 1,views_amount: 0,name: "valid Agency",superior_public_agency_id: 1)

		for i in 1..5
			Expense.create(document_number: "0000",payment_date: Date.new(2013,i,1),public_agency_id: 1,value: 100)
		end
	end
	test "Route to method show and the result of the request" do
		create_public_agency				
	  	assert_routing '/public_agency/1/budgets', { :controller => "budget", :action => "show", :id => "1" }	
		get :show, id: 1

		assert_response :success

		assert assigns(:list_expense_month)
		assert assigns(:expense_find)
	end

 	test "The method get_expenses_agency" do
 		id_public_agency = 1
		public_agency_default = @controller.get_expenses_agency(id_public_agency)
		expense_value_init = {}
		assert_equal(expense_value_init,public_agency_default)
		
		create_entities
		
		id_public_agency = 1
		expected_data = {Date.new(2010,1,1)=>2000}
		public_agency = @controller.get_expenses_agency(id_public_agency)
		assert_equal(public_agency,expected_data)


		id_public_agency = 2
		public_agency_false = @controller.get_expenses_agency(id_public_agency)
		assert_equal(public_agency_false,{})				

	end
	test "Sum of the type expenses in method get_expense_by_type" do
		create_entities
		id_public_agency = 1
		data = @controller.get_list_expenses_by_period(id_public_agency)
		assert_not data.empty?

		expected_list = [["01/2010", 2000], ["02/2010", 0], ["03/2010", 0], ["04/2010", 0], ["05/2010", 0], ["06/2010", 0], ["07/2010", 0], ["08/2010", 0], ["09/2010", 0], ["10/2010", 0], ["11/2010", 0], ["12/2010", 0]]

		assert_equal(expected_list,data)
 	end
	def create_entities
		SuperiorPublicAgency.create(id: 1,name: "valid SuperiorPublicAgency")

		PublicAgency.create(id: 1,views_amount: 0,name: "valid Agency",superior_public_agency_id: 1)

		Expense.create(document_number: "0000",payment_date: Date.new(2010,1,1),public_agency_id: 1,value: 500)
		Expense.create(document_number: "0001",payment_date: Date.new(2010,1,2),public_agency_id: 1,value: 500)
		Expense.create(document_number: "0002",payment_date: Date.new(2010,1,1),public_agency_id: 1,value: 1000)
		
	end
	
end

