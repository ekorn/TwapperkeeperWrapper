require 'json'
require 'net/http'

class Twapperkeeper
  attr_accessor :apikey

#http://api.twapperkeeper.com/2/notebook/tweets/?apikey=xxxx&name=xxxxx&type=xxxx[&optional parameters]
#GET parmaters

#apikey [required]
#type (hashtag, keyword, person, collection, person-collection) [required]
#name [required]

#lang [optional - ISO-639-1 2 letter code included in tweet metadata]
#max_id [optional - maximum twitter id]
#since_id [optional - minimum twitter id]
#since [optional - start date - format = YY-MM-DD]
#until [optional - end date - format = YY-MM-DD]
#order_by [optional - a = ascending, d = descending (default)]
#nort [optional set to 1 to remove all tweets starting with RT, default = 0]
#text [optional - tweet text to search for]
#from_user [optional - twitter username of sender]
#latitude | longitude | radius [optional - must include each parameters individually - radius in km]
#rpp = results per page [optional - but default set to 10, max allowed = 1000]
#page [optional - default = 1] 
 
  def getTweets(type,name, parameter={})
    tweets_url = "http://api.twapperkeeper.com/2/notebook/tweets/?apikey="
    query = "#{tweets_url}#{apikey}"
    if type == "hashtag" || type == "keyword" || type == "person" || type == "collection" || type == "person-collection"
        query+= "&type=#{type}"
    else
        raise ArgumentError, "No valid type given", caller
    end
    if name != nil
        query+= "&name=#{name}"
    else
       raise ArgumentError, "No valid name given", caller
    end  
    #optional Parameter
    if parameter[:lang] != nil
        query+= "&lang=#{parameter[:lang]}"
    end
    if parameter[:max_id] != nil
        query+= "&max_id=#{parameter[:max_id]}"
    end
    if parameter[:since_id] != nil
        query+= "&since_id=#{parameter[:since_id]}"
    end    
    if parameter[:until] != nil
        query+= "&until=#{parameter[:until]}"
    end    
    if parameter[:order_by] == "a" || parameter[:order_by] == "d"
            query+= "&order_by=#{parameter[:order_by]}"
    end  
    if parameter[:nort] == 0 || parameter[:nort] == 1
            query+= "&nort=#{parameter[:nort]}"
    end         
    if parameter[:text] != nil
        query+= "&text=#{parameter[:text]}"
    end    
    if parameter[:from_user] != nil
        query+= "&from_user=#{parameter[:from_user]}"
    end    
    if parameter[:latitude] != nil
        query+= "&latitude=#{parameter[:latitude]}"
    end
    if parameter[:longitude] != nil
        query+= "&longitude=#{parameter[:longitude]}"
    end  
    if parameter[:radius] != nil
        query+= "&radius=#{parameter[:radius]}"
    end  
    if parameter[:rpp] != nil
        query+= "&rpp=#{parameter[:rpp]}"
    end     
    if parameter[:page] != nil
        query+= "&page=#{parameter[:page]}"
    end                                                   
    return sendRequest(query)
  end

#notebook info
#http://api.twapperkeeper.com/notebook/info/?apikey=xxxx&type=xxxx&name=xxxx&namelike=xxxx&desclike=xxxx
#GET parmaters
#apikey [required], 

#type (hashtag, keyword, person, collection, person-collection) [optional] 
#name [optional]
#namelike [optional]
#desclike [optional]

  def getInfo(parameter)
    info_url = "http://api.twapperkeeper.com/notebook/info/?apikey="
    query = "#{info_url}#{apikey}"
     if parameter[:type] != nil
         
        if parameter[:type] == "hashtag" || parameter[:type] == "keyword" || parameter[:type] == "person" || parameter[:type] == "collection" || parameter[:type] == "person-collection"
            query+= "&type=#{parameter[:type]}"
        end
    end
    
    if parameter[:name] != nil
        query+= "&name=#{parameter[:name]}"
    end
    if parameter[:namelike] != nil
        query+= "&namelike=#{parameter[:namelike]}"
    end
    if parameter[:desclike] != nil
        query+= "&desclike=#{parameter[:desclike]}"
    end        
     
    return sendRequest(query)
  end

#create a notebook
#http://api.twapperkeeper.com/notebook/create/?apikey=xxxxx&name=abcdefg&type=hashtag&description=This is a test.&created_by=jobrieniii&user_id=1234
#POST arguments
#apikey [required]
#type (hashtag, keyword, person, collection, person-collection) [required]
#name [required]
#created_by [required]
#description [required]

#tags[optional]
#n1,n2,n3,n4,n5 [notebook 1,2,3,4,5 - only for type collection or person-collection - collections must have at least one archive - and do not mix together person and hashtag / keyword archives or errors will occur!]  
  def createArchive(type, name, created_by, description, parameter="")
    create_url = "http://api.twapperkeeper.com/notebook/create/?apikey="
    query = "#{create_url}#{apikey}"
        if type == "hashtag" || type == "keyword" || type == "person" || type == "collection" || type == "person-collection"
            query+= "&type=#{type}"
        else
            raise ArgumentError, "No valid type given", caller
        end
    if name != nil
        query+= "&name=#{name}"
    else
       raise ArgumentError, "No valid name given", caller
    end
    if created_by != nil
        query+= "&created_by=#{created_by}"
    else
       raise ArgumentError, "No valid created_by given", caller
    end
    if description != nil
        query+= "&description=#{description}"
    else
       raise ArgumentError, "No valid description given", caller
    end        
    if parameter != ""
        query+= parameter
    end         
    return sendRequest(query)
  end    
  
  def initialize(apikey)
    @apikey = apikey
  end
  
  
  def sendRequest(url)
       resp = Net::HTTP.get_response(URI.parse(url))
       data = resp.body

       # we convert the returned JSON data to native Ruby
       # data structure - a hash
       result = JSON.parse(data)

       # if the hash has 'Error' as a key, we raise an error
       if result.has_key? 'Error'
          raise "web service error"
       end
       
       if result['status'] == 1
        return result
       else
        return false
       end
   end

  private :sendRequest
end
