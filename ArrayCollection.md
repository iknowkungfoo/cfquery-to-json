ArrayCollection
===============

A custom JSON render object for ColdFusion queries

Details at blog post:

http://iknowkungfoo.com/blog/index.cfm/2012/5/11/ArrayCollectioncfc-a-custom-JSON-renderer-for-ColdFusion-queries

**Simple example**

```
<cffunction name="books" access="remote" output="false" returntype="string">
    <cfargument name="term" type="string" required="true" />
    <cfset var rs = {} />
    <cfquery name="rs.q" datasource="cfbookclub">
        SELECT DISTINCT
            bookid,
            title,
            genre
        FROM
            books
        WHERE
            title LIKE <cfqueryparam value="%#arguments.term#%" cfsqltype="cf_sql_varchar" />
        ORDER BY
            genre, title
    </cfquery>
    <cfset rs.ac = createObject("component", "ArrayCollection").init() />
    <cfset rs.ac.setData( rs.q ) />
    <cfreturn rs.ac.$renderdata() />
</cffunction>

<cfdump var="#books('Man')# />
```

**Output: Version 4**
```
{
    "data": [
        {
            "bookid": 8,
            "genre": "Fiction",
            "title": "Apparition Man"
        },
        {
            "bookid": 2,
            "genre": "Non-fiction",
            "title": "Shopping Mart Mania"
        }
    ],
    "message": "Array Collection populated.",
    "meta": {
        "offset": 0,
        "pageSize": 2,
        "totalRecords": 2
    },
    "success": true
}
```

**New in Version 4**

Refactored script CFC

Added additional keys: 
* "message": String
* "meta": object containing "offset", "pageSize" and "totalRecords"
* "success": boolean

If you trigger setDataOnly(true), the only the contents of the "data" key are returned.

**New in Version 3**

Converted to a script CFC

Renamed queryToArrayOfStructs to arrayOfStructs.

Renamed queryToArrayOfArrays to arrayOfArrays.

Added the property "dataFormat" to convert between array or struct output.

**New in Version 2**

The function setDataKeys() triggers the return of an array of structs (true) or an array of arrays (false).

The function setDataKeyCase() changes the column names (keys) in the structs from lowercase (default) to uppercase.

**Depricated**

The function setDataType() was replaced with setDataKeys().
