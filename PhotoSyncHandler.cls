global class PhotoSyncHandler {
	
	/*
	
	//Sync the user's picture
	String pictureUrl = null;
	if (data.provider == 'Facebook') {
		pictureUrl = 'https://graph.facebook.com/' + data.identifier + '/picture?type=large';
	} else if (data.provider == 'LinkedIn'){
		pictureUrl = data.attributeMap.get('picture-url');
	} else {
		pictureUrl = data.attributeMap.get('picture');
	}
	if (pictureUrl != null) PhotoSyncHandler.syncPhoto(userid, data.attributeMap.get('sfdc_networkid'), pictureUrl);
		
	*/
    
    @Future(callout=true)
    public static void syncPhoto(String userId, String communityId, String url){
        System.debug('userId: ' + userid + ' communityId: ' + communityId + ' url: ' + url);
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        if(res.getStatusCode() == 302) {
           req.setEndpoint(res.getHeader('Location'));
           res = h.send(req);
        }
        if( (res.getStatusCode() >= 200) && (res.getStatusCode() < 300) )  {
            ConnectApi.BinaryInput photo = new ConnectApi.BinaryInput(res.getBodyAsBlob(), 'image/jpg', 'userphoto.jpg');
            ConnectApi.UserProfiles.setPhoto(communityId, userId, photo);
        }
    }

}