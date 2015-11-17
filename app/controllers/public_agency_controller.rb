# public_agency.rb
# Create a class to handle the data related with public agencies
class PublicAgencyController < ApplicationController
  # list of all public agencies in DB
  def index
    @public_agencies = PublicAgency.all
    @total_expense_agency = {}
    @public_agencies.each do |agency|
      @total_expense_agency[agency.id] = expenses_public_agency(agency.id)
    end
  end

  # Find the data of one public agency to show in the view with chart
  def show
    find_agencies(params[:id])
    increment_views_amount(@public_agency)
    expenses_public_agency = get_expenses_agency(@public_agency.id)
    @list_expenses = expenses_public_agency[:total_date]

    change_type_list_expenses
  end

  def change_type_list_expenses
    puts "\n\n #{@list_expenses} \n\n"
    aux = @list_expenses
    HelperController.int_to_month(aux)
    @list_expenses = aux
    temporary_expense = { '2015'=> @list_expenses.to_h }
    @list_expenses = temporary_expense.to_json
  end

  def expenses_public_agency(id_pub_agency)
    total_expense = Expense.where(public_agency_id: id_pub_agency).sum(:value)
    total_expense
  end

  def filter_chart
    # find the same thing then the show
    find_agencies(params[:id])
    expenses_agency = nil
    begin
      expenses_agency = create_list_expense(params, @public_agency)
    rescue Exception => erro
      flash[:error] = "#{erro}\n Veja o gráfico com todos gastos"
      expenses_agency = get_expenses_agency(@public_agency.id)
    end
    @list_expenses = expenses_agency[:total_date]
    @total_expense = expenses_agency[:total]
    change_type_list_expenses
    render 'show'
  end

  def create_list_expense(date, public_agency)
    dates = HelperController.create_date(date)

    expenses_agency = { total_date: {} }
    if HelperController.date_valid?(dates[:begin], dates[:end])
      expenses_agency = get_expenses_agency(public_agency.id,
                                            dates[:begin], dates[:end])
    end
    # puts expenses_agency
    if expenses_agency[:total_date].empty?
      fail 'Não encontrou nenhum gasto no periodo'
    end
    expenses_agency
  end

  # def  break_filter_years(begin_date, end_date)
  #     begin_year = begin_date.year
  #     end_year = end_date.year
  #     aux_year = 2011

  #     while begin_year != end_year
  #       increment year
  #       begin_year += 1 
  #     end
  # end

  def get_expenses_agency(id_public_agency,
    begin_date = '2014-01-01', end_date = '2015-12-31')
  
    expenses = Expense.where(public_agency_id: id_public_agency,
                             payment_date: begin_date..end_date)

    expenses_agency = {total_date: {}}
    expenses.each do |expense|
      date = Date.new(expense.payment_date.year, expense.payment_date.month, 1)
      HelperController.sum_expense(l(date), expense,
                                   expenses_agency[:total_date])
    end

    expenses_agency[:total_date] = expenses_agency[:total_date]
                                   .sort_by { |date, _value| Date.parse(date) }
    return expenses_agency
  end

  def increment_views_amount(public_agency)
    views_amount = public_agency.views_amount
    views_amount += 1
    public_agency.update(views_amount: views_amount)
  end

  # methods that's need to be private
  private :increment_views_amount,
          :get_expenses_agency, :create_list_expense, :expenses_public_agency
  # private :increment_views_amount, :month_to_int
end
