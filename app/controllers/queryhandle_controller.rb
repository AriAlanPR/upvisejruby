class QueryhandleController < ApplicationController
    #include_package 'com.upvise.client'
    def obtain
        init_connector()

        item_ns = query_params['item']
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

    def push_from_netsuite      
        #initialize json as java json object
        sales_product = java_json.new
        sales_product.put("categoryid", query_params['categoryid'])
        sales_product.put("description", query_params['description'])
        sales_product.put("lowstock", query_params['lowstock'])
        sales_product.put("price", query_params['price'])
        sales_product.put("name", query_params['name'])
        sales_product.put("purchaseprice", query_params['purchaseprice'])
        sales_product.put("type", query_params['type'])
        sales_product.put("stock", query_params['stock'])
        sales_product.put("date", (Time.now.to_f * 1000).to_i)
        #insert product as type 0 1 product to upvise
        query = uv_query.insert('sales.products', sales_product)
        #verify it exists
        where = "name='#{query_params['name']}' AND price=#{query_params['price']} AND type=#{query_params['type']}"
        status = uv_query.select('sales.products', where) ? 200 : 401
        resolve = status == 200 ? {:resolve => sales_product.to_s} : {:reject => "Couldn't add values and object to upvise cloud database"}
        #upvise_test_code(sales_product)

        respond_to do |format|     
            response.set_header('Access-Control-Allow-Origin', '*')
            response.set_header('Access-Control-Allow-Credentials','true')
            response.set_header('Accept', 'application/json')
            format.json {render status: status,  json: resolve}
        end 
    end

    def get_listof_upvise_products
        query = uv_query.select('sales.products', 'type=0')
        products = Array.new
        query.each do |product|
            products << product.getString("name") #push param name form product to products array
        end

        respond_to do |format|     
            response.set_header('Access-Control-Allow-Origin', '*')
            response.set_header('Access-Control-Allow-Credentials','true')
            response.set_header('Accept', 'application/json')
            format.json {render status: 200,  json: {:upvise_listof_products => products}}
        end 
    end

    def get_single_upvise_product
        product = uv_query.selectId('sales.products', query_params['item'])

        respond_to do |format|     
            response.set_header('Access-Control-Allow-Origin', '*')
            response.set_header('Access-Control-Allow-Credentials','true')
            response.set_header('Accept', 'application/json')
            format.json {render status: 200,  json: {:upvise_product => product.getString("name")}}
        end 
    end


    def insert_contact
        contact = java_json.new
        contact.put("id", "1")
        contact.put("contact", "Cambria")
        contact.put("name", "Jruby cooler")
        contact.put("company", "Java and Ruby")
        contact.put("subsidiary", "3")
        contact.put("phone", "?")
        contact.put("email", "d@itneuevolaredo.com")
        contact.put("date", (Time.now.to_f * 1000).to_i)

        query = uv_query.insert('netvise.contact', contact)

        respond_to do |format|     
            response.set_header('Access-Control-Allow-Origin', '*')
            response.set_header('Access-Control-Allow-Credentials','true')
            response.set_header('Accept', 'application/json')
            format.json {render status: 200,  json: {:result => query}}
        end 
    end

    def upvise_test_code(testingitem)
        # standard Java platform via their full paths.
        frame = javax.swing.JFrame.new("Window") # Creating a Java JFrame
        label = javax.swing.JLabel.new(testingitem.to_s)

        # We can transparently call Java methods on Java objects, just as if they were defined in Ruby.
        frame.add(label)  # Invoking the Java method 'add'.
        frame.setDefaultCloseOperation(javax.swing.JFrame::EXIT_ON_CLOSE)
        frame.pack
        frame.setVisible(true) 
    end

    def query_params
        p params
        params.require(:queryhandle).permit(:format,:id, :categoryid, :description, :lowstock, :price, :purchaseprice, :name, :type, :stock, :item)
    end
end
