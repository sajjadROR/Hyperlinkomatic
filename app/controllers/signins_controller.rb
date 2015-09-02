class SigninsController < ApplicationController

  def index
    @signins = Signin.all
  end

  def edit
  end

  def create
    @signin = Signin.new(signin_params)
    @signin.save
  end

  private

    def signin_params
      params.require(:signin).permit(:url)
    end

end

require 'EventType'
require 'json'

class ApiController < ApplicationController

  respond_to :json

  # ----------------------------------------------------------------------------------------------------------
  before_filter :find_user_by_api_key
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  # ----------------------------------------------------------------------------------------------------------
  after_filter :set_access_control_headers
  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
  end

  # ----------------------------------------------------------------------------------------------------------
  def listInformationv2


    @response[:attributes] = []

    # I just did this using LOOP so that we avoid write same code again and code.
    # I think now this is simple and short

    ["Email", "Title","Firstname", "Lastname", "Company", "Phone", "Address", "Website", "Notes"].each do |i|
      item = {:name=>i, :id=>"system_#{i.downcase}", :input=>"text", :type=>"system"}
      @response[:attributes] << item
    end

    user.customattributes.order('LOWER(name)').each do |catt|

      item = {}

      item[:name] = catt.name
      item[:id] = "custom_" + catt.id.to_s
      item[:input] = "text"
      item[:type] = "custom"

      @response[:attributes] << item

    end

    user.tags.order('LOWER(name)').each do |tag|

      item = {}

      item[:name] = tag.name
      item[:id] = "tag_" + tag.id.to_s
      item[:input] = "boolean"
      item[:type] = "tag"

      @response[:attributes] << item

    end

    @response[:groups] = []

    user.groups.order('LOWER(name)').each do |group|

      item = {}

      item[:name] = group.name
      item[:id] = group.id

      @response[:groups] << item

    end

    render 'v1response'

  end

  # ----------------------------------------------------------------------------------------------------------
  def createProspect(user, json)

    prospect = Lead.new

    prospect.team_id = user.team.id unless user.team.nil?

    prospect.user_id = user.id

    if json['system_email'].blank?
      @response[:error_text] += "'system_email' field missing: Prospects can not be created without an email\n"
      return nil
    end

    # again here is repetitions, we avoid using loop with dynamically
    prospect.each do |item|
      json["system_#{item}"].strip if json["system_#{item}"].present?
    end


    if json["group_id"].present?
      group = user.findGroup(json["group_id"])
      if group.nil?
        @response[:error_text] += "Group id specified '#{json['group_id']}' could not be found, prospect '#{prospect.email}' not created\n"
        return nil
      else
        prospect.group_id = group.id
        prospect.user_id = group.user.id
      end
    end

    if prospect.save == false
      @response[:error_text] += "Problem adding prospect '#{prospect.email}': #{prospect.errors.first}\n"
      return nil
    end

    user.customattributes.each do |catt|

      if json["custom_#{catt.id}"].present? && json["custom_#{catt.id}"].downcase == "true"
        attval = Customattributevalue.new
        attval.lead_id = prospect.id
        attval.customattribute_id = catt.id
        attval.value = json["custom_#{catt.id}"].strip
        attval.save!
      end

    end

    user.tags.each do |tag|

      if json["tag_#{tag.id}"].present?
        prospect.tags << tag
      end

    end

    return prospect
  end

  # ----------------------------------------------------------------------------------------------------------
  def newProspectv2

    information = request.raw_post


    begin
      json = JSON.parse(information)
    rescue
      @response[:error_text] = "INVALID JSON PAYLOAD"
      render 'v1response', :status => 400
      return
    end

    if json['data'].blank? || json['data'].is_a?(Array) == false
      @response[:error_text] = "Your JSON must have a data field as array."
      render 'v1response', :status => 400
      return
    end

    if json['data'].count > 30
      @response[:error_text] = "Maximum number of prospects created per call is 30."
      render 'v1response', :status => 400
      return
    end

    total = 0
    total_error = 0
    json['data'].each do |prospect|
      newlead = createProspect(user, prospect)
      if newlead.present?
        total += 1
      else
        total_error += 1
      end
    end

    @response[:total_created] = total
    @response[:total_errors] = total_error

    render 'v1response'

  end


  # ----------------------------------------------------------------------------------------------------------
  def getProspectv2
    @response[:total] = 0

    if params["query"].blank?
      @response[:error_text] = "You must have a query parameter specified"
      render 'v1response', :status => 400
      return
    end

    search = params["query"].downcase.strip

    prospect = user.leads.find_by_email(search)

    if prospect.nil?
      @response[:error_text] = "Can't find prospect '#{search}'"
      render 'v1response', :status => 400
      return
    end

    @response[:total] = 1


    @response[:data] = []

    item = {}

    item[:system_email] = prospect.email
    item[:system_firstname] = prospect.firstname
    item[:system_lastname] = prospect.lastname
    item[:system_title] = prospect.title
    item[:system_company] = prospect.company
    item[:system_phone] = prospect.phone
    item[:system_address] = prospect.address
    item[:system_website] = prospect.website
    item[:system_notes] = prospect.notes

    item[:group_id] = nil
    if prospect.group.nil? == false
      item[:group_id] = prospect.group.id
    end

    user.customattributes.each do |cust|
      cattvalue = prospect.customattributevalues.find_by_customattribute_id(cust.id)
      val = nil
      val = cattvalue.value unless cattvalue.nil?
      item["custom_#{cust.id}"] = val
    end

    user.tags.each do |tag|
      val = (prospect.tags.find_by_id(tag.id) != nil)
      item["tag_#{tag.id}"] = val
    end


    @response[:data] << item

    render 'v1response'
  end

  private
    def find_user
      @response = {}

      app_key = request.headers['app_key']
      # app_key.nil? == true is same like app_key.nil? because app_key.nil? also checking its returning true or not
      if !Rails.env.production?  && app_key.nil?
        app_key = params['app_key']
      end

      if app_key.blank?

        @response[:error_text] = "APPLICATION KEY MISSING"
        render 'v1response', :status => 400
        return

      end

      partner = Partner.find_by_app_key(app_key)
      if partner.nil?
        sleep(1)
        @response[:error_text] = "INVALID APPLICATION KEY"
        render 'v1response', :status => 401
        return
      end

      Partner.increment_counter :get_calls, partner.id

      This is already done

      api_key = request.headers['api_key']
      if Rails.env.production? == false && api_key.nil? == true
        api_key = params['api_key']
      end

      if api_key.blank?

        @response[:error_text] = "API KEY MISSING"
        render 'v1response', :status => 400
        return

      end

      user = User.find_by_api_key(app_key)
      if user.nil?
        sleep(1)
        @response[:error_text] = "INVALID API KEY"
        render 'v1response', :status => 401
        return
      end
    end


end

