function(doc, req){
	
	var opt_data = {};
	opt_data.req = req;
	opt_data.doc = doc;
	
  %output%
	
	return html.template(opt_data);	
	
};