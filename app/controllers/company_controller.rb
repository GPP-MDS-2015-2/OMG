class CompanyController < ApplicationController
  def show
    find_public_agency
    expenses_public_agency = Expense.where(public_agency_id: @public_agency.id)
    @array_company_expense = find_company(expenses_public_agency)
    @array_company_expense.to_json
  end

  def find_public_agency
    @public_agency = PublicAgency.find(params[:id])
    @superior_public_agency = SuperiorPublicAgency.find(@public_agency.superior_public_agency_id)
  end

  def find_company(expenses_public_agency)
    companies_expense = {}

    expenses_public_agency.each do |expense|
      company = Company.where(id: expense.company_id)
      test_add_expense(company, expense, companies_expense)
    end

    return sort_by_expense(companies_expense)
  end

  # assert that company array is not empty
  def test_add_expense(company, expense, companies_expense)
    if !company.empty? && company.length == 1
      testing_companies(company, expense, companies_expense)
    end
  end

  def testing_companies(company, expense, companies_expense)
    company = company[0]
    if !companies_expense [company.name]
      companies_expense [company.name] = expense.value
    else
      companies_expense[company.name] += expense.value
     end
  end

  def sort_by_expense(companies_expense)
    companies_expense.sort_by { |_name, expense| expense }
  end

######################################### View hiring incidence ######################

  def find
      expenses = Expense.where(company_id: 1)
      company_hiring_incidence = find_public_agencies(expenses)
      company_name = get_name_company
      data_company = generate_company_node(company_name)
      generate_public_agency_node(company_name,company_hiring_incidence,data_company)    
    end

    def find_public_agencies(expenses)
      company_hiring_incidence  = {}
      expenses.each do |expense|
        public_agency = PublicAgency.find(expense.public_agency_id)
        verify_insert(company_hiring_incidence,public_agency)
      end
      return company_hiring_incidence
    end

    def find_hiring_count(public_agency)
      counting = Expense.where(public_agency_id: public_agency.id).count
    end

    def verify_insert(company_hiring_incidence,public_agency)
      if ! company_hiring_incidence[public_agency.name]
        counting = find_hiring_count(public_agency)
        company_hiring_incidence[public_agency.name] = counting
      end
    end
  end

  def get_name_company
    company_name = Company.find(params[:id]).name
  end

  def generate_company_node(company_name)
    data_company = [
      { "data" => { id => company_name }, position => { x => 100, y => 80 } },
      { "data" => { id => 'Órgãos Públicos' } },{ "data" => { id => 'qtde Contratações' } },
    ]
  end

  def generate_public_agency_node(company_name,company_hiring_incidence,data_company)
    count = 1
    array_general = []
    edges = []
    company_hiring_incidence.each do |public_agency_name, hiring|
      public_agency_name = public_agency_name.to_s
      hash_public_agency = { "data" => { id => public_agency_name, parent => 'Órgãos Públicos' }, position => { x => 200, y => count * 50 } },
      hash_hiring = { "data" => { id => hiring, parent => 'qtde Contratações' }, position => { x => 350, y => count * 50  } }
      
      data_company << hash_public_agency
      data_company << hash_hiring
      count += 1


      hash_edge_to_company = { "data" => { source => public_agency_name, target => company_name } }
      hash_edge_to_public_agency = { "data" => { source => hiring, target => public_agency_name } }

      edges << hash_edge_to_company
      edges << hash_edge_to_public_agency
    end

    array_general << data_company
    array_general << edges
  end

end
=end



=begin
elements: {
    nodes: [
      { "data": { id: 'Empresas' }, position: { x: 100, y: 80 } },
      { "data": { id: 'Órgãos Públicos' } },
      { "data": { id: 'qtde Contratações' } },
      { "data": { id: 'Ministério2', parent: 'Órgãos Públicos' }, position: { x: 200, y: 80 } },
      { "data": { id: '37', parent: 'qtde Contratações' }, position: { x: 350, y: 30 } },
      { "data": { id: 'Ministério1', parent: 'Órgãos Públicos' }, position: { x: 200, y: 30 } },
    ],
    edges: [
      { data: { source: 'Ministério2', target: 'Empresas' } },
      { data: { source: '37', target: 'Ministério1' } },
      { data: { source: 'Ministério1', target: 'Empresas' } }
      
    ]
  }
=end
