class QueryhandleController < ApplicationController
    protect_from_forgery with: :null_session
    #include Upvise::SalesOrderHelper 
    #require 'json'

    def init_connector
        init_NS_Connector('TSTDRV1681055', 'tstdrv1681055', 3)
    end

    def decode_ns_result(item)
        ihashable = ActiveSupport::JSON.decode(item) 
        p 'till here going well'
        return JSON.parse(ihashable) || ihashable 
    end    

    def obtain
        init_connector()

        item_ns = params['item']
        item_result = ns_get("https://tstdrv1681055.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=627&deploy=1&recordtype=serializedassemblyitem&id=#{item_ns}",true)
        if item_result.code == 400
            item_result = ns_get("https://tstdrv1681055.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=627&deploy=1&recordtype=inventoryitem&id=#{item_ns}",true)
        end

        code = item_result.code
        aux = item_result 
        p 'item result'
        p item_result
        item_result = decode_ns_result(item_result.body)['fields']        
        p 'trying to read get'

        sales_item = {
            :date => (Time.now.to_f * 1000).to_i,
            :discount => 0, 
            :categoryid => item_result['itemtype'],
            :comission => 0,
            :currency => "",
            :code => "",
            :custom => "",
            :description => "Stock description: #{item_result['stockdescription']} \nSale conversion rate: #{item_result['saleconversionrate']} \nOriginal cost: #{item_result['origcost']} \nProduct type: #{item_result['itemtype']} \nNetsuite item id:#{item_result['id']} \nNetsuite original id:#{item_result['itemidorig']}",
            :lowstock => 0, 
            :manufacturerid => "",
            :owner => "",
            :price => item_result['cost'],
            :name => item_result['purchasedescription'],
            :purchaseprice => item_result['cost'],
            :status => 0,
            :type => 0,
            :stock => item_result['totalquantityonhand'],
            :termfileid => "",
            :unitid => "",
            :vat => 0,
            :wholesaleprice => 0
        }
        
        p 'responding'
        
        respond_to do |format|     
            response.set_header('Access-Control-Allow-Origin', '*')
            response.set_header('Access-Control-Allow-Credentials','true')
            response.set_header('Accept', 'application/json')
            format.json {render status: code,  json: {:product_sanitized => sales_item}}
        end    
    end
end
