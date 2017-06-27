/**
* @author Adrian J. Moreno
* @website http://iknowkungfoo.com
* @Twitter: @iknowkungfoo
* @hint: A custom JSON render object for ColdFusion queries.
* @Repo: https://github.com/iknowkungfoo/cfquery-to-json
* @version 4.0
* @requirements ColdFusion 9.0+ or Railo 4+
* @BlogPost: http://cfml.us/Ce
*/

component output="false" accessors="true" {

    /**
     * @required true
     * @setter false
     * @hint The query object to convert to JSON.
     */
    property query data;
    /**
     * @required false
     * @default "json"
     * @hint Sets the content-type for the response.
     */
    property string contentType;
    /**
     * @required false
     * @default true
     * @hint Prefix the content with keys.
     */
    property boolean dataHandle;
    /**
     * @required false
     * @default "data"
     * @hint The key for the data contained in the response.
     */
    property string dataHandleName;
    /**
     * @required false
     * @default true
     * @hint Return data as
     *              true: an array of objects with data in name/value pairs
     *              false: an array of arrays with data as unnamed elements
     * @example true: [{"id": 1, "value": "yes"}], false: [["1", "yes"]]
     */
    property boolean dataKeys;
    /**
     * @required false
     * @default false
     * @hint Data return formst, overrides dataHandle property.
     *              true: return data content only, setDataHandle(false)
     *              false: return standard data packet, setDataHandle(true)
     */
    property boolean dataOnly;
    /**
     * @required false
     * @default "lower"
     * @hint return data keys in "upper"- or "lower"-case.
     */
    property string dataKeyCase;

    /**
     * Setup JSON response packet.
     * @return ArrayCollection
     */
    public ArrayCollection function init() {
        variables.stData = {
            "success": true
            , "message": "Array Collection created."
            , "meta": {
                "offset": 0
                , "pageSize": 0
                , "totalRecords": 0
            }
            , "data": []
        };
        return this;
    }

    /**
     * Setup query object to convert with related data as needed.
     * @param required query        data          Query Object
     * @param numeric  offset       Query record offset
     * @param numeric  pageSize     Query record limit
     * @param numeric  totalRecords Query total records is data set
     * @param boolean  success
     * @param string   message
     */
    public ArrayCollection function setData( required query data, numeric offset, numeric pageSize, numeric totalRecords, boolean success, string message ) {
        variables.data = arguments.data;
        variables.stData.meta["offset"] = structKeyExists(arguments, "offset") ? arguments.offset : 0;
        variables.stData.meta["pageSize"] = structKeyExists(arguments, "pageSize") ? arguments.pageSize : arguments.data.recordcount;
        variables.stData.meta["totalRecords"] = structKeyExists(arguments, "totalRecords") ? arguments.totalRecords : arguments.data.recordcount;
        structKeyExists(arguments, "message") ? setMessage(arguments.message) : setMessage("Array Collection populated.");
        if (structKeyExists(arguments, "success")) { setSuccess(arguments.success); }
        return this;
    }

    /**
     * Overrides the DataHandle property. Returns on the data array.
     * @param required boolean dataOnly
     */
    public ArrayCollection function setDataOnly(required boolean dataOnly ) {
        setDataHandle(!arguments.dataOnly);
        return this;
    }

    /**
     * Reset data to an empty query object.
     * @param  required array columns Array of columns from original query object.
     */
    public ArrayCollection function resetData(required array columns) {
        setData(data: querynew(arrayToList(arguments.columns)));
        return this;
    }

    /**
     * Was the query successful or not?
     * @param required boolean success
     */
    public ArrayCollection function setSuccess(required boolean success) {
        variables.stData.success = arguments.success;
        return this;
    }

    /**
     * Set a message to be returned to the client.
     * @param required string message
     */
    public ArrayCollection function setMessage(required string message) {
        variables.stData.message = arguments.message;
        return this;
    }

    /**
     * Set other data in the meta object. Will not overwrite default keys.
     * @param required string key   meta struct key
     * @param required any    value meta struct key value
     */
    public ArrayCollection function setMetaKey(required string key, required any value) {
        if (!structKeyExists(variables.stData.meta, arguments.key)) {
            variables.stData.meta[arguments.key] = arguments.value;
        }
        return this;
    }

    /**
     * Change the existing columns names of the query object to a supplied array.
     * @param  required array names Array of columns names, must match original column order and length
     * @return ArrayCollection
     */
    public ArrayCollection function changeColumnNames( required array names ) {
        if (!arrayIsEmpty(arguments.names)) {
            var aOriginalNames = getData().getColumnNames();
            if (arraylen(aOriginalNames) NEQ arrayLen(arguments.names)) {
                resetData(aOriginalNames)
                    .setSuccess(false)
                    .setMessage("Requested column names array length does not match the number of query columns.")
                    .setMetaKey("originalNames", aOriginalNames)
                    .setMetaKey("requestedNames", arguments.names);
            } else {
                getData().setColumnNames(arguments.names);
            }
        }
        return this;
    }

    /**
     * Render the collection data structure as JSON
     * @return json
     */
    public string function $renderdata() {
        var aData = [];
        if (getDataKeys()){
            aData = arrayOfStructs();
        } else {
            aData = arrayOfArrays();
        }
        if (getDataHandle()) {
            variables.stData[getDataHandleName()] = aData;
            return serializeJSON(variables.stData);
        } else {
            return serializeJSON(aData);
        }
    }

    /**
     * Returns the column list ordered alphabetically and in the case requested.
     * @return string
     */
    private string function getColumnList() {
        var columns = listSort( getData().columnlist, "textnocase" );
        if ( getDataKeyCase() IS "lower" ) {
            return lcase( columns );
        } else {
            return ucase( columns );
        }
    }

    /**
     * Convert n query object to an array of structs.
     * @return array
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
     * Convert a query object to an array of arrays.
     * @return array
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
