class RegisterController < ApplicationController
#  def show
#    id = params[:id] # retrieve movie ID from URI route
#    @calendar = Schedule.find(id) # look up movie by unique ID
#    # will render app/views/movies/show.<extension> by default
#  end

#  http_basic_authenticate_with :name => "sales", :password => "npasia"

  before_filter :authorize

  def schedule
    Rails.logger.info "Service Schedule = #{params[:service_schedule]}"
    @service_schedule = params[:service_schedule]

    @sale = Sale.all
    @companies = Company.order("name asc")
    @locations = Location.order("name asc")

    @nilpeter_products = Product.where(:type_id => 1)
    @oem1 = Product.where(:type_id => 2).limit(6)
    @oem2 = Product.where(:type_id => 2).last(5)
    @all_days = [1]

    @users = User.all
    @users = @users - [current_user]
    @users = @users - User.where(email: "ios@nilpeter.com")
    third = @users.length / 3
    @engineer1 = @users.slice(0,third)
    @engineer2 = @users.slice(third, third)
    @engineer3 = @users.slice((third)* 2,@users.length)

    begin_month = DateTime.now.at_beginning_of_month
    end_month = begin_month.end_of_month
    @last_job_num = "00"
    if !Schedule.where('user_id = ? AND date >= ? AND date <= ?', current_user.id, begin_month, end_month).last.nil?
      @last_job_num = Schedule.where('user_id = ? AND date >= ? AND date <= ?', current_user.id, begin_month, end_month).last.job_num
    end
  end

  def index
    params[:sort] ||= "date"
    params[:direction] ||= "desc"
    
    @schedule = Schedule.search(params[:search])
    .order(params[:sort] + " " + params[:direction])
    .paginate(:per_page => 25, :page => params[:page])

    @nilpeter_products = Product.where(:type_id => 1)
    @meech_products = Product.where(:type_id => 2)
    @have_timesheet = false
    @timesheet_id = 0
    @test =  current_user
  end

  def export_csv
    begin_month = DateTime.now.at_beginning_of_month
    end_month = begin_month.end_of_month
    Rails.logger.info "None Month = #{params[:pick_month]}"

    begin_month = DateTime.now.at_beginning_of_month << Integer(params[:pick_month])
    end_month = begin_month.end_of_month
    Rails.logger.info "picked"


    schedules = Schedule.where('date >= ? AND date <= ?',begin_month,end_month).order("date desc")

    csvdata = CSV.generate do |csv|
      # header row
      csv << ["Start Date", "End Date", "Job Num", "Company", "Machine No.","Engineers", "Creator", "Products", "Description", "Chargable"]

      schedules.each do |s|
          enginner_names = []
          products = []
          s.users.each do |e|
            enginner_names.push(e.email.split("@")[0].upcase)
          end
          creator = s.user.email.split("@")[0].upcase unless s.user.nil?
          s.products.each do |p|
            products.push(p.name)
          end
          start_date = s.date.utc.strftime("%d/%m/%Y %H:%M") unless s.date.nil?
          end_date = s.end_date.utc.strftime("%d/%m/%Y %H:%M") unless s.end_date.nil?
          job_num = s.job_num unless s.job_num.nil?
          csv << [start_date, end_date, job_num, s.company_name, s.machine_number, enginner_names, creator, products, s.project, s.chargable == 1 ? "YES" : "" ]
      end
    end
    send_data(csvdata, :type => 'text/csv', :filename => 'serviceapp_export.csv')
  end

  def export_xls
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "Pie Chart") do |sheet|
        sheet.add_row ["Simple Pie Chart"]
        %w(first second third).each { |label| sheet.add_row [label, rand(24)+1] }
        sheet.add_chart(Axlsx::Pie3DChart, :start_at => [0,5], :end_at => [10, 20], :title => "example 3: Pie Chart") do |chart|
          chart.add_series :data => sheet["B2:B4"], :labels => sheet["A2:A4"],  :colors => ['FF0000', '00FF00', '0000FF']
        end
      end
      send_data p.to_stream.read, type: "application/xlsx", filename: "filename.xlsx"
    end
  end

  def show
    @schedule = Schedule.find(params[:id])
  end
#
  def edit
    @service_schedule = params[:service_schedule]
    @schedule = Schedule.find(params[:id])

    if current_user.id != @schedule.user_id and current_user.role_id != 3
      flash[:notice] = "you don't have a permission to edit, please contact admin..."
      redirect_to(:controller => "calendar", :action => "index")
    end

    @sale = Sale.all
    @companies = Company.all
    @locations = Location.all

    @nilpeter_products = Product.where(:type_id => 1)
    @oem1 = Product.where(:type_id => 2).limit(6)
    @oem2 = Product.where(:type_id => 2).last(5)

    @users = User.all
    @users = @users - [current_user]
    @users = @users - ["ios@nilpeter.com"]

    third = @users.length / 3
    @engineer1 = @users.slice(0,third)
    @engineer2 = @users.slice(third, third)
    @engineer3 = @users.slice((third)* 2,@users.length)
  end

  def update
    @schedule = Schedule.find(params[:id])
    @schedule.product_ids = params[:products]

    service_schedule = params[:schedule]["service_schedule"]

    Rails.logger.info "chargable params 6 #{params[:schedule]}"

    engineers = []
    engineers = engineers + params[:engineers] unless params[:engineers].nil?
  
    if current_user.role_id != 3
      @schedule.user_ids = engineers.push(current_user.id)
    else
      @schedule.user_ids = engineers
    end


    @schedule.update_attributes!(params[:schedule])

    if !params[:schedule].include? "chargable"
      @schedule.chargable = 0
      Rails.logger.info "not chargable"
    else
      @schedule.chargable = 1
      Rails.logger.info "chargable"
    end

    @schedule.save

    flash[:notice] = "#{@schedule.project} was successfully updated."

    if service_schedule == '1'
      redirect_to(:controller => "calendar", :action => "index", :service_schedule => 1)
    else 
      redirect_to(:controller => "calendar", :action => "index")
    end
  end

  def delete
    @schedule = Schedule.find(params[:id])
    if current_user.id != @schedule.user_id and current_user.role_id != 3
      flash[:notice] = "you don't have a permission to delete, please contact admin..."
      redirect_to(:action => "index")
    end
  end

  def destroy
    # service_schedule = 0
    service_schedule = params[:service_schedule] unless params[:service_schedule].nil?
    # UserMailer.registration_confirmation().deliver
    @schedule = Schedule.find(params[:id])
    if current_user.id != @schedule.user_id and current_user.role_id != 3
      flash[:notice] = "you don't have a permission to delete, please contact admin..."
      redirect_to(:controller => "calendar", :action => "index")
    else
      @schedule.destroy
      flash[:notice] = "#{@schedule.project} was successfully deleted."
      if service_schedule == '1'
        redirect_to(:controller => "calendar", :action => "index", :service_schedule => 1)
      else 
        redirect_to(:controller => "calendar", :action => "index")
      end
    end

  end

  def create
    schedule = params[:schedule]
    service_schedule = params[:schedule]["service_schedule"]
    Rails.logger.debug { "service val #{service_schedule == '1'}" }

    if Schedule.exists?(job_num: "#{params[:schedule]["job_num"]}") and service_schedule != '1'
      flash[:notice] = "#{params[:schedule]["job_num"]} already exists, please try another job number"
      if service_schedule == '1'
        redirect_to(:controller => "register", :action => "schedule", :service_schedule => 1)
      else 
        redirect_to(:controller => "register", :action => "schedule")
      end
    else
      s = Schedule.create!(schedule)
      s.product_ids = params[:products]
      s.chargable = params[:schedule]["chargable"][0] unless params[:schedule]["chargable"].nil?
      engineers = []
      engineers = engineers + params[:engineers] unless params[:engineers].nil?
      # Rails.logger.info "Month create = #{current_user.id}, #{current_user.email}, #{current_user.role_id}, #{params[:engineers]}"
      if current_user.role_id != 3
        # Rails.logger.info "create current user role id less than 3, #{params[:engineers]}"
        s.user_ids = engineers.push(current_user.id)
      else
        s.user_ids = engineers
      end

      s.save

      flash[:notice] = "#{s.project} was successfully created."

      if service_schedule == '1'
        redirect_to(:controller => "calendar", :action => "index", :service_schedule => 1)
      else 
        redirect_to(:controller => "calendar", :action => "index")
      end
    end
  end

  def calendar
    @schedule = Schedule.search(params[:search])
  end

  def create_new
    @company = Company.create!(params[:company])
    flash[:notice] = "#{@company.name} was successfully created."
    redirect_to(:action => "schedule")
  end

end
