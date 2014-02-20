/**
*
* @author Adrian J. Moreno
* @email amoreno@iknowkungfoo.com
* @description Custom JSON renderer used to convert CFML application queries for use with jQuery DataTables.
* @version 3.0
* @requirements ColdFusion 9.0+ or Railo 4+
* @Repo: https://github.com/iknowkungfoo/cfquery-to-json
*
*/

component output="false" extends="ArrayCollection" accessors="true" {

	property type="numeric" name="echo" default="-1";
	property type="numeric" name="totalRecords" default="0";
	property type="numeric" name="totalDisplayRecords" default="0";

	public DataTables function init() {
		setContentType("json");
		setDataHandle(false);
		setDataFormat("array");
		setDataKeyCase("lower");
		setEcho(-1);
		setTotalRecords(0);
		setTotalDisplayRecords(0);
		return this;
	}

	public void function setData( required query data ){
		variables.data = arguments.data;
		if (structKeyExists(arguments.data, "total_records")){
			setTotalRecords( val(arguments.data.total_records) );
			setTotalDisplayRecords( val(arguments.data.total_records) );
		} else {
			setTotalRecords( arguments.data.recordcount );
			setTotalDisplayRecords( arguments.data.recordcount );
		}

	}

	public string function $renderdata(){
		var rs = {};
		if (getEcho() GTE 0) {
			rs["sEcho"] = val(getEcho());
		}
		if (getTotalRecords() GT 0) {
			rs["iTotalRecords"] = getTotalRecords();
		}
		if (getTotalDisplayRecords() GT 0) {
			rs["iTotalDisplayRecords"] = getTotalDisplayRecords();
		}
		if (getDataFormat() IS "array") {
			rs["aaData"] = arrayOfArrays();
		} else {
			rs["aaData"] = arrayOfStructs();
		}
		return serializeJSON(rs);
	}
}
