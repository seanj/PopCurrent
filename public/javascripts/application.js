// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function popup(url)
{
	newwindow=window.open(url,'name','height=150,width=450');
	if (window.focus) {newwindow.focus()}
	return false;
}