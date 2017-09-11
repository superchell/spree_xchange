# encoding: UTF-8

=begin
spree_core/lib/spree/core/permalinks.rb
-          other = self.class.all(:conditions => "#{field} LIKE '#{permalink_value}%'")
   	 50 	
+          other = self.class.all(:conditions => ["#{field} LIKE ?", "#{permalink_value}%"])

Installation steps
rails _3.2.6_ new spree6 -d mysql
cd spree6
create database, and edit config/database.yml
spree install --version=1.1.2
failure
bundle update
spree install --version=1.1.2
add to Gemfile
gem 'rails-i18n'
gem 'spree_i18n', :git => 'https://github.com/2rba/spree_i18n'
gem 'spree_xchange', :path => '../spree_xchange'
gem 'spree_simpleco', :path => '../spree_simpleco'
bundle

edit config/application.rb
     config.i18n.default_locale = :uk
rake spree_xchange:install:migrations
rake db:migrate





=end
require 'digest/md5'
require "nokogiri"


class Exchange1cController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate


  def test
    br = {:section => 'test', :return => 'test', :email => 'test@42team.ru'}
    render :xml => br.to_xml
  end

  def main
    case params[:mode]
      when 'checkauth'
        time = Time.now.to_i.to_s
        Dir.mkdir('/tmp/' + Digest::MD5.hexdigest(@user.email) + '_' + time)

        render plain: "success\nsession_id\n#{time}\n"
      when 'init'
        render plain: "zip=no\nfile_limit=1024000"
      when 'query'
        builder = Nokogiri::XML::Builder.new(:encoding => 'utf-8') do |xml|
          xml.КоммерческаяИнформация(ВерсияСхемы: '2.03') {
            Spree::Order.where(id: 1069267030).all.each do |order|
              xml.Документ {
                xml.Ид order.id
                xml.Номер order.id
                xml.Дата order.created_at.strftime('%Y-%m-%d')
                xml.ХозОперация 'Заказ товара'
                xml.Роль 'Продавец'
                xml.Валюта 'грн'
                xml.Курс '1'
                xml.Сумма order.item_total
                xml.Контрагенты {
                  xml.Контрагент {
                    xml.Ид order.user_id
                    xml.Наименование order.email
                    xml.Роль 'Покупатель'
                    xml.ПолноеНаименование order.email
                    xml.Фамилия order.bill_address.lastname
                    xml.Имя order.bill_address.firstname
                  }
                }
                xml.Время order.created_at.strftime('%H:%M:%S')
                xml.Комментарий order.special_instructions
                xml.Товары {
                  order.line_items.each {
                      |item|
                    xml.Товар {
                      xml.Ид str_add_dash item.variant.product.xchange_id.unpack('H*').first.to_s
                      xml.Наименование item.variant.product.name
                      xml.ЦенаЗаЕдиницу item.price
                      xml.Количество item.quantity
                      xml.Сумма item.price*item.quantity
                    }
                  }
                }
              }
            end
          }
        end
        render :xml => "\xEF\xBB\xBF" + builder.to_xml #'<?xml version="1.0" encoding="UTF-8"?><КоммерческаяИнформация ВерсияСхемы="2.03" ДатаФормирования="2007-10-30">'+"\n"+'</КоммерческаяИнформация>'
      when 'success'
        render plain: 'ok'
      when 'file'

        filename = params[:filename]

        if filename =~ /import[\d]*_[\d]*.xml/ # файл импорта каталога товаров

          filename_with_bom = '/tmp/' + Digest::MD5.hexdigest(@user.email) + '_' + cookies[:session_id].to_s + '/bom_' + filename
          filename_clean = '/tmp/' + Digest::MD5.hexdigest(@user.email) + '_' + cookies[:session_id].to_s + '/' + filename

          File.open(filename_with_bom, 'wb') {|f| request.body.set_encoding("UTF-8"); f.write(request.body.read)}
          file = File.open(filename_with_bom, 'r:bom|utf-8')
          File.open(filename_clean, 'wb') {|f| f.write(file.read)}

          answer = 'success'

        elsif filename =~ /import_files/ # иные файлы импорта

          filename = '/tmp/' + Digest::MD5.hexdigest(@user.email) + '_' + cookies[:session_id].to_s + '/' + filename
          dirname = File.dirname(filename)

          FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
          File.open(filename, 'wb') {|f| f.write request.body.read}

          ids = File.basename(filename, File.extname(filename)).split('_')

          Spree::Product.where(xchange_id: ids[0]).first

          answer = 'success'

        elsif filename =~ /offers[\d]*_[\d]*.xml/ # файл импорта заказов
          answer = 'success'
        else
          answer = 'failure\nПроизошла ошибка при загрузке файлов импорта'
        end

        render plain: answer

      when 'import'

        filename = params[:filename]

        if filename =~ /import[\d]*_[\d]*.xml/

          filename = '/tmp/' + Digest::MD5.hexdigest(@user.email) + '_' + cookies[:session_id].to_s + '/' + filename

          xml = Nokogiri::XML(File.open(filename)).remove_namespaces!

          # catalog import

          taxonomy = Spree::Taxonomy.where(name: 'Каталог').first

          if taxonomy.nil?
            taxonomy = Spree::Taxonomy.create(:name => 'Каталог')
            taxon = taxonomy.root
            taxon.permalink = 'catalog'
            taxon.save
          end

          root_group = taxonomy.taxons.where(parent_id: nil).first

          xml.xpath('КоммерческаяИнформация/Классификатор/Группы').each do |groups|
            groups.xpath('Группа').each do |group_node|
              process_group(group_node, root_group, taxonomy)
            end
          end

          # products import

          xml.xpath('//Товар').each do |node_product|

            id = node_product.xpath('Ид').first.content.gsub('-', '')

            if (i = id.index('#')).nil?
              xchange_id = id
            else
              xchange_id = id[0..(i - 1)]
              variant_id = id[(i + 1)..-1]
            end

            product = Spree::Product.where(xchange_id: xchange_id).first_or_create

            product.name = node_product.xpath('Наименование').first.content
            description = node_product.xpath('Описание').first
            product.description = description.nil? ? '' : description.content
            product.xchange_id = xchange_id
            product.price = 0 if product.price.nil?

            group_id = node_product.xpath('Группы/Ид').first.content.gsub('-', '')

            group = Spree::Taxon.where(xchange_id: group_id).first

            product.taxons << group unless product.taxons.exists?(group.id)

            product.shipping_category_id = 1
            product.available_on = Time.zone.now

            attachment_path = Find.find(File.dirname(filename)).select { |p| p.include?(xchange_id) }.first

            logger.info 'attachment_path||||||||||||||||||||||||||||||||||||||D'
            logger.info filename
            logger.info File.dirname(filename)
            logger.info xchange_id
            logger.info attachment_path
            logger.info 'attachment_path||||||||||||||||||||||||||||||||||||||D'

            if attachment_path
              Spree::Asset.new(attachment: File.open(attachment_path), viewable: product)
            end

            product.save

            if i #fixme whaat??

              variant = product.variants.where('xchange_id = ?', variant_id).first

              if variant.nil?
                variant = product.variants.create
                variant.xchange_id = variant_id
                variant.price=0
                variant.save
              end

              node_product.xpath('ХарактеристикиТовара/ХарактеристикаТовара').each do |xoption|

                name = xoption.xpath('Наименование').first.content

                option_name = "xchange-#{name}".to_param
                option_type = Spree::OptionType.where(name: option_name).first

                if option_type.nil?
                  option_type = Spree::OptionType.new(name: option_name, presentation: name)
                  option_type.save
                end

                option_value_str = xoption.xpath('Значение').first.content
                option_value = Spree::OptionValue.where(option_type_id: option_type, name: option_value_str).first

                if option_value.nil?
                  option_value = option_type.option_values.create(name: option_value_str, presentation: option_value_str)
                end

                unless variant.option_values.exists?(option_value)
                  variant.option_values << option_value
                  variant.save
                end

              end
            end
          end


        end

        when 'offers.xml'
          filename = 'offers.xml'
          filename = '/tmp/' + Digest::MD5.hexdigest(@user.email) + '_' + cookies[:session_id].to_s + '/' + filename
          xml = Nokogiri::XML(File.open(filename))
          r = xml.xpath("//Предложение")
          r.each {
              |nodeOffer|
            id = nodeOffer.xpath("Ид").first.content.gsub('-', '')
            if ((i = id.index('#')).nil?)
              xchange_id = id
              product = Spree::Product.where('xchange_id = UNHEX(?)', xchange_id).first
              variant = product
            else
              xchange_id = id[0..(i-1)]
              variant_id = id[(i+1)..-1]
              product = Spree::Product.where('xchange_id = UNHEX(?)', xchange_id).first
              variant = product.variants.where('xchange_id = UNHEX(?)', variant_id).first
            end
            variant.price = nodeOffer.xpath('Цены/Цена/ЦенаЗаЕдиницу').first.content.to_i
            variant.count_on_hand = nodeOffer.xpath('Количество').first.content.to_i
            product.available_on = Time.now
            #if variant.count_on_hand > 0
            #  product.available_on = Time.now
            #else
            #  product.available_on =nill
            #end
            product.save
            variant.save
            #p v
            #hash = {}
            #p.children.each do |node|
            #    hash[node.node_name] = node.content
            #  end
            #p hash
          }

        else
          filename = '/tmp/' + Digest::MD5.hexdigest(@user.email) + '_' + cookies[:session_id].to_s + '/' + Digest::MD5.hexdigest(params[:filename])
        end

        render plain: 'success'
    end
  end

  private

  def str_add_dash(str)
    str.scan(/^(.{8})(.{4})(.{4})(.{4})(.{12})$/).join('-')
  end

  def process_group(group_node, parent_group, taxonomy)
    xchange_id = group_node.xpath('Ид').first.content.gsub('-', '')

    group = Spree::Taxon.where('xchange_id = ?', xchange_id).first_or_create

    group.xchange_id = xchange_id
    group.parent_id = parent_group.id
    group.name = group_node.xpath('Наименование').first.content
    group.taxonomy_id = taxonomy.id

    group.save

    group_node.xpath("Группы/Группа").each do |group_node2|
      process_group(group_node2, group, taxonomy)
    end
  end

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      @user = Spree::User.find_by_email(username)
      valid_password = Spree::User.find_by_email(username).valid_password?(password)
      @user && @user.has_spree_role?("admin") && valid_password
    end
  end

end
