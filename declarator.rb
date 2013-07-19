#!/usr/bin/env ruby

require 'yaml'
require 'mechanize'
require 'highline/import'

class Declarator
  CONF_FILE = 'config.yml'
  BASE_FILE = 'base.xml'
  LOGIN_URL = 'https://declaraciones.sri.gob.ec/tuportal-internet/index.jsp'
  UPLOAD_URL = 'https://declaraciones.sri.gob.ec/rec-declaraciones-internet/recepcion/mostrarDeclaracion.jspa?codVF=04201201'
  MONTHS_ES = %w{ENERO FEBRERO MARZO ABRIL MAYO JUNIO JULIO AGOSTO SEPTIEMBRE OCTUBRE NOVIEMBRE DICIEMBRE}

  def initialize
    conf = YAML::load_file CONF_FILE
    @id = conf['cedula'].to_s
    @passwd = ask('Ingrese password') { |q| q.echo = '*' }
    @razon = conf['razon_social'].to_s
    # Past month's declaration
    @month = Date.today.month - 1
    @year = Date.today.year
    @dest = "04ORI_#{MONTHS_ES[@month - 1]}#{@year}.xml"
  end

  # Create the XML declaration from a base file
  def create_declaration
    if File.exists? @dest
      puts "El archivo #{@dest} ya existe. Abortando"
      exit 1
    end

    replacements = {
      '%%CEDULA%%' => @id,
      '%%RAZON%%' => @razon,
      '%%MONTH%%' => @month,
      '%%YEAR%%' => @year
    }
    File.open(BASE_FILE) do |file|
      content = file.read.gsub /%%\w+%%/, replacements
      File.open(@dest, 'w') { |f| f.write content }
    end

    self
  end

  # Upload the declaration using Mechanize
  def submit
    agent = Mechanize.new { |a| a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE }

    # Login
    agent.get LOGIN_URL
    f = agent.page.form 'loginForm'
    f.j_username = "#{@id}001"
    f.j_password = @passwd
    f.submit

    # Upload
    agent.get UPLOAD_URL
    f = agent.page.form 'formularioForm'
    f.mes = @month
    f.anio = @year
    # Declaracion sin valor a pagar
    f.formaPago = 'DS'
    f.file_uploads.first.file_name = @dest
    f.submit

    # Confirmation
    f = agent.page.form 'frm2'
    f.submit
    puts "Subida exitosa del archivo #{@dest}"

    self
  end
end

if __FILE__ == $0
  Declarator.new.create_declaration.submit
end
