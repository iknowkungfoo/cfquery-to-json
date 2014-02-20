/**
*
* @author Adrian J. Moreno
* @website http://iknowkungfoo.com
* @Twitter: @iknowkungfoo
* @Description: A custom JSON render object for ColdFusion queries.
* @version 3.0
* @requirements ColdFusion 9.0+ or Railo 4+
* @Repo: https://github.com/iknowkungfoo/cfquery-to-json
* @BlogPost: http://cfml.us/Ce
*
*/

component output="false" accessors="true" {

    property name="data" type="query" required="true";
    property name="contentType" type="string" required="true";
    property name="dataHandle" type="boolean" required="true";
    property name="dataHandleName" type="string" required="true";
    property name="dataKeys" type="boolean" required="true";
    property name="dataKeyCase" type="string" required="false" default="lower";
    property name="dataFormat" type="string" required="false" default="struct";

    public ArrayCollection function init() {
        setContentType("json");
        setDataKeys(true);
        setDataKeyCase("lower");
        setDataHandle(true);
        setDataHandleName("data");
        setDataFormat("struct");
        return this;
    }

    public string function $renderdata() {
        var aData = [];
        var stData = {};
        if (getDataKeys()){
            aData = arrayOfStructs();
        } else {
            aData = arrayOfArrays();
        }
        if (getDataHandle()) {
            stData[getDataHandleName()] = aData;
            return serializeJSON(stData);
        } else {
            return serializeJSON(aData);
        }
    }

    private string function getColumnList() {
        var columns = listSort( getData().columnlist, "textnocase" );
        if ( getDataKeyCase() IS "lower" ) {
            return lcase( columns );
        } else {
            return ucase( columns );
        }
    }

    /**
    * @hint Convert a query to an array of structs.
    */

    private array function arrayOfStructs() {
        var results = [];
        var temp = {};
        var q = getData();
        var rc = q.recordCount;
        var fields = listToArray(getColumnList());
        var fc = arrayLen(fields);
        var x = 0;
        var y = 0;
        var fieldName = "";

        for ( x = 1; x LTE rc; x++ ){
            temp = {};
            for ( y = 1; y LTE fc; y++ ) {
                fieldName = fields[y];
                temp[fieldName] = q[fieldName][x];
            }
            arrayAppend( results, temp );
        }
        return results;
    }

    /**
    * @hint Convert a query to an array of arrays.
    */

    private array function arrayOfArrays() {
        var results = [];
        var temp = [];
        var q = getData();
        var rc = q.recordCount;
        var fields = listToArray(getColumnList());
        var fc = arrayLen(fields);
        var x = 0;
        var y = 0;

        for ( x = 1; x LTE rc; x++ ) {
            temp = [];
            for ( y = 1; y LTE fc; y++ ) {
                arrayAppend( temp, q[fields[y]][x] );
            }
            arrayAppend( results, temp );
        }
        return results;
    }

}
