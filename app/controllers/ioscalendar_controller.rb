class IoscalendarController < ActionController::Base

  require 'json'

  def current_user
    @current_user ||= User.find_by_auth_token(cookies[:auth_token]) if cookies[:auth_token]
  end

  def index
    @schedule = Schedule.all
    @holidays = Holiday.all
  end

  def create_timesheet

    Rails.logger.info "timesheet data controller value #{params[:timesheet_nil_sig]}"
    @timesheet = Timesheet.new
    @timesheet.user_id = params[:user_id]
    @timesheet.schedule_id = params[:schedule_id]
    @timesheet.data = params[:data]
    @timesheet.nil_sig = params[:nil_sig]
    @timesheet.cus_sig = params[:cus_sig]
    @timesheet.save!

    @schedule = Schedule.find(params[:schedule_id])

    @schedule.timesheet_id = @timesheet.id
    @schedule.update_attributes!(params[:timesheet_id])

    redirect_to(:controller => "register", :action => "index")
  end

  # def create_ios_timesheet
  #
  #   Rails.logger.info "timesheet data controller value #{params[:timesheet_nil_sig]}"
  #   @timesheet = Timesheet.new
  #   @timesheet.user_id = params[:user_id]
  #   @timesheet.schedule_id = params[:schedule_id]
  #   @timesheet.data = params[:data]
  #   @timesheet.nil_sig = params[:nil_sig]
  #   @timesheet.cus_sig = params[:cus_sig]
  #   @timesheet.save!
  #
  #   @schedule = Schedule.find(params[:schedule_id])
  #   @schedule.timesheet_id = @timesheet.id
  #   @schedule.update_attributes!(params[:timesheet_id])
  #
  #   render :json =>  {
  #     :status => "success"
  #   }
  # end

  def timesheet

    id = params[:id]
    @schedule_id = id
    @schedule = Schedule.find(id)
    @project = Schedule.find(id).project.gsub(/\r\n/, "\\r\\n")

    if current_user.id != @schedule.user_id and current_user.role_id != 3
      flash[:notice] = "you don't have a permission to create the timesheet, please contact admin..."
      redirect_to(:controller => "calendar", :action => "index")
    end

    @current_user_id = @schedule.user_id
    @engineers = ""
    for user in @schedule.users.reverse
      @engineers = user.email.split("@")[0].upcase + ", " + @engineers
    end
    @engineers = @engineers.chop.chop

    @product_types = ""
    for product in @schedule.products.reverse
      @product_types = product.name.upcase + ", " + @product_types
    end
    @product_types = @product_types.chop.chop
  end

  def iostimesheet

    id = params[:id]
    @schedule_id = id
    @schedule = Schedule.find(id)
    @project = Schedule.find(id).project.gsub(/\r\n/, "\\r\\n")
    @current_user_id = @schedule.user_id
    @engineers = ""
    for user in @schedule.users.reverse
      @engineers = user.email.split("@")[0].upcase + ", " + @engineers
    end
    @engineers = @engineers.chop.chop

    @product_types = ""
    for product in @schedule.products.reverse
      @product_types = product.name.upcase + ", " + @product_types
    end
    @product_types = @product_types.chop.chop
  end

  def edit_timesheet

    @schedule = Schedule.where(timesheet_id: params[:id])[0]

    if current_user.id != @schedule.user_id and current_user.role_id != 3
      flash[:notice] = "you don't have a permission to edit the timesheet, please contact admin..."
      redirect_to(:controller => "register", :action => "index")
    end

    @timesheet = Timesheet.find(params[:id])
    @timesheet_id = params[:id]
    @timesheet_data = @timesheet.data
  end

  def edit_iostimesheet

    @schedule = Schedule.where(timesheet_id: params[:id])[0]

    @timesheet = Timesheet.find(params[:id])
    @timesheet_id = params[:id]
    @timesheet_data = @timesheet.data
  end

  def print_timesheet

    @schedule = Schedule.where(timesheet_id: params[:id])[0]

    @timesheet = Timesheet.find(params[:id])
    @timesheet_id = params[:id]
    @timesheet_data = @timesheet.data
    @timesheet_json = JSON.parse(@timesheet_data)

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "file_name",
        header: { right: '[page] of [topage]' },
        disable_smart_shrinking: false,
        zoom: 0.9
      end
    end
  end

  def update_timesheet

    @timesheet = Timesheet.find(params[:id])
    @timesheet.data = params[:data]
    @timesheet.nil_sig = params[:nil_sig]
    @timesheet.cus_sig = params[:cus_sig]
    @timesheet.update_attributes!(params[:timesheet])
    redirect_to(:controller => "register", :action => "index")
  end

end
