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
          console.log id
          if item.blob_ss
            for blob in item.blob_ss
              console.log blob
              link = 'https://dev.cspace.berkeley.edu/pahmav2_project/imageserver/blobs/' + blob + '/content'
              console.log link
              postLink = 'http://s3.us.archive.org/hearst-anthro-musem' + blob + '.jpg'
              Meteor.http.get link,
                (e,r) ->
                  Meteor.http.post postLink,
                    (e,r) ->
                      console.log r
