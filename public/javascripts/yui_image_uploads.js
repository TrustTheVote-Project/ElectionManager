/*
yuiImgUploader
 
variables:
 rte: The YAHOO.widget.Editor instance
 upload_url: the url to post the file to
 upload_image_name: the name of the post parameter to send the file as
 
for version 2.8.0r4
 
Your server must handle the posted image.  You must return a JSON object
with the result url that the image can be viewed at on your server.  If
the upload fails, you can return an error message.  For successful
uploads, the status must be set to UPLOADED.  All other status messages,
or the lack of a status message is interpreted as an error.  IE will
try to open a new document window when the response is returned if your
content-type header on your response is not set to 'text/javascript'
 
Example Success:
{status:'UPLOADED', image_url:'/somedirectory/filename'}
Example Failure:
{status:'We only allow JPEG Images.'}
 
*/
 
function yuiImgUploader(rte, editor_name, upload_url, upload_image_name) {
   // customize the editor img button
 
 
   YAHOO.log( "Adding Click Listener" ,'debug');
   rte.addListener('toolbarLoaded',function() {
	   rte.addListener ( 'afterOpenWindow', function(o) {
		   try {
 
			   var imgPanel = new YAHOO.util.Element(editor_name + '-panel');
 
			   imgPanel.on ( 'contentReady', function() {
 
				   try {
					   var Dom=YAHOO.util.Dom;
 
					   if (! Dom.get(editor_name + '_insertimage_upload'))
					   {
 
						   var label = document.createElement('label');
						  label.innerHTML='<strong>Upload:</strong>'+
					 '<input type="file" id="' +
				  editor_name + '_insertimage_upload" name="'+upload_image_name+
					 '" size="10" style="width: 300px" />'+
					 '</label>';
 
 
 
						   var img_elem = Dom.get(editor_name + '_insertimage_url');
 
						   var doc = Dom.getAncestorByTagName(img_elem, 'form');
 
						   if(doc){
							   doc.encoding = 'multipart/form-data';
								Dom.insertAfter(label, img_elem.parentNode);
						   }else{
							   doc = document.createElement("form");
							   doc.encoding = 'multipart/form-data';
							   doc.method = 'POST';
							   Dom.insertBefore(doc, img_elem.parentNode);
						   }
 
						//   Dom.getElementsByTagName(img_elem)[0].encoding = 'multipart/form-data';
 
 
 
						   YAHOO.util.Event.on ( editor_name + '_insertimage_upload', 'change', function(ev) {
							   YAHOO.util.Event.stopEvent(ev); // no default click action
 
							   YAHOO.util.Connect.setForm ( doc/*img_elem.form*/, true, true );
							   var c = YAHOO.util.Connect.asyncRequest(
							   'POST', upload_url, {
								   upload:function(r){
									   try {
 
										   // strip pre tags if they got added somehow
										   resp=r.responseText.replace( /<pre>/i, '').replace ( /<\/pre>/i, '');
										   var o=eval('('+resp+')');
 
										   if (o.status=='UPLOADED') {
											   Dom.get(editor_name + '_insertimage_upload').value='';
											   Dom.get(editor_name + '_insertimage_url').value=o.image_url;
											   // tell the image panel the url changed
											   // hack instead of fireEvent('blur')
											   // which for some reason isn't working
											   Dom.get(editor_name + '_insertimage_url').focus();
										   //	Dom.get(editor_name + '_insertimage_upload').focus();
										   } else {
											   alert ( "Upload Failed: "+o.status );
										   }
 
									   } catch ( eee ) {
										   YAHOO.log( eee.message, 'error' );
									   }
								   }
							   }
							   );
							   return false;
						   });
					   }
				   }
			catch ( ee ) {YAHOO.log( ee.message, 'error' );}
 
			   });
		   } catch ( e ) {
			   YAHOO.log( e.message, 'error' );
 
		   }
	   });
   });
 
}
