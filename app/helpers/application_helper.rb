module ApplicationHelper
    require 'json'
    
    def ns_url_org(organization)
        if (organization == "0")
             init_NS_Connector('TSTDRV1681055', 'tstdrv1681055',3) #ONE WORLD
            return ns_url("tstdrv1681055","594")
        else
            init_NS_Connector('TSTDRV1511400', 'tstdrv1511400',41) #ENTERPRISE
            return ns_url("tstdrv1511400","177")
        end
    end

    def ns_url(organization_id, number)
        return "https://#{organization_id}.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=#{number}&deploy=1" #"https://tstdrv1681055.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=#{number}&deploy=1"
    end

    def ns_post(url, body)
        return HTTParty.post(url || ns_url("tstdrv1681055","611"), :format => :json, :body => body.to_json, :headers => ns_headers(true))
    end

    def ns_get(url, type=false) 
        return HTTParty.get(url, headers: ns_headers(type))
    end

    def ns_put(url, body)
        return HTTParty.put(url || ns_url("tstdrv1681055","611"), :format => :json, :body => body.to_json, :headers => ns_headers(true)) 
    end

    def init_NS_Connector(account_id, organization_id, role=nil)
        NSConnector::Config.set_config!({
            :account_id  => account_id,
            :email       => "alan@dmcstrategicit.com",#"abneed@dmcstrategicit.com",
            :password    => "123456aBcd",#"24981149Rc204863",
            :role        => role || 3,
            :restlet_url => "https://#{organization_id}.restlets.api.netsuite.com/app/site/hosting/restlet.nl" #'https://tstdrv1681055.restlets.api.netsuite.com/app/site/hosting/restlet.nl' #url_fd_restlet,
          })
    end

    #This is pretended to return the long header with 2 params when performing a Post,Put,Destroy(also this is not intended and is no common behavior) and the short one if its a Get
    def ns_headers(long) 
        if long
            return { 
                "Content-Type"  => "application/json",
                "Authorization" => NSConnector::Restlet.auth_header 
            }
        else
            return {
                "Accept" => "application/json" 
            }
        end
    end

    #this helps to decode netsuite json text result
    def decode_ns_result(item)
        ihashable = ActiveSupport::JSON.decode(item) 
        p 'till here going well'
        return JSON.parse(ihashable) || ihashable 
    end
end
