#TODO: 
#      proper attribution format
#      verify: account for failed uploads, retries, check python ia wrapper
#      

# Check settings for access keys and set variables accordingly
if Meteor.settings?.HTH?.app_id and Meteor.settings?.HTH?.app_key
  hth_id = Meteor.settings.HTH.app_id
  hth_key = Meteor.settings.HTH.app_key
  console. log hth_id
  console. log hth_key
else
  console.log "no HTH"
if Meteor.settings?.IA?.access and Meteor.settings?.IA?.secret
  ia_access =  Meteor.settings.IA.access
  ia_secret=  Meteor.settings.IA.secret
  console. log ia_access 
  console. log ia_secret
else
  console.log "no IA"

# Number used in thewholeshebang command, arbitrary
collectionSize = 100000

# If photos are on average about 1.5 mb, it's nice to limit our uploads to 15 mb per iteration, arbitrary
rowsPerRequest = 10

Meteor.startup ->
  # Make the intial call for ROWSPERREQUST items from the HackTheHearst API
  result = Meteor.http.get 'https://apis.berkeley.edu/hearst_museum/select?q=objname_s:headdress&wt=json&indent=on',
    headers:
      app_id: hth_id
      app_key:hth_key,


  # Force parsing of JSON, because response content type is text/plain instead of JSON
  result.data = JSON.parse result.content

  # Loop through each individual row (item from the JSON response)
  for item in result.data.response.docs
    id = item.csid_s
    # Loop through each of the item's blobs (photo ids)
    if item.blob_ss
      for blob in item.blob_ss
        link = "https://dev.cspace.berkeley.edu/pahmav2_project/imageserver/blobs/#{ blob }/content"

        # Get the image from the pahmav project imageserver, load it into a buffer.
        image = Meteor.http.get link,
          responseType: 'buffer'

        postLink = "http://s3.us.archive.org/testpahma_#{ id }/#{ blob }.jpg"
        
        # Upload the image data as to postLink
        console.log Meteor.http.put postLink,
          content: image.content
          headers:
            'x-archive-meta01-collection': 'test_collection'
            'x-amz-auto-make-bucket': '1'
            'x-archive-meta-mediatype': 'images'
            authorization: 'LOW #{ ia_access }:#{ ia_secret }'

      # Update the item's xml metadata
      metaLink = "http://archive.org/metadata/testpahma_#{ id }"
      for attr of item
        patch = JSON.stringify
          add: "/#{ attr }"
          value: "#{ item[attr] }"
        if typeof patch != "undefined"
          console.log Meteor.http.post metaLink,
            params:
              '-patch': patch
              '-target': 'metadata'
              access: ia_access
              secret: ia_secret

      # Update the item's json metadata

      return
