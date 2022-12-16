require 'open-uri'

class UserService
  include HTTParty
  attr_reader :errors, :record

  def initialize(parameters = {})
    @parameters = parameters

    @picture = @parameters.delete(:picture)

    @errors = []
    @record = nil
    @success = false
  end

  def success?
    @success
  end

  def create
    record = User.new

    save_record(record)
  end

  def update(id)
    record = User.find(id)

    save_record(record)
  end

  def destroy(id)
    record = User.find(id)

    if record.destroy
      @success = true
      @record = record
    else
      @errors = record.errors.full_messages
    end
  end

  def import(params)
    Kernel.puts "Importação iniciada."

    response = HTTParty.get('https://randomuser.me/api', query: params)

    parsed_body = JSON.parse(response.body, symbolize_names: true)

    parsed_body[:results].each do |parameters|
      parameters[:name] = "#{parameters[:name][:first]} #{parameters[:name][:last]}"
      parameters[:picture] = parameters[:picture][:large]

      picture_url = parameters.delete(:picture)
      downloaded_picture = URI.parse(picture_url).open

      record = User.new(parameters)

      record.picture.attach(io: downloaded_picture, filename: picture_url.split('/').last.chomp(".jpg"))

      if record.save
        Kernel.puts "Usuário #{record.id} importado com sucesso."
      else
        Kernel.puts "Erro na importação de usuário: #{parameters[:name]}"
      end
    end

    Kernel.puts "Importação finalizada."
  rescue StandardError => e
    Rails.logger.error(e.message)
    Kernel.puts "ERRO: #{e.message}"
  end

  private

  def save_record(record)
    record.assign_attributes(@parameters)

    record.picture = @picture if @picture.present? && !@picture.is_a?(String)

    if record.save
      @success = true
      @record = record
    else
      @errors = record.errors.full_messages
    end
  end
end
