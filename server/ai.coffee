Meteor.startup ->
  Meteor.http.get 'https://apis.berkeley.edu/hearst_museum/select?q=objname_s:headdress&wt=json&indent=on',
    headers:
      app_id:'3e5e6d21'
      app_key:'8c88f1f9a30eb28c1737d96aa737ee87',
    (e, r) ->
      if e
        console.log(e)
      else
        s = r.content
        json = EJSON.parse s
        items = json.response.docs
        for item in items
          id = item.csid_s
          if item.blob_ss
            for blob in item.blob_ss
              link = 'https://dev.cspace.berkeley.edu/pahmav2_project/imageserver/blobs/' + blob + '/content'
              postLink = 'http://s3.us.archive.org/test_collection/' + blob + '.jpg'
              Meteor.http.get link,
                (e,r) ->
                  Meteor.http.put postLink, r,
                    headers:
                      authorization: #accesskeys here,
                    (e,r) ->
                      console.log postLink
                      console.log r 
 
